#Add Consul UI URL
output "hello_service_url" {
  value = "http://${aws_instance.hello_service.public_ip}:5000/hello"
}

output "response_service_url" {
    value = <<CONFIGURATION
    http://${aws_instance.response_service[0].public_ip}:5001/response
    http://${aws_instance.response_service[1].public_ip}:5001/response
    CONFIGURATION

}

output "consul_ui_url" {
  value = "http://${aws_instance.consul.public_ip}:8500"
}

