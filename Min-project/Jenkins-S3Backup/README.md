# Terraform-Jenkins-Setup-ByEC2

🔑 SSH Configuration
Before running terraform apply, you must generate an SSH key pair to secure your instance:

Generate keys:
Bash
ssh-keygen -t rsa -b 2048 -f keys/Jenkins
(Press Enter twice to leave the passphrase empty).

Security: * Jenkins (Private) - KEEP PRIVATE. Never commit this to Git.

Jenkins.pub (Public) - Used by Terraform to authorize your access.

SSH into instance
ssh -i .\keys\Jenkins ec2-user@<EC2_PUBLIC_IP>

🚀 Usage
Configure AWS credentials: aws configure
Initialize: terraform init
Preview changes: terraform plan
Deploy: terraform apply

🛡️ Security
.gitignore is configured to ignore private keys, Terraform state files, and local provider binaries.
Ensure you do not hardcode credentials in your .tf files.