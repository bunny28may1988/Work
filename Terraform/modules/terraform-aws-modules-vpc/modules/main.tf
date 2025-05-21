resource "aws_vpc" "main" {
  for_each                             = var.create_vpc
  cidr_block                           = each.value["cidr_block"]
  instance_tenancy                     = try(each.value["instance_tenancy"], null)
  ipv4_ipam_pool_id                    = try(each.value["ipv4_ipam_pool_id"], null)
  ipv4_netmask_length                  = try(each.value["ipv4_netmask_length"], null)
  ipv6_cidr_block                      = try(each.value["ipv6_cidr_block"], null)
  ipv6_ipam_pool_id                    = try(each.value["ipv6_ipam_pool_id"], null)
  ipv6_netmask_length                  = try(each.value["ipv6_netmask_length"], null)
  ipv6_cidr_block_network_border_group = try(each.value["ipv6_cidr_block_network_border_group"], null)
  enable_dns_support                   = try(each.value["enable_dns_support"], null)
  enable_dns_hostnames                 = try(each.value["enable_dns_hostnames"], null)
  assign_generated_ipv6_cidr_block     = try(each.value["assign_generated_ipv6_cidr_block"], null)
  tags                                 = try(each.value["tags"], null)
}

resource "aws_internet_gateway" "igw" {
  for_each = var.internet_gateway ? var.create_vpc : {}
  vpc_id   = aws_vpc.main[each.key].id

  tags = var.igw_tags
  depends_on = [
    aws_vpc.main
  ]
}
