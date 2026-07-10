# AWS VPC Resource for Jenkins EC2 instance
resource "aws_vpc" "jenkins_vpc" {
  cidr_block = var.cidr
  instance_tenancy = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6
  tags = {
    Name = "Jenkins-VPC"
    environment = var.vpc_environment   
  }
}

# AWS Internet Gateway for Jenkins VPC
resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id
  tags = {
    Name = "Jenkins-IGW"
    environment = var.vpc_environment
  }
}

# AWS Subnet for Jenkins VPC
resource "aws_subnet" "jenkins_pub_subnet1" {
  vpc_id = aws_vpc.jenkins_vpc.id
  cidr_block = var.cidr_pub_subnet1
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone1
  tags = {
    Name = "${var.vpcname}-pub-subnet1"
    environment = var.vpc_environment
  }
}
# AWS Subnet for Jenkins VPC
resource "aws_subnet" "jenkins_pub_subnet2" {
  vpc_id = aws_vpc.jenkins_vpc.id
  cidr_block = var.cidr_pub_subnet2
  availability_zone = var.availability_zone2
  tags = {
    Name = "${var.vpcname}-pub-subnet2"
    environment = var.vpc_environment
  }
}

# AWS Route Table for Jenkins VPC
resource "aws_route_table" "jenkins_pub_route_table" {
  vpc_id = aws_vpc.jenkins_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }
  tags = {
    Name = "${var.vpcname}-pub-route-table"
    environment = var.vpc_environment
  }
}
# AWS Route Table Association for Jenkins VPC
resource "aws_route_table_association" "jenkins_pub_route_table_assoc1" {
  subnet_id = aws_subnet.jenkins_pub_subnet1.id
  route_table_id = aws_route_table.jenkins_pub_route_table.id
}
# AWS Route Table Association for Jenkins VPC
resource "aws_route_table_association" "jenkins_pub_route_table_assoc2" {
  subnet_id = aws_subnet.jenkins_pub_subnet2.id
  route_table_id = aws_route_table.jenkins_pub_route_table.id
}
