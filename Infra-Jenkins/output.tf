output "jenkins_instance_public_ip" {
  value = aws_instance.Jenkins_EC2.public_ip
}

output "jenkins_url" {

  value = "http://${aws_instance.Jenkins_EC2.public_ip}:8080"

}
output "jenkins_instance_id" {
  value = aws_instance.Jenkins_EC2.id
}

output "vpc_id" {
  value = aws_vpc.jenkins_vpc.id
}

output "security_group_id" {
  value = aws_security_group.vpc_jenkins_sg.id
}

output "public_subnet1_id" {
  value = aws_subnet.jenkins_pub_subnet1.id
}

output "public_subnet2_id" {
  value = aws_subnet.jenkins_pub_subnet2.id
}
