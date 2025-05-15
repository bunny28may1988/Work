output "lb_arn" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.nlb.arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.nlb.dns_name
}