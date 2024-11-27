output "vault_ui_url" {
  value = "http://${aws_instance.vault.public_ip}:8200"
}