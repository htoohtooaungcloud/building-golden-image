# Building Golden Image

## Overview
This project demonstrates the process of building a golden AMI (Amazon Machine Image) using HashiCorp's infrastructure as code tools. The golden image approach ensures consistent and reproducible environments for your applications.

## Prerequisites
- AWS CLI configured with appropriate credentials
- HashiCorp Packer >= 1.9.0
- Ansible >= 2.15.0
- HashiCorp Terraform >= 1.5.0
- AWS Account with appropriate permissions
- AWS Profile configured as `hc-aws-dev-terraform` in my case

## Project Structure
```
.
├── ansible.cfg              # Ansible configuration
├── aws-ubuntu.pkr.hcl      # Packer configuration for AWS Ubuntu AMI
├── group_vars/             # Ansible group variables
├── playbooks/              # Ansible playbooks
│   └── templates/          # Jinja2 templates
└── terraform-deploy/       # Terraform configuration
```

## Features
- Automated AMI creation with Docker and Docker Compose pre-installed
- Nginx deployment configuration included
- Infrastructure deployment templates using Terraform
- Automated configuration management using Ansible

## Usage

### 1. Building the Golden Image
Build the AMI image using Packer:
```bash
packer build aws-ubuntu.pkr.hcl
```

### 2. Validating the AMI
Verify the newly created AMI using AWS CLI:
```bash
aws ec2 describe-images \
  --owners self \
  --filters "Name=tag:packer-golden,Values=true" \
  --query 'Images[*].[ImageId,Name,CreationDate,Tags[?Key==`Name`].Value|[0]]' \
  --output table \
  --profile hc-aws-dev-terraform
```

### 3. Deploying Infrastructure
Navigate to the Terraform directory and apply the configuration:
```bash
cd terraform-deploy
terraform plan \
    -var-file=terraform.tfvars \
    -out=terraform.tfplan \
    > terraform-plan.log 2>&1
```

Review the plan output:
```bash
tail -n 30 terraform-plan.log
```

### 4. AMI Management
List all golden AMIs sorted by creation date:
```bash
aws ec2 describe-images \
    --owners self \
    --filters "Name=tag:packer-golden,Values=true" \
    --query 'Images | sort_by(@, &CreationDate) | reverse(@) | [].[ImageId,Name,CreationDate]' \
    --output table \
    --profile hc-aws-dev-terraform
```

## Example Output
```
-----------------------------------------------------------------------------------------
|                                    DescribeImages                                     |
+-----------------------+----------------------------------+----------------------------+
|  ami-02c5aeeb7e75fe665|  ubuntu-24-04-docker-1751098835  |  2025-06-28T08:26:10.000Z  |
|  ami-01cd2788f2acb97dd|  ubuntu-24-04-docker-1751096377  |  2025-06-28T07:44:52.000Z  |
+-----------------------+----------------------------------+----------------------------+
```

## Contributing
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Maintainers
- Htoo Htoo <Devotee of Cloud and DevOps>

## Note
Remember to update your AWS credentials and region settings before running the commands.