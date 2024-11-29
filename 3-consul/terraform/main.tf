#1.  Add a new EC2 instance for Consul.
#2.  Modify HelloService and ResponseService to include Consul configuration.

# Add EC2 instance for Consul
resource "aws_instance" "consul" {
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io unzip

    curl -O https://releases.hashicorp.com/consul/1.14.4/consul_1.14.4_linux_amd64.zip
    unzip consul_1.14.4_linux_amd64.zip
    mv consul /usr/local/bin/

    consul agent -dev -bind=0.0.0.0 -client=0.0.0.0 -ui -data-dir=/tmp/consul &
  EOF

  vpc_security_group_ids = [aws_security_group.minion_chat_sg.id]
}

# Update HelloService to register with Consul
resource "aws_instance" "hello_service" {
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io

    systemctl start docker
    docker run -d -p 5000:5000 \
      -e CONSUL_HTTP_ADDR=http://$(curl http://169.254.169.254/latest/meta-data/public-ipv4):8500 \
      your_dockerhub_username/helloservice:latest
  EOF
}

# Update ResponseService to register with Consul
resource "aws_instance" "response_service" {
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io

    systemctl start docker
    docker run -d -p 5001:5001 \
      -e CONSUL_HTTP_ADDR=http://$(curl http://169.254.169.254/latest/meta-data/public-ipv4):8500 \
      your_dockerhub_username/responseservice:latest
  EOF
}