provider "aws" {
  region = var.aws_region
}

# Security group for HTTP and SSH
resource "aws_security_group" "minion_chat_sg" {
  name        = "minion-chat-sg"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# HelloService EC2 instance
resource "aws_instance" "hello_service" {
  ami           = var.ami_id    # Use Packer-generated AMI
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    docker run -d -p 5000:5000 your_dockerhub_username/helloservice:latest
  EOF

  vpc_security_group_ids = [aws_security_group.minion_chat_sg.id]
}

# ResponseService EC2 instance
resource "aws_instance" "response_service" {
  ami           = var.ami_id    # Use Packer-generated AMI
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    docker run -d -p 5001:5001 your_dockerhub_username/responseservice:latest
  EOF

  vpc_security_group_ids = [aws_security_group.minion_chat_sg.id]
}