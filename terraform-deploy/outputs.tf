output "ami_selection_strategy" {
  description = "AMI selection strategy used"
  value       = var.ami_selection_strategy
}

output "selected_ami_id" {
  description = "AMI ID of the selected golden image"
  value       = local.selected_ami_id
}

output "selected_ami_name" {
  description = "AMI name of the selected golden image"
  value       = local.selected_ami_name
}

output "selected_ami_creation_date" {
  description = "Creation date of the selected golden image"
  value       = local.selected_ami_creation_date
}

# Additional output to show all available golden images for validation
output "all_available_golden_images" {
  description = "All available golden images for validation"
  value = var.ami_selection_strategy == "latest" ? [
    for ami in data.aws_ami.golden_image_latest : {
      id            = ami.id
      name          = ami.name
      creation_date = ami.creation_date
      description   = ami.description
    }
  ] : []
}

output "webserver_instances" {
  description = "Details of the created web server instances"
  value = {
    for i, instance in aws_instance.webserver : "webserver${i + 1}" => {
      instance_id = instance.id
      public_ip   = instance.public_ip
      private_ip  = instance.private_ip
      public_dns  = instance.public_dns
      private_dns = instance.private_dns
    }
  }
}

output "webserver_public_ips" {
  description = "Public IP addresses of the web servers"
  value       = aws_instance.webserver[*].public_ip
}

output "webserver_ssh_commands" {
  description = "SSH commands to connect to each web server"
  value = [
    for i, instance in aws_instance.webserver :
    "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${instance.public_ip}  # webserver${i + 1}"
  ]
}