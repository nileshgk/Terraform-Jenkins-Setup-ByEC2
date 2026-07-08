module "Dev_Jenkins" {
  source = "/../.."

  vpcname = "Dev_Jenkins"
  cidr = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_ipv6 = true
  vpc_environment = "Development"
  AWS_REGION = "us-east-1"
  cidr_pub_subnet1 = "10.0.0.0/24"
  cidr_pub_subnet2 = "10.0.1.0/24"
  availability_zone1 = "us-east-1a"
  availability_zone2 = "us-east-1b"
  public_key_path      = "C:/Users/Nilesh/.ssh/Jenkins.pub"
}