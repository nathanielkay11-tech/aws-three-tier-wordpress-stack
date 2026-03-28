# AWS High-Availability Three-Tier WordPress Stack

## Project Overview
The goal of this project was to architect and manually deploy a highly available, **three-tier WordPress environment** on AWS. By building this from scratch in the AWS Console, I gained a deep operational understanding of secure networking, high-availability compute, and decoupled data layers. This project demonstrates a **security-first approach**, utilizing private subnets, NAT Gateways for secure egress, and automated recovery via Auto Scaling.

---

## Figure 0: High-Level Solution Architecture
![Architecture Diagram](figure0.png)

### Architecture Summary:
This diagram visualizes the end-to-end traffic flow and security boundaries of the environment. It illustrates a **Three-Tier Architecture** mirrored across two **Availability Zones** to ensure high availability. By utilizing an **Application Load Balancer (ALB)** for ingress and a **NAT Gateway** for secure egress, the design keeps the WordPress and Database layers strictly private.

---

## Technical Implementation & Evidence

### 1. Networking & Security Infrastructure
I established a dedicated VPC with a tiered subnet strategy, separating public-facing entry points from sensitive internal data.
![VPC Setup](figure1.png)

* **Security Group Chaining:** Implemented "Least Privilege" access, ensuring the Database only accepts traffic from the Web Tier.
![Security Groups](figure2.png)

### 2. Compute & Database Layer
Deployed a scalable WordPress fleet via an Auto Scaling Group and a managed RDS MariaDB instance.
![Compute Layer](figure5.png)

### 3. Troubleshooting & Optimization
During the deployment, I identified and resolved a Linux file permission conflict by updating the Launch Template and performing an **Instance Refresh**.
![Troubleshooting](figure7.png)
