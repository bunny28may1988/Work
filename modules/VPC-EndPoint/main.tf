##### VPC endpoint service #######

resource "aws_vpc_endpoint_service" "endpoint_service" {
  for_each                  = var.create_endpoint_service != {} ? var.create_endpoint_service : {}
  acceptance_required       = try(each.value["acceptance_required"], null)
  gateway_load_balancer_arns = try(each.value["gateway_load_balancer_arns"], null)
  network_load_balancer_arns = try(each.value["network_load_balancer_arns"], null)
  supported_ip_address_types = try(each.value["supported_ip_address_types"], null)
  private_dns_name           = try(each.value["private_dns_name"], null)
  tags                       = try(merge(var.Predefined_tags,each.value["tags"]), null)
}

 
############## VPC Endpoint ###########

resource "aws_vpc_endpoint" "vpc_endpoint" {
  for_each = var.create_endpoint
  vpc_id              = each.value["vpc_id"]
  service_name        = try(aws_vpc_endpoint_service.endpoint_service[each.value.service_key].service_name, each.value.service_name, null) 
  auto_accept         = try(each.value["auto_accept"], null)
  policy              = try(each.value["policy"], null)
  ip_address_type     = try(each.value["ip_address_type"], null)
  private_dns_enabled = try(each.value["private_dns_enabled"], null)
  route_table_ids     = try(each.value["route_table_ids"], null)
  subnet_ids          = try(each.value["subnet_ids"], null)
  security_group_ids  = try(each.value["security_group_ids"], null)
  vpc_endpoint_type   = try(each.value["vpc_endpoint_type"], null)  # (Optional) The VPC endpoint type, Gateway, GatewayLoadBalancer, or Interface. Defaults to Gateway.
  tags                = try(merge(var.Predefined_tags,each.value["tags"]), null)

  depends_on = [aws_vpc_endpoint_service.endpoint_service]
}

######### Notification ##############
resource "aws_vpc_endpoint_connection_notification" "this" {
  for_each = { 
    for key, value in var.create_endpoint_service : 
    key => value if coalesce(value.enable_notification, false) 
    }
  
  vpc_endpoint_service_id = try(aws_vpc_endpoint_service.endpoint_service[each.key].id, null)

  connection_notification_arn = try(each.value.sns_arn, null)
  connection_events           = try(each.value.connection_events, null)#["Accept", "Reject", "Delete", "Connect"]
}  

resource "aws_vpc_endpoint_connection_notification" "this1" {

  for_each = { 
    for key, value in var.create_endpoint : 
    key => value if coalesce(value.enable_notification, false) 
    }

  vpc_endpoint_id = try(aws_vpc_endpoint.vpc_endpoint[each.key].id, null)

  connection_notification_arn = try(each.value.sns_arn, null)
  connection_events           = try(each.value.connection_events, null)#["Accept", "Reject", "Delete", "Connect"]
}