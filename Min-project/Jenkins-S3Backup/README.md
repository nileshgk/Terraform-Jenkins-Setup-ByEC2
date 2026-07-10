# Terraform-Jenkins-Setup-ByEC2

🔑 SSH Configuration
Before running terraform apply, you must generate an SSH key pair to secure your instance:

Generate keys:
Bash
ssh-keygen -t rsa -b 2048 -f keys/Jenkins
(Press Enter twice to leave the passphrase empty).

Security: * Jenkins (Private) - KEEP PRIVATE. Never commit this to Git.

Jenkins.pub (Public) - Used by Terraform to authorize your access.

CMD For SSH into instance 
ssh -i .\keys\Jenkins ec2-user@<EC2_PUBLIC_IP>

# Automated Jenkins Backup & Recovery System

This project implements an automated, production-grade backup and disaster recovery solution for a Jenkins CI/CD infrastructure deployed on AWS using **Terraform**, **Bash**, and **Docker**.

## Project Objective
To mitigate the risk of critical server crashes and data loss by securely archiving Jenkins configuration data into AWS S3, automating daily snapshots, and enabling rapid, minimal-downtime recovery.

## Architecture & Core Features
* **Infrastructure as Code (IaC):** Utilizes Terraform to provision a secure, versioned, and encrypted AWS S3 backup bucket, a remote state storage backend, and a DynamoDB state locking table.
* **Keyless Security:** Implements an AWS IAM Instance Profile attached directly to the Jenkins EC2 instance, eliminating the security risk of hardcoded AWS Access Keys.
* **One-Click Bootstrapping:** Leverages an advanced Amazon Linux 2023 User Data script (`Jenkins.sh`) to automatically install Jenkins (Java 21), native Docker components, and pre-configure service permissions.
* **Automated Data Protection:** Deploys an embedded Bash utility (`jenkins_backup.sh`) that strips heavy caches/workspaces and streams core configuration snapshots directly to S3.
* **Hybrid Triggering:** Features a custom Python Flask voting application pipeline (`Jenkinsfile`) that triggers deployments instantly via GitHub Webhooks, while simultaneously running guaranteed daily S3 backups via an automated cron-schedule.

## File Structure
├── backend_infra.tf   # Remote S3 State & DynamoDB Lock setup
├── main.tf            # Core AWS compute, IAM, and Backup storage assets
├── state.tf           # Terraform remote state backend pointer
├── variables.tf       # Infrastructure input variables
└── Jenkins.sh         # Master system configuration & bootstrap shell script