output "hello_service_url" {
  value = "http://${aws_instance.hello_service.public_ip}:5000/hello"
}

output "response_service_url" {
  value = "http://${aws_instance.response_service.public_ip}:5001/response"
}