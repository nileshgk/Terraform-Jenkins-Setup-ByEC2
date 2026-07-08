# AWS Security Group for Jenkins EC2 instance
resource "aws_security_group" "jenkins_sg" {
  name        = "${var.vpcname}-sg"
  description = "Security group for Jenkins EC2 instance"
  vpc_id      = aws_vpc.aws_vpc_jenkins.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name = "${var.vpcname}-sg"
        environment = var.vpc_environment
    }
}