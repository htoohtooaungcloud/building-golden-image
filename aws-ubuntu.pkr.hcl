# Variable declarations
variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_name_prefix" {
  type    = string
  default = "ubuntu-24-04-docker"
}

variable "source_ami_owner" {
  type    = string
  default = "099720109477"  # Canonical's AWS account ID
}

variable "aws_profile" {
  type    = string
  default = "hc-aws-dev-terraform"
  description = "AWS profile to use for building the AMI"
}

# Packer configuration
packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.7"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "amazon-ebs" "ubuntu-docker" {
  region        = var.aws_region
  instance_type = var.instance_type
  ami_name      = "${var.ami_name_prefix}-{{timestamp}}"
  profile       = var.aws_profile
  
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*24.04*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      state              = "available"
      architecture       = "x86_64"
    }
    owners      = [var.source_ami_owner]
    most_recent = true
  }
  
  ssh_username    = "ubuntu"
  ami_description = "Golden Image: Ubuntu 24.04 with Docker and Docker Compose"
  
  tags = {
    "Name"          = "${var.ami_name_prefix}-{{timestamp}}"
    "packer-golden" = "true"
    "project"       = "golden-image"
  }
}

build {
  name    = "ubuntu-docker"
  sources = ["source.amazon-ebs.ubuntu-docker"]
  
  # Wait for cloud-init to finish
  provisioner "shell" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait",
      "echo 'Cloud-init completed'"
    ]
  }
  
  # Run Ansible playbook to install Docker and configure system
  provisioner "ansible" {
    playbook_file = "./playbooks/deploy-nginx.yml"
    user         = "ubuntu"
    use_proxy    = false
    extra_arguments = [
      "--become",
      "--become-user=root",
      "-v",
      "--extra-vars", "packer_hostname=webserver-{{ timestamp }}"
    ]
  }
  
  # Cleanup and prepare image
  provisioner "shell" {
    inline = [
      "echo 'Cleaning up...'",
      "sudo apt-get autoremove -y",
      "sudo apt-get autoclean",
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/tmp/*",
      "sudo rm -f /home/ubuntu/.bash_history",
      "sudo rm -f /root/.bash_history",
      "# Clean up cloud-init artifacts",
      "sudo rm -rf /var/lib/cloud/instance/",
      "sudo rm -rf /var/log/cloud-init*",
      "# Clean up SSH host keys (will be regenerated on first boot)",
      "sudo rm -f /etc/ssh/ssh_host_*",
      "# Clean up machine ID",
      "sudo truncate -s 0 /etc/machine-id"
    ]
  }
}