output "hello_service_cli" {
  value = "curl http://${aws_instance.hello_service.public_dns}:5000/hello | jq"
}

output "response_service_cli" {
  value = "curl http://${aws_instance.response_service.public_dns}:5001/response | jq"
}

output "ssh_hello_service" {
  value = "ssh -i minion-key.pem ubuntu@${aws_instance.hello_service.public_dns}"
}

output "ssh_response_service" {
  value = "ssh -i minion-key.pem ubuntu@${aws_instance.response_service.public_dns}"
}

output "hello_service_public_ip" {
  value = "${aws_instance.hello_service.public_ip}"
}

output "response_service_public_ip" {
  value = "${aws_instance.response_service.public_ip}"
}