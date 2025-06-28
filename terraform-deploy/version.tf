provider "aws" {
  shared_config_files      = ["/home/htoohtoo/.aws/config"]
  shared_credentials_files = ["/home/htoohtoo/.aws/credentials"]
  profile                  = "hc-aws-dev-terraform"
  region                   = var.aws_region
}
