# 🤖 Infrastructure as Code: Terraform Automation

This directory represents the evolution of this project from a manual AWS Console build into a fully automated, reusable DevOps workflow. 

## 📍 Iteration 2: Manual HCL Translation & IDE Mastery
After completing the manual build (see main README), I transitioned into **VS Code** to translate the architecture into HashiCorp Configuration Language (HCL). This was a critical learning phase focused on moving from a GUI-based workflow to a professional developer environment.

### 🧠 Key Technical Milestones:
* **IDE Workflow:** I mastered using VS Code and the Terraform CLI to manage infrastructure. I learned to interpret `terraform plan` outputs to troubleshoot resource dependencies before deployment.
* **State & Security Logic:** I gained hands-on experience managing local state files and used a `.gitignore` to ensure sensitive infrastructure metadata remained secure.
* **Technical Troubleshooting:** I successfully navigated common IaC hurdles, such as resolving circular dependencies in Security Groups and ensuring the correct order of operations for NAT Gateways and Route Tables.

### 💡 Architectural Decisions:
* **Dynamic AMI Resolution:** I used a `data` block to fetch the latest Amazon Linux 2 AMI rather than hardcoding an ID. This ensures the launch template always spins up instances with the latest security patches.
* **Separation of Variables:** Database passwords and sensitive parameters are declared in `variables.tf`. This ensures no active secrets are accidentally committed to GitHub.
* **Multi-AZ Fault Tolerance:** Resources are spread across multiple Availability Zones (`us-east-1a` and `us-east-1b`) to ensure application uptime during a data center failure.

## 📍 Iteration 3: AI Sounding Board & "One-Shot" Prompting
In the final phase, I utilized an AI coding assistant as a technical sounding board to stress-test my logic and refine my **Prompt Engineering** skills. By treating the AI as a "Junior Engineer" and myself as the "Supervisor," I audited the generated code for hallucinations (like oversized instances or naming errors).

**The Goal:** To engineer a single, multi-constraint prompt capable of reproducing this entire compliant configuration in one go.

### 🏆 The Engineered One-Shot Prompt
To replicate this specific multi-file automation environment in a fresh AI chat, use the following prompt:

> "Act as a Senior AWS Solutions Architect and DevOps Engineer. Generate the complete Terraform configuration for a high-availability WordPress application on AWS. **Provide the output in two distinct code blocks: one for `main.tf` and one for `variables.tf`**, following these strict constraints:
> 
> 1. **Networking:** Create a custom VPC (`Prod-app-vpc`) with a `10.0.0.0/16` CIDR block. Deploy 6 subnets across 2 Availability Zones (`us-east-1a` and `us-east-1b`): 2 Public (`Prod-pub-sub`), 2 App (`Prod-app-sub`), and 2 Data (`Prod-data-sub`).
> 2. **Gateways & Routing:** Include an Internet Gateway (`Prod-IGW`) and two NAT Gateways (`Prod-NAT-GW`) mapped to the public subnets so private app subnets can reach the internet. 
> 3. **Compute:** Set up a Launch Template using the latest Amazon Linux 2 AMI on a free-tier `t2.micro` instance type. In the `user_data`, include permissions fixes for Apache: `chown -R apache:apache /var/www/html` and `chmod -R 755 /var/www/html`.
> 4. **Scaling & Load Balancing:** Create an Internet-facing Application Load Balancer (`Prod-alb`) targeting an Auto Scaling Group (`Prod-app-asg`) with a minimum of 2 instances and a max of 4.
> 5. **Database:** Deploy a Multi-AZ MariaDB instance on RDS (`Prod-mariadb`) on a free-tier `db.t3.micro` instance class. Use engine version `10.11` and name the database `wordpress_storage_db`. It must only be accessible from the App subnet security group on port 3306.
> 6. **Security Naming Rule:** Ensure all security groups use the prefix `Prod-sg-` (e.g., `Prod-sg-alb`, `Prod-sg-app`, `Prod-sg-db`). Do NOT use the system-reserved prefix `sg-` directly in user-defined names.
> 7. **Best Practice:** Ensure all sensitive inputs (DB username/password) are defined in the `variables.tf` block and referenced in `main.tf` to avoid hardcoded secrets."

---

## 📁 Files in this Directory
* `main.tf`: The primary configuration file holding the provider, network, compute, and database blocks.
* `variables.tf`: Defines the dynamic inputs (like DB passwords) so hardcoded secrets never touch GitHub.
* `.gitignore`: Strictly prevents sensitive local state files (`.tfstate`) from being uploaded.

## 🚀 Deployment Instructions
1. Navigate to this directory: `cd terraform-automation`
2. Run `terraform init` to download the AWS provider plugins.
3. Run `terraform plan` to view the deployment blueprint.
4. Run `terraform apply` to build the isolated, multi-AZ environment.
5. Run `terraform destroy` when finished to safely tear down the infrastructure.

## ⚠️ Important Note on Permissions & Errors
This project uses a dynamic data lookup for the Amazon Linux 2 AMI. 
* **Requirement:** Ensure your AWS IAM user has the `ec2:DescribeImages` permission. 
* **Troubleshooting:** If you receive a **403 Authorization** error during the plan phase, ensure your AWS credentials are properly exported to your terminal session and your user has the correct permissions.
