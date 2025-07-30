##EIP 

resource "aws_network_interface" "network_card" {

  for_each                  = var.network_interface
  subnet_id                 = each.value.nic_subnet_id
  private_ips               = try(each.value.private_ips, [])
  security_groups           = try(each.value.security_groups, null)
  source_dest_check         = try(each.value.source_dest_check_nic, null)
  description               = try(each.value.nic_description, null)
  interface_type            = try(each.value.interface_type, null)
  ipv4_prefix_count         = try(each.value.ipv4_prefix_count, null)
  ipv4_prefixes             = try(each.value.ipv4_prefixes, null)
  ipv6_address_count        = try(each.value.ipv6_address_count, null)
  ipv6_address_list_enabled = try(each.value.ipv6_address_list_enabled, null)
  ipv6_address_list         = try(each.value.ipv6_address_list, null)
  ipv6_addresses            = try(each.value.ipv6_addresses, null)
  ipv6_prefix_count         = try(each.value.ipv6_prefix_count, null)
  ipv6_prefixes             = try(each.value.ipv6_prefixes, null)
  private_ip_list           = try(each.value.private_ip_list, null)
  private_ip_list_enabled   = try(each.value.private_ip_list_enabled, null)
  private_ips_count         = try(each.value.private_ips_count, null)
  dynamic "attachment" {
   for_each =  try(each.value.attachment != null && each.value.attachment.instance != null && each.value.attachment.device_index != null ? [each.value.attachment] : [], [])
    content {
      instance     = try(attachment.value.instance, null)
      device_index = try(attachment.value.device_index, null)
    }
  }
  tags =try( merge(var.Predefined_tags, each.value.tags), null)

}

resource "aws_eip" "eip" {

  for_each = { for k, v in var.network_interface : k => v if v.enable_elastic_ip == true }

  domain                    = "vpc"
  instance                  = try(each.value.instance, null)
  network_interface         = try(aws_network_interface.network_card[each.key].id, each.value.network_interface)
  associate_with_private_ip = try(each.value.associate_with_private_ip, null)
  public_ipv4_pool          = try(each.value.public_ipv4_pool, null)
  tags                      = try(merge(var.Predefined_tags, each.value.tags), null)


}

resource "aws_eip_association" "eip-association" {

  for_each = { for k, v in var.network_interface : k => v if v.enable_elastic_ip == true }

  allocation_id        = try(aws_eip.eip[each.key].id, each.value.allocation_id)
  instance_id          = try(each.value.instance_id, null)
  network_interface_id = try(aws_network_interface.network_card[each.key].id, each.value.network_interface_id)
  allow_reassociation  = try(each.value.allow_reassociation, null)
  private_ip_address   = try(each.value.private_ip_address, null)
  public_ip            = try(each.value.public_ip, null)
  depends_on = [
    aws_network_interface.network_card,
    aws_eip.eip
  ]

}