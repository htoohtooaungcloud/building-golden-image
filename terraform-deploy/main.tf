# Local value to determine which AMI to use
locals {
  selected_ami_id = var.ami_selection_strategy == "latest" ? (
    length(data.aws_ami.golden_image_latest) > 0 ? data.aws_ami.golden_image_latest[0].id : ""
    ) : (
    length(data.aws_ami.golden_image_specific) > 0 ? data.aws_ami.golden_image_specific[0].id : ""
  )

  selected_ami_name = var.ami_selection_strategy == "latest" ? (
    length(data.aws_ami.golden_image_latest) > 0 ? data.aws_ami.golden_image_latest[0].name : ""
    ) : (
    length(data.aws_ami.golden_image_specific) > 0 ? data.aws_ami.golden_image_specific[0].name : ""
  )

  selected_ami_creation_date = var.ami_selection_strategy == "latest" ? (
    length(data.aws_ami.golden_image_latest) > 0 ? data.aws_ami.golden_image_latest[0].creation_date : ""
    ) : (
    length(data.aws_ami.golden_image_specific) > 0 ? data.aws_ami.golden_image_specific[0].creation_date : ""
  )
}

# Create a security group for web servers
resource "aws_security_group" "webserver_sg" {
  name        = "webserver-security-group"
  description = "Security group for web servers"

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webserver-security-group"
  }
}

# Validation check to ensure AMI is selected
resource "null_resource" "ami_validation" {
  count = local.selected_ami_id == "" ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'ERROR: No AMI found with the specified criteria' && exit 1"
  }
}

# Create 3 EC2 instances using the selected golden image
resource "aws_instance" "webserver" {
  count                  = 3
  ami                    = local.selected_ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]

  depends_on = [null_resource.ami_validation]

  # Set hostname using user_data
  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Set hostname
    hostnamectl set-hostname webserver${count.index + 1}
    echo "127.0.0.1 webserver${count.index + 1}" >> /etc/hosts
    
    # Update /etc/cloud/cloud.cfg to preserve hostname
    sed -i 's/preserve_hostname: false/preserve_hostname: true/' /etc/cloud/cloud.cfg
    
    # Restart services to apply hostname changes
    systemctl restart systemd-hostnamed
    EOF
  )

  tags = {
    Name        = "webserver${count.index + 1}"
    Environment = "production"
    Project     = "webserver-deployment"
    CreatedBy   = "terraform"
  }

  # Add a name tag for easier identification
  volume_tags = {
    Name = "webserver${count.index + 1}-root-volume"
  }
}
