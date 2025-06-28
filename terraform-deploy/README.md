# Terraform AWS Ubuntu EC2

This project provisions an EC2 instance using the latest Ubuntu 24.04 LTS AMI ID retrieved through a data source in Terraform.

## Prerequisites

- Terraform installed on your machine.
- AWS account with appropriate permissions to create EC2 instances.

## Setup

1. Clone this repository to your local machine.
2. Navigate to the project directory.

   ```bash
   cd terraform-aws-ubuntu-ec2
   ```

3. Initialize the Terraform configuration.

   ```bash
   terraform init
   ```

4. Review the planned actions.

   ```bash
   terraform plan
   ```

5. Apply the configuration to provision the EC2 instance.

   ```bash
   terraform apply
   ```

6. Follow the prompts to confirm the action.

## Outputs

After the successful execution of the Terraform configuration, you will receive the public IP address of the created EC2 instance.

## Cleanup

To remove the resources created by this project, run:

```bash
terraform destroy
```

## License

This project is licensed under the MIT License.