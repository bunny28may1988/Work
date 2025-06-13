#########################
# VPC Outputs
#########################
output "vpc_id" {
  value = aws_vpc.ADO-Agent_VPC.id
}

output "vpc_cidr_block" {
  value = aws_vpc.ADO-Agent_VPC.cidr_block
}

output "vpc_arn" {
  value = aws_vpc.ADO-Agent_VPC.arn
}

output "vpc_main_route_table_id" {
  value = aws_vpc.ADO-Agent_VPC.main_route_table_id
}

#########################
# Subnets Outputs
#########################
output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "public_subnet_cidrs" {
  value = [for s in aws_subnet.public : s.cidr_block]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "private_subnet_cidrs" {
  value = [for s in aws_subnet.private : s.cidr_block]
}

#########################
# NAT Gateway Outputs
#########################
output "nat_eip_id" {
  value = aws_eip.nat_eip.id
}

output "nat_eip_public_ip" {
  value = aws_eip.nat_eip.public_ip
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}

output "nat_gateway_subnet_id" {
  value = aws_nat_gateway.nat.subnet_id
}


output "nat_gateway_all_attributes" {
  value = aws_nat_gateway.nat
}

#########################
# Internet Gateway Outputs
#########################
output "internet_gateway_id" {
  value = aws_internet_gateway.ADO-Agent_IGW.id
}

output "internet_gateway_vpc_id" {
  value = aws_internet_gateway.ADO-Agent_IGW.vpc_id
}

output "internet_gateway_arn" {
  value = aws_internet_gateway.ADO-Agent_IGW.arn
}
#########################
# Route Table Outputs
#########################
output "public_route_table_id" {
  value = aws_route_table.main["public"].id
}

output "public_route_table_associations" {
  value = [for assoc in aws_route_table_association.public_subnets : assoc.id]
}

output "public_route_table_arn" {
  value = aws_route_table.main["public"].arn
}

output "private_route_table_id" {
  value = aws_route_table.main["private"].id
}

output "private_route_table_routes" {
  value = aws_route_table.main["private"].route
}

output "private_route_table_associations" {
  value = [for assoc in aws_route_table_association.private_subnets : assoc.id]
}

output "private_route_table_arn" {
  value = aws_route_table.main["private"].arn
}

#########################
# S3 VPC Endpoint Outputs
#########################
output "s3_gateway_endpoint_id" {
  value = aws_vpc_endpoint.ADO-Agent_s3-gateway.id
}

output "s3_gateway_endpoint_prefix_list_id" {
  value = aws_vpc_endpoint.ADO-Agent_s3-gateway.prefix_list_id
}

output "s3_gateway_endpoint_dns_entries" {
  value = aws_vpc_endpoint.ADO-Agent_s3-gateway.dns_entry
}

output "s3_gateway_endpoint_route_table_ids" {
  value = aws_vpc_endpoint.ADO-Agent_s3-gateway.route_table_ids
}

#########################
# Security Groups Outputs
#########################

output "all_security_group_ids" {
  value = module.security_groups.security_group_ids
}