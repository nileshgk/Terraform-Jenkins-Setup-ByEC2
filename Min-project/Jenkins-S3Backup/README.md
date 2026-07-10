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
Min-project/Jenkins-S3Backup/
│
├── .terraform/                  # Hidden directory containing downloaded AWS provider plugins
├── keys/                        # Secure folder containing your SSH private keys (e.g., Jenkins key pair)
│
├── .gitignore                   # Tells Git which files/folders to ignore (like keys and local state)
├── .terraform.lock.hcl          # Lock file ensuring consistent provider plugin versions across runs
│
├── backend_infra.tf             # Core infra setup for the Remote S3 State & DynamoDB Lock components
├── state.tf                     # Configures the backend block pointing Terraform to use the remote state
│
├── main.tf                      # Core infrastructure definitions (EC2, IAM profiles, S3 Backup targets)
├── vpc.tf                       # Custom network topology (VPC, Subnets, Route Tables, Internet Gateway)
├── securityGroup.tf             # Firewall rules opening ports 22 (SSH), 8080 (Jenkins), and 5000 (App)
│
├── variable.tf                  # Infrastructure input variable declarations (AMI IDs, types, regions)
├── output.tf                    # Outputs public endpoints (like your EC2 Instance's Public IP address)
│
├── terraform.tfstate            # The local state file (generated if state isn't migrated/pushed yet)
├── terraform.tfstate.backup     # The previous state version backup managed locally by Terraform
│
├── Dockerfile                   # Blueprint used by the pipeline to containerize your Vote Application
├── Jenkinsfile                  # Declarative CI/CD ppline scrpt managing build,deploy & S3 backup stages
├── Jenkins.sh                   # shell script used to install Java, Jenkins, and Docker on instance boot
└── README.md                    # Project documentation detailing deployment and usage instructions

🚀 The 4-Step Deployment Execution Workflow
Because we are setting up a secure remote state file backend, follow this precise sequence to spin everything up without any catch-22 errors:

Step 1: Initialize Local State
Make sure your state.tf file is commented out (or temporarily moved out of the folder). Run:
terraform init

Step 2: Build the Backend Infrastructure
Deploy just the state storage and locking mechanism first by target-applying your backend_infra.tf resources:
Bash:
terraform apply -target=aws_s3_bucket.terraform_state -target=aws_dynamodb_table.terraform_locks
Type yes when prompted.

Step 3: Migrate State to the Cloud
Now, uncomment your state.tf file so Terraform knows where to store its records remotely. Run:
terraform init

Terraform will detect the new backend configuration and ask: “Do you want to copy existing state to the new backend?” Type yes.

Step 4: Run the Complete Infrastructure Deployment
Now you can safely deploy everything else (the Jenkins EC2 server, IAM roles, security groups, and the jenkins-backup-bucket-2026 storage bucket):
terraform apply --auto-approve

The Fix: Wrap the targets in double quotes ""
To stop PowerShell from parsing the dots, wrap your target resource paths completely in quotation marks. Run this exact command instead:
Wipe the local cache folder
Remove-Item -Recurse -Force .terraform
Remove-Item -Force .terraform.lock.hcl
PowerShell
terraform apply -target="aws_s3_bucket.terraform_state" -target="aws_dynamodb_table.terraform_locks"

Alternatively (If you still hit issues):
If PowerShell continues to act up with multiple targets, you can target them one at a time using your local state file before migrating:

Target the S3 Bucket first:

PowerShell
terraform apply -target="aws_s3_bucket.terraform_state" --auto-approve
Target the DynamoDB Table second:

PowerShell
terraform apply -target="aws_dynamodb_table.terraform_locks" --auto-approve
Once both are created successfully, you can uncomment your state.tf file and run terraform init to complete the remote backend migration!


🔍 Post-Deployment Verification (What to do next)
Grab the Jenkins Admin Password: SSH into your new EC2 instance or go to the AWS Web Console and read the logs at /var/log/jenkins-install.log to fetch your initial unlock token.

Configure Git & Webhooks: Create your application repository containing your Dockerfile and Jenkinsfile for the voting app, and set up your GitHub webhook pointing to your EC2 IP.

Run your First Build: Run the pipeline manually once to ensure that your voting container builds successfully and that the Phase 3 stage runs /usr/local/bin/jenkins_backup.sh to push your very first backup archive cleanly into S3!