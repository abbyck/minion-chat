#Add Consul UI URL

output "consul_ui_url" {
  value = "http://${aws_instance.consul.public_ip}:8500"
}

