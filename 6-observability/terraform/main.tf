#1.  Add a new EC2 instance for Consul.
#2.  Modify HelloService and ResponseService to include Consul configuration.

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID for Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_security_group" "sg" {
  name        = "minion-chat-sg"
}

# Add EC2 instance for Consul
resource "aws_instance" "consul" {
  instance_type = var.instance_type
  # Hard coding this since it is already hard code in 1-basic-setup
  key_name      = "minion-key"

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io unzip

    curl -O https://releases.hashicorp.com/consul/1.14.4/consul_1.14.4_linux_amd64.zip
    unzip consul_1.14.4_linux_amd64.zip
    mv consul /usr/local/bin/

    PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

    consul agent -dev -bind=0.0.0.0 -client=0.0.0.0 -advertise="$PRIVATE_IP" -ui -data-dir=/tmp/consul &
  EOF

  vpc_security_group_ids = [data.aws_security_group.sg.id]
  ami = data.aws_ami.ubuntu.id
}

# HelloService EC2 instance
resource "aws_instance" "hello_service" {
  depends_on = [aws_instance.response_service]
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = "minion-key"

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io

    systemctl start docker
    docker run -d -p 5000:5000 -e CONSUL_HTTP_ADDR=${aws_instance.consul.public_ip}:8500 ${var.dockerhub_id}/helloservice:latest

    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

    # Register the service with Consul
    curl -X PUT http://${aws_instance.consul.public_ip}:8500/v1/agent/service/register \
    -H "Content-Type: application/json" \
    -d '{
      "Name": "hello-service",
      "ID": "hello-service",
      "Address": "'$PUBLIC_IP'",
      "Port": 5000,
      "Meta": {
        "version": "1.0.0"
      },
      "EnableTagOverride": false,
      "Checks": [
        {
          "Name": "HTTP Health Check",
          "HTTP": "http://'$PUBLIC_IP':5000/hello",
          "Interval": "10s",
          "Timeout": "1s"
        }
      ]
    }'
  EOF

  vpc_security_group_ids = [data.aws_security_group.sg.id]
}

# Update ResponseService to register with Consul
resource "aws_instance" "response_service" {
  depends_on = [aws_instance.response_service]
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = "minion-key"
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io

    systemctl start docker
    docker run -d -p 5001:5001 -e CONSUL_HTTP_ADDR=${aws_instance.consul.public_ip}:8500 ${var.dockerhub_id}/responseservice:latest

    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

    # Register the service with Consul
    curl -X PUT http://${aws_instance.consul.public_ip}:8500/v1/agent/service/register \
    -H "Content-Type: application/json" \
    -d '{
      "Name": "response-service",
      "ID": "response-service",
      "Address": "'$PUBLIC_IP'",
      "Port": 5001,
      "Meta": {
        "version": "1.0.0"
      },
      "EnableTagOverride": false,
      "Checks": [
        {
          "Name": "HTTP Health Check",
          "HTTP": "http://'$PUBLIC_IP':5001/response",
          "Interval": "10s",
          "Timeout": "1s"
        }
      ]
    }'

  EOF
  vpc_security_group_ids = [data.aws_security_group.sg.id]
}