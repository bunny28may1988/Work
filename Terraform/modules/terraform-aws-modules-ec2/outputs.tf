############### EC2 ##############

output "instance_id" {
  value = aws_instance.instance
}

output "private_key" {
  value     = tls_private_key.ssh_key[*]
  sensitive = true
}
