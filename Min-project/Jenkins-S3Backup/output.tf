output "jenkins_instance_public_ip" {
  value = aws_instance.Jenkins_EC2.public_ip
}

output "jenkins_url" {

  value = "http://${aws_instance.Jenkins_EC2.public_ip}:8080"

}
output "jenkins_instance_id" {
  value = aws_instance.Jenkins_EC2.id
  description = "The ID of the Jenkins EC2 instance"
}

output "vpc_id" {
  value = aws_vpc.jenkins_vpc.id
  description = "The ID of the VPC"
}

output "security_group_id" {
  value = aws_security_group.vpc_jenkins_sg.id
  description = "The ID of the security group for the Jenkins EC2 instance"
}

output "public_subnet1_id" {
  value = aws_subnet.jenkins_pub_subnet1.id
  description = "The ID of the first public subnet"
}

output "public_subnet2_id" {
  value = aws_subnet.jenkins_pub_subnet2.id
  description = "The ID of the second public subnet"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.jenkins_backup.id
  description = "The name of the created S3 bucket"
}

output "iam_instance_profile_name" {
  value       = aws_iam_instance_profile.jenkins_profile.name
  description = "The instance profile name to attach to the Jenkins server"
}
