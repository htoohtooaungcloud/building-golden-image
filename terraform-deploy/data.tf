# Data source to retrieve the golden image AMI created by Packer (LATEST VERSION)
data "aws_ami" "golden_image_latest" {
  count       = var.ami_selection_strategy == "latest" ? 1 : 0
  most_recent = true
  owners      = ["self"] # Look for AMIs created by your account

  filter {
    name   = "tag:packer-golden"
    values = ["true"]
  }

  filter {
    name   = "tag:project"
    values = ["golden-image"]
  }

  filter {
    name   = "name"
    values = ["ubuntu-24-04-docker-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Data source for specific AMI ID
data "aws_ami" "golden_image_specific" {
  count  = var.ami_selection_strategy == "specific" ? 1 : 0
  owners = ["self"]

  filter {
    name   = "image-id"
    values = [var.specific_ami_id]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}