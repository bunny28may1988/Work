resource "aws_security_group" "main" {
  for_each = var.create_security_groups

  name_prefix            = try(each.value.name_prefix, null)
  name                   = try(each.value.name, null)
  description            = try(each.value.description, null)
  vpc_id                 = each.value.vpc_id
  revoke_rules_on_delete = try(each.value.revoke_rules_on_delete, null)
  tags                   = try(merge(var.Predefined_tags,each.value.tags), null)
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = var.ingress_rules

  security_group_id = aws_security_group.main[each.value.sg_key].id
  
  from_port        = try(each.value.from_port, null)
  ip_protocol      = try(each.value.ip_protocol, null)
  to_port          = try(each.value.to_port, null)
  description      = try(each.value.description, null)
  cidr_ipv4        = try(each.value.cidr_ipv4 != null ? each.value.cidr_ipv4 : null, null)
  cidr_ipv6        = try(each.value.cidr_ipv6 != null ? each.value.cidr_ipv6 : null, null)
  prefix_list_id   = try(each.value.prefix_list_id != null ? each.value.prefix_list_id : null, null)
  tags             = try(merge(var.Predefined_tags,each.value.tags), null)
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  for_each = var.egress_rules

  security_group_id = aws_security_group.main[each.value.sg_key].id

  from_port        = try(each.value.from_port, null)
  ip_protocol      = try(each.value.ip_protocol, null)
  to_port          = try(each.value.to_port, null)
  description      = try(each.value.description, null)
  cidr_ipv4        = try(each.value.cidr_ipv4 != null ? each.value.cidr_ipv4 : null, null)
  cidr_ipv6        = try(each.value.cidr_ipv6 != null ? each.value.cidr_ipv6 : null, null)
  prefix_list_id   = try(each.value.prefix_list_id != null ? each.value.prefix_list_id : null, null)
  tags             = try(merge(var.Predefined_tags,each.value.tags), null)
}