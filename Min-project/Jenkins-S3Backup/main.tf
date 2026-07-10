# AWS PROVIDER CONFIGURATION
provider "aws" {
  region = var.region
}

# resource Key pair for Jenkins EC2 instance
resource "aws_key_pair" "jenkins_key_pair" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Jenkins EC2 Instance
resource "aws_instance" "Jenkins_EC2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.jenkins_key_pair.key_name
  subnet_id     = aws_subnet.jenkins_pub_subnet1.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.vpc_jenkins_sg.id]
  
  # Root block device configuration to increase volume to 20 GB
  root_block_device {
    volume_size           = 20    # Provision 20 GB of storage
    volume_type           = "gp3" # High performance, cost-effective storage tier
    encrypted             = true  # Ensures volume encryption at rest
    delete_on_termination = true  # Automatically deletes the volume when the instance is torn down
  }
  
user_data = file("${path.module}/Jenkins.sh")

  tags = {
    Name        = "Jenkins-EC2"
    environment = var.vpc_environment
  }
# This is how you reference the instance profile block from above:
  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name
 
}
# AWS S3 Bucket for Jenkins Backups
resource "aws_s3_bucket" "jenkins_backup" {
  bucket        = var.bucket_name
  force_destroy = false

  tags = {
    Name        = "Jenkins Backup Bucket"
    Environment = var.vpc_environment
    ManagedBy   = "Terraform"
  }
}
# Enable S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "jenkins_backup_versioning" {
  bucket = aws_s3_bucket.jenkins_backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-Side Encryption (Crucial for storing configuration credentials safely)
resource "aws_s3_bucket_server_side_encryption_configuration" "jenkins_backup_crypto" {
  bucket = aws_s3_bucket.jenkins_backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly Block Public Access (Ensures your backups remain completely secure)
resource "aws_s3_bucket_public_access_block" "jenkins_backup_privacy" {
  bucket = aws_s3_bucket.jenkins_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM Policy for Jenkins S3 Access
resource "aws_iam_policy" "jenkins_s3_policy" {
  name        = "JenkinsS3BackupPolicy-${var.vpc_environment}"
  description = "Allows Jenkins to push and pull backups from S3 in ${var.vpc_environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "JenkinsS3Access"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.jenkins_backup.arn}",
          "${aws_s3_bucket.jenkins_backup.arn}/*"
        ]
      }
    ]
  })
}

# IAM Role for EC2
resource "aws_iam_role" "jenkins_role" {
  name = "JenkinsBackupRole-${var.vpc_environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "jenkins_attach" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_s3_policy.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "JenkinsInstanceProfile-${var.vpc_environment}"
  role = aws_iam_role.jenkins_role.name
}