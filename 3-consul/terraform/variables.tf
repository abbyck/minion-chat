variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "username" {
  description = "Your name"
}

variable "dockerhubhandle" {
  description = "Your docker hub handle"
}
