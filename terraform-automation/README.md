# 🤖 Infrastructure as Code: Terraform Automation

This directory represents the evolution of this project from a manual AWS Console build into a fully automated, reusable DevOps workflow. 

## 📍 Iteration 2: Manual HCL & Technical Translation
After completing the manual build (see main README), I translated the architecture into HashiCorp Configuration Language (HCL). This stage focused on modularity, state management, and security best practices.

### 💡 Key Architectural & Security Decisions
* **Dynamic AMI Resolution:** I used a `data` block to fetch the latest Amazon Linux 2 AMI rather than hardcoding an ID. This ensures the launch template always spins up instances with the latest security patches.
* **Separation of Variables:** Database passwords and sensitive parameters are declared in `variables.tf`. This ensures no active secrets are accidentally committed to GitHub.
* **Multi-AZ Fault Tolerance:** Resources are spread across multiple Availability Zones (`us-east-1a` and `us-east-1b`) to ensure application uptime during a data center failure.

## 📍 Iteration 3: AI Sounding Board & "One-Shot" Prompting
In the final phase, I utilized an AI coding assistant as a technical sounding board to stress-test the logic of these files and refine my prompt engineering skills. 

**The Goal:** To engineer a "One-Shot" prompt capable of reproducing this entire compliant configuration in a single interaction.

### 🏆 The Engineered One-Shot Prompt
To replicate this specific automation environment in a fresh AI chat, use the following multi-constraint prompt:

> "Act as a Senior AWS Solutions Architect and DevOps Engineer. Generate a single, complete `main.tf` file for a high-availability WordPress application on AWS with the following strict constraints:
> 
> 1. **Networking:** Create a custom VPC (`Prod-app-vpc`) with a `10.0.0.0/16` CIDR block. Deploy 6 subnets across 2 Availability Zones (`us-east-1a` and `us-east-1b`): 2 Public (`Prod-pub-sub`), 2 App (`Prod-app-sub`), and 2 Data (`Prod-data-sub`).
> 2. **Gateways & Routing:** Include an Internet Gateway (`Prod-IGW`) and two NAT Gateways (`Prod-NAT-GW`) mapped to the public subnets so private app subnets can reach the internet. 
> 3. **Compute:** Set up a Launch Template using the latest Amazon Linux 2 AMI on a free-tier `t2.micro` instance type. In the `user_data`, include permissions fixes for Apache: `chown -R apache:apache /var/www/html` and `chmod -R 755 /var/www/html`.
> 4. **Scaling & Load Balancing:** Create an Internet-facing Application Load Balancer (`Prod-alb`) targeting an Auto Scaling Group (`Prod-app-asg`) with a minimum of 2 instances and a max of 4.
> 5. **Database:** Deploy a Multi-AZ MariaDB instance on RDS (`Prod-mariadb`) on a free-tier `db.t3.micro` instance class. Use engine version `10.11` and name the database `wordpress_storage_db`. It must only be accessible from the App subnet security group on port 3306.
> 6. **Security Naming Rule:** Ensure all security groups use the prefix `Prod-sg-` (e.g., `Prod-sg-alb`, `Prod-sg-app`, `Prod-sg-db`). Do NOT use the system-reserved prefix `sg-` directly in user-defined names.
> 7. **Best Practice:** Use variables for the RDS database username and password to avoid hardcoded secrets."

---

## 📁 Files in this Directory
* `main.tf`: The primary configuration file holding the provider, network, compute, and database blocks.
* `variables.tf`: Defines the dynamic inputs so hardcoded secrets never touch GitHub.
* `.gitignore`: Strictly prevents sensitive local state files (`.tfstate`) from being uploaded.

## 🚀 Deployment Instructions (Simulation Mode)
1. Navigate to this directory: `cd terraform-automation`
2. `terraform init` - Initialize provider plugins.
3. `terraform plan` - View the deployment blueprint.
   * *Note: A 403 error is expected during plan if active AWS credentials are not exported to the terminal.*

## ⚠️ Important Note on Permissions
This project uses a dynamic data lookup for the Amazon Linux 2 AMI. 
* **Requirement:** Ensure your AWS IAM user has the `ec2:DescribeImages` permission. 
* Without this, AWS will block the lookup and return a `403 Authorization` error during the plan phase.
