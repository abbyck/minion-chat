# Combined Nomad + Consul EC2 instance
resource "aws_instance" "nomad_consul" {
  ami           = var.ami_id    # Packer-generated Docker + Consul + Nomad AMI
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    # Start Consul and Nomad
    consul agent -dev -bind=0.0.0.0 -client=0.0.0.0 -ui -data-dir=/tmp/consul &
    nomad agent -dev -bind=0.0.0.0 -data-dir=/tmp/nomad &
  EOF

  vpc_security_group_ids = [aws_security_group.nomad_consul_sg.id]
}