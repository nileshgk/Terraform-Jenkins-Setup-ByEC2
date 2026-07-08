output "jenkins_instance_id" {
  value = aws_instance.jenkins_ec2_instance.id
}

output "jenkins_instance_public_ip" {
  value = aws_instance.jenkins_ec2_instance.public_ip
}