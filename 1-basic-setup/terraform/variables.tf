variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for EC2"
  default     = "ami-0c02fb55956c7d316" # Replace with valid Ubuntu AMI
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair for SSH access"
}

variable "username" {
  description = "Your name"
}