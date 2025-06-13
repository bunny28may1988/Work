##Outputs

output "instance_id" {
  description = "EC2 instance IDs"
  value       = [for i in aws_instance.instance : i.id]
}

output "instance_arn" {
  description = "EC2 instance ARNs"
  value       = [for i in aws_instance.instance : i.arn]
}

output "instance_public_ip" {
  description = "public IPs of EC2 instances"
  value       = [for i in aws_instance.instance : i.public_ip]
}

output "aws_ebs_volume_id" {
  description = "EBS volume IDs"
  value       = [for i in aws_ebs_volume.main : i.id]
}

output "aws_ebs_volume_arn" {
  description = "EBS volume ARNs"
  value       = [for i in aws_ebs_volume.main : i.arn]
}

output "aws_volume_attachment_id" {
  description = "IDs of attached EBS volumes"
  value       = [for i in aws_volume_attachment.ebs_att : i.volume_id]
}

output "aws_key_pair_id" {
  description = "	IDs of generated key pairs"
  value       = [for i in aws_key_pair.generated_key : i.key_pair_id]
}

output "aws_key_pair_arn" {
  description = "ARNs of generated key pairs"
  value       = [for i in aws_key_pair.generated_key : i.arn]
}

output "aws_key_pair_type" {
  description = "types of generated key pairs"
  value       = [for i in aws_key_pair.generated_key : i.key_type]
}