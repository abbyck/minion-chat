# Vault EC2 instance
resource "aws_instance" "vault" {
  ami           = var.ami_id    # Packer-generated Vault + Consul AMI
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    # Start Consul for Vault storage
    consul agent -dev -bind=0.0.0.0 -client=0.0.0.0 -data-dir=/tmp/consul &

    # Start Vault in dev mode (for demo)
    vault server -dev -dev-listen-address="0.0.0.0:8200" -dev-root-token-id="root" -dev-storage-backend="consul" &
  EOF

  vpc_security_group_ids = [aws_security_group.vault_consul_sg.id]
}
