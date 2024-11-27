# Consul EC2 instance
resource "aws_instance" "consul" {
  ami           = var.ami_id    # Packer-generated Docker + Consul AMI
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    consul agent -dev -bind=0.0.0.0 -client=0.0.0.0 -ui -data-dir=/tmp/consul &
  EOF

  vpc_security_group_ids = [aws_security_group.minion_chat_sg.id]
}

# HelloService EC2 instance
resource "aws_instance" "hello_service" {
  ami           = var.ami_id    # Packer-generated Docker + Consul AMI
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    docker run -d -p 5000:5000 \
      -e CONSUL_HTTP_ADDR=http://$(curl http://169.254.169.254/latest/meta-data/public-ipv4):8500 \
      your_dockerhub_username/helloservice:latest
  EOF

  vpc_security_group_ids = [aws_security_group.minion_chat_sg.id]
}

# ResponseService EC2 instance
resource "aws_instance" "response_service" {
  ami           = var.ami_id    # Packer-generated Docker + Consul AMI
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    docker run -d -p 5001:5001 \
      -e CONSUL_HTTP_ADDR=http://$(curl http://169.254.169.254/latest/meta-data/public-ipv4):8500 \
      your_dockerhub_username/responseservice:latest
  EOF

  vpc_security_group_ids = [aws_security_group.minion_chat_sg.id]
}