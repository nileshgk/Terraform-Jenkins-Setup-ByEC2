variable "AWS_ACCESS_KEY" {
    type        = string
    description = "AWS Access Key"
    default     = "" 
}
variable "AWS_SECRET_KEY" {
    type        = string
    description = "AWS Secret Key" 
    default     = ""
}
variable "AWS_REGION" {
    type        = string
    description = "AWS Region"
    default     = "us-east-1"
}
variable "vpcname" {
    description = "Name to be used on all the resource as identifier"
    type        = string
    default     = ""
}
variable "cidr" {
  description = "The CIDR block for the vpc"
  type = string
  default = "0.0.0.0/0"
}
variable "instance_tenancy" {
  description = "The instance tenancy attribute for the vpc"
  type = string
  default = "default"
}
variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  type = bool
  default = false
  
}
variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC"
  type = bool
  default = false
}
variable "enable_ipv6" {
    description = "A boolean flag to enable/disable IPv6 support for the VPC"
    type = bool
    default = false
}
variable "vpc_environment" {
    description = "The environment for the resources"
    type        = string
    default     = "Development"
  
}
variable "cidr_pub_subnet1" {
    description = "The CIDR block for the public subnet"
    type        = string
    default     = "10.0.0.0/24"
  
}
variable "cidr_pub_subnet2" {
    description = "The CIDR block for the second public subnet"
    type        = string
    default     = "10.0.1.0/24"
}
variable "availability_zone1" {
    description = "The availability zone for the first subnet"
    type        = string
    default     = "us-east-1a"
}
variable "availability_zone2" {
    description = "The availability zone for the second subnet"
    type        = string
    default     = "us-east-1b"
}
variable "public_key_path" {
    description = "Path to the public key file for SSH access"
    type        = string
    default     = "~/.ssh/Jenkins.pub"
}