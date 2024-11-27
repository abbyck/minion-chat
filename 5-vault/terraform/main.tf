# Add EC2 instance for Vault
resource "aws_instance" "vault" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io unzip curl jq

    # Install Consul (for Vault storage backend)
    curl -O https://releases.hashicorp.com/consul/1.14.4/consul_1.14.4_linux_amd64.zip
    unzip consul_1.14.4_linux_amd64.zip
    mv consul /usr/local/bin/

    # Install Vault
    curl -O https://releases.hashicorp.com/vault/1.14.1/vault_1.14.1_linux_amd64.zip
    unzip vault_1.14.1_linux_amd64.zip
    mv vault /usr/local/bin/

    # Configure Consul for Vault storage
    consul agent -dev -bind=0.0.0.0 -client=0.0.0.0 -data-dir=/tmp/consul &

    # Start Vault in dev mode (for demo)
    vault server -dev -dev-listen-address="0.0.0.0:8200" -dev-root-token-id="root" -dev-storage-backend="consul" &
  EOF

  vpc_security_group_ids = [aws_security_group.minion_chat_sg.id]
}

