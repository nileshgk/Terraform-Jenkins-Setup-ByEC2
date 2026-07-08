variable "ami_id" {
    description = "AMI ID for the Jenkins EC2 instance"
    type        = string
    default     = "ami-002192a70217ac181" # Example AMI ID, replace with a valid one 
}

variable "instance_type" {
    description = "Instance type for the Jenkins EC2 instance"
    type        = string
    default     = "t2.micro"
}
variable "AWS_REGION" {
    description = "AWS region to deploy the resources"
    type        = string
    default     = "us-east-1"
}
