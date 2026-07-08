# Terraform-Jenkins-Setup-ByEC2

🔑 SSH Configuration
Before running terraform apply, you must generate an SSH key pair to secure your instance:

Generate keys:
Bash
ssh-keygen -t rsa -b 2048 -f my_local_key
(Press Enter twice to leave the passphrase empty).

Security: * my_local_key (Private) - KEEP PRIVATE. Never commit this to Git.

my_local_key.pub (Public) - Used by Terraform to authorize your access.

🚀 Usage
Configure AWS credentials: aws configure
Initialize: terraform init
Preview changes: terraform plan
Deploy: terraform apply

🛡️ Security
.gitignore is configured to ignore private keys, Terraform state files, and local provider binaries.
Ensure you do not hardcode credentials in your .tf files.