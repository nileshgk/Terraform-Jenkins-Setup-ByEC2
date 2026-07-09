# AWS PROVIDER CONFIGURATION
provider "aws" {
  region = var.region
}

# resource Key pair for Jenkins EC2 instance
resource "aws_key_pair" "jenkins_key_pair" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "Jenkins_EC2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.jenkins_key_pair.key_name
  subnet_id     = aws_subnet.jenkins_pub_subnet1.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.vpc_jenkins_sg.id]

user_data = file("${path.module}/Jenkins.sh")

  tags = {
    Name        = "Jenkins-EC2"
    environment = var.vpc_environment
  }
  
}