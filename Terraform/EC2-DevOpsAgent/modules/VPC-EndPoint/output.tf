output "vpc_endpoint_id" {
  description = "ID of the VPC Endpoint"
  value = [for i in aws_vpc_endpoint.vpc_endpoint : i.id]
}

output "vpc_endpoint_arn" {
  description = "ARN of the VPC Endpoint"
  value = [for i in aws_vpc_endpoint.vpc_endpoint : i.arn]
}

output "endpoint_service_id" {
  description = "ID of the Endpoint Service"
  value = [for i in aws_vpc_endpoint_service.endpoint_service : i.id]
}

output "endpoint_service_arn" {
  description = "ARN of the Endpoint Service"
  value = [for i in aws_vpc_endpoint_service.endpoint_service : i.arn]
}

output "endpoint_notification_id" {
  description = "ID of the VPC Endpoint Connection Notification"
  value = [for i in aws_vpc_endpoint_connection_notification.this : i.id]
}
