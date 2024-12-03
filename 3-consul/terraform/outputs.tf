#Add Consul UI URL
output "hello_service_url" {
  value = "http://${aws_instance.hello_service.public_ip}:5000/hello"
}

output "response_service_url" {
  value = "http://${aws_instance.response_service.public_ip}:5001/response"
}

output "consul_ui_url" {
  value = "http://${aws_instance.consul.public_ip}:8500"
}

