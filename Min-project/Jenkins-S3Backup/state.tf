terraform {
  backend "s3" {
    bucket         = "nk-jenkins-backup-bucket-11072026" # Replace with your unique state bucket name
    key            = "jenkins-infrastructure/terraform.tfstate"
    region         = "us-east-1" # Must match your infrastructure region
    encrypt        = true
    use_lockfile   = true
  }
}