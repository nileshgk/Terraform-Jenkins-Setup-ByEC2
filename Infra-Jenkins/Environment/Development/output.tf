output "vpc_id" {
  value = aws_vpc.aws_vpc_jenkins.id
}

output "security_group_id" {
  value = aws_security_group.jenkins_sg.id
}

output "public_subnet1_id" {
  value = aws_subnet.aws_pub_subnet_jenkins1.id
}

output "public_subnet2_id" {
  value = aws_subnet.aws_pub_subnet_jenkins2.id
}
