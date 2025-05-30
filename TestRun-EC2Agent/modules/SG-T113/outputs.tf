output "sg_id" {
  value       = [for i in aws_security_group.main : i.id]
  description = "ID of the Security Group"
}

output "sg_arn" {
  value       = [for i in aws_security_group.main : i.arn]
  description = "ARN of the Security Group"
}

output "sg_ingress_arn" {
  value       = [for i in aws_vpc_security_group_ingress_rule.ingress : i.arn]
  description = "ARN of the Ingress Security Group Rule"
}

output "sg_egress_arn" {
  value       = [for i in aws_vpc_security_group_egress_rule.egress : i.arn]
  description = "ARN of the Egress Security Group Rule"
}
