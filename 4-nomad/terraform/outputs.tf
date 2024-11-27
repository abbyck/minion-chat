output "nomad_ui_url" {
  value = "http://${aws_instance.nomad_consul.public_ip}:4646"
}