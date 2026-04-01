# 🤖 Infrastructure as Code: Terraform Automation

This folder contains the automated Terraform blueprints for the 3-Tier WordPress Architecture mapped out in the main project directory.

## 📁 Files in this Directory
* `main.tf`: The primary configuration file holding the provider, network, compute, and database blocks.
* `variables.tf`: Defines the dynamic inputs (like DB passwords) so hardcoded secrets never touch GitHub.
* `.gitignore`: Strictly prevents sensitive local state files (`.tfstate`) from being uploaded.

## 🚀 Deployment Instructions
1. Navigate to this directory on your local machine.
2. Run `terraform init` to download the AWS provider plugins.
3. Run `terraform plan` to view the deployment blueprint.
4. Run `terraform apply` to build the isolated, multi-AZ environment.

## ⚠️ Important Note on Dynamic AMI Resolution
This project uses a dynamic data lookup block to always fetch the absolute latest Amazon Linux 2 AMI for the AWS region you are running in. 
* **Requirement:** Ensure your executing AWS IAM user has the `ec2:DescribeImages` permission attached. 
* Without this specific permission, AWS will block the lookup and your `terraform plan` will return a `403 Authorization` error.
