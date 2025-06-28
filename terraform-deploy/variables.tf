
# Variables
variable "aws_region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS region"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  description = "AWS Key Pair name for SSH access"
  default     = "golden-image"
}

# Variable to control AMI selection strategy
variable "ami_selection_strategy" {
  type        = string
  default     = "latest"
  description = "AMI selection strategy: 'latest' for most recent, 'specific' for exact AMI ID"

  validation {
    condition     = contains(["latest", "specific"], var.ami_selection_strategy)
    error_message = "AMI selection strategy must be either 'latest' or 'specific'."
  }
}

variable "specific_ami_id" {
  type        = string
  default     = ""
  description = "Specific AMI ID to use when ami_selection_strategy is 'specific'"
}