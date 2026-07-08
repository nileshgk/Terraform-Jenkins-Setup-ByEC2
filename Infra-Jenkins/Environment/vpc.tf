
resource "aws_vpc" "aws_vpc_jenkins" {
  cidr_block = var.cidr
  instance_tenancy = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = {
    Name = "${var.vpcname}-vpc"
    environment = var.vpc_environment   
  }

}

#AWS Internet Gateway
resource "aws_internet_gateway" "aws_igw_jenkins" {
    vpc_id = aws_vpc.aws_vpc_jenkins.id
    
    tags = {
        Name = "${var.vpcname}-igw"
        environment = var.vpc_environment
    }
}

# AWS subnet for Jenkins vpc
resource "aws_subnet" "aws_pub_subnet_jenkins1" {
  vpc_id = aws_vpc.aws_vpc_jenkins.id
  cidr_block = var.cidr_pub_subnet1
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone1

  tags = {
    Name = "${var.vpcname}-pub-subnet1"
    environment = var.vpc_environment
  }
}

#AWS subnet for Jenkins vpc
resource "aws_subnet" "aws_pub_subnet_jenkins2" {
  vpc_id = aws_vpc.aws_vpc_jenkins.id
  cidr_block = var.cidr_pub_subnet2
  availability_zone = var.availability_zone2

  tags = {
    Name = "${var.vpcname}-pub-subnet2"
    environment = var.vpc_environment
  }
}

# AWS route table for Jenkins vpc
resource "aws_route_table" "aws_pub_route_table_jenkins" {
  vpc_id = aws_vpc.aws_vpc_jenkins.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_igw_jenkins.id
  }
  tags = {
    Name = "${var.vpcname}-route-table"
    environment = var.vpc_environment
  }
}

# AWS route table association for Jenkins vpc
resource "aws_route_table_association" "aws_route_table_association_jenkins" {
  subnet_id = aws_subnet.aws_pub_subnet_jenkins1
  route_table_id = aws_route_table.aws_pub_route_table_jenkins.id
}
resource "aws_route_table_association" "aws_route_table_association_jenkins2" {
  subnet_id = aws_subnet.aws_pub_subnet_jenkins2
  route_table_id = aws_route_table.aws_pub_route_table_jenkins.id
}

