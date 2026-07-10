#terraform {
#  backend "s3" {
#    bucket         = "jenkins-backup-bucket-2026" # Replace with your unique state bucket name
#    key            = "jenkins-infrastructure/terraform.tfstate"
#    region         = "us-east-1"                     # Must match your infrastructure region
#    encrypt        = true
#    dynamodb_table = "terraform-state-locks"         # Enables state locking to prevent conflicts
#  }
#}