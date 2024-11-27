# Update Nomad and Consul instance
resource "aws_instance" "nomad_consul" {
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io unzip curl jq

    # Install Consul
    curl -O https://releases.hashicorp.com/consul/1.14.4/consul_1.14.4_linux_amd64.zip
    unzip consul_1.14.4_linux_amd64.zip
    mv consul /usr/local/bin/

    # Install Nomad
    curl -O https://releases.hashicorp.com/nomad/1.5.6/nomad_1.5.6_linux_amd64.zip
    unzip nomad_1.5.6_linux_amd64.zip
    mv nomad /usr/local/bin/

    consul agent -dev -bind=0.0.0.0 -client=0.0.0.0 -ui -data-dir=/tmp/consul &
    nomad agent -dev -bind=0.0.0.0 -data-dir=/tmp/nomad &
  EOF
}