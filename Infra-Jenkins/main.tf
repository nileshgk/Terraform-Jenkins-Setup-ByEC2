module "Dev_Jenkins" {
  source = "./Infra-Jenkins/Environment/Development"

provider "aws" {
    region = var.AWS_REGION
}

resource "aws_instance" "jenkins_ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = Environment.Development.public_subnet1_id.id
  security_groups = ["${Environment.Development.security_group_id.id}"]

  tags = {
    Name        = "${var.vpcname}-ec2"
    environment = var.vpc_environment
  }

user_data = file("Jenkins.sh")
}

resource "aws_key_pair" "jenkins_key_pair" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}
}

