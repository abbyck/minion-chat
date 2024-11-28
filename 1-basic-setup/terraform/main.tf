provider "aws" {
  region = var.aws_region
}

# Security group for HTTP and SSH
resource "aws_security_group" "minion_chat_security_group" {
  name        = "minion_chat_sg"
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
  depends_on = [aws_instance.response_service]
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y docker.io
    sudo usermod -aG docker $USER

    sudo systemctl start docker
    sudo docker run -d -p 5000:5000 -e RESPONSE_SERVICE_HOST=${aws_instance.response_service.public_ip} your_dockerhub_username/helloservice:latest
  EOF

  vpc_security_group_ids = [aws_security_group.minion_chat_security_group.id]
}

# ResponseService EC2 instance
resource "aws_instance" "response_service" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io

    systemctl start docker
    sudo docker run -d -p 5001:5001 your_dockerhub_username/responseservice:latest
  EOF

  vpc_security_group_ids = [aws_security_group.minion_chat_security_group.id]
}