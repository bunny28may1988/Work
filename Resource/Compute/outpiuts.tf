output "instance_id" {
  description = "The ID of the created EC2 instance"
  value       = module.EC2_Agent.instance_id[0]
}
/*
output "private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = module.EC2_Agent.private_ip[var.EC2_name]
}
*/ #Commented as the source module does not provide this output
output "instance_arn" {
  description = "The ARN of the EC2 instance"
  value       = module.EC2_Agent.instance_arn[0]
}