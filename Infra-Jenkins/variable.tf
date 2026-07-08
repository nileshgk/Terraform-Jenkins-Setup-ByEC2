variable "ami_id" {
    description = "AMI ID for the Jenkins EC2 instance"
    type        = string
    default     = "ami-08f44e8eca9095668" # Example AMI ID, replace with a valid one 
}

variable "instance_type" {
    description = "Instance type for the Jenkins EC2 instance"
    type        = string
    default     = "t2.micro"
}

