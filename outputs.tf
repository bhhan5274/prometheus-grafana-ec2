output "monitoring_instance_ip" {
  value = aws_eip.monitoring_instance_eip.public_ip
}
