############### Endpoint service  #############

variable "create_endpoint_service" {
  type = map(object({
    acceptance_required        = bool
    allowed_principals         = optional(string)
    gateway_load_balancer_arns = optional(list(string))
    network_load_balancer_arns = optional(list(string))
    supported_ip_address_types = optional(list(string))
    private_dns_name           = optional(string)
    tags                       = optional(map(string))

    enable_notification     = optional(bool)
    vpc_endpoint_service_id = optional(bool)
    sns_arn                 = optional(string)
    connection_events       = optional(list(string))

  }))
  description = "map of endpoint service"
  nullable    = true
  sensitive   = false

  default = {}

}



############## VPC Endpoint ###########

variable "create_endpoint" {
  description = "map of VPC endpoints."
  type = map(object({
    vpc_id              = string
    service_key         = optional(string)
    service_name        = optional(string)
    auto_accept         = optional(bool)
    policy              = optional(string)
    private_dns_enabled = optional(bool, false)
    ip_address_type     = optional(string)
    route_table_ids     = optional(list(string))
    subnet_ids          = optional(list(string))
    security_group_ids  = optional(list(string))
    vpc_endpoint_type   = optional(string , "Gateway")
    tags                =  optional(map(string))

    enable_notification     = optional(bool)
    vpc_endpoint_service_id = optional(bool)
    sns_arn                 = optional(string)
    connection_events       = optional(list(string))

  }))

  nullable  = true
  sensitive = false

  validation {
    condition = can(index(keys(var.create_endpoint), "sns_arn")) ? all([for sns in values(var.create_endpoint) : can(index(keys(sns), "sns_arn")) ? (sns.sns_arn == null || substr(sns.sns_arn, 0, 11) == "arn:aws:sns") : true]) : true
    error_message = "If provided, sns_arn must start with \"arn:aws:sns\"."
  }

  validation {
    condition     = length([for vpc_endpoint_type in values(var.create_endpoint)[*].vpc_endpoint_type : vpc_endpoint_type if !contains(["Gateway", "GatewayLoadBalancer",  "Interface"], vpc_endpoint_type)]) <= 0
    error_message = "Gateway, GatewayLoadBalancer, or Interface are allowed values for vpc_endpoint_type."
  }

  default = {}

}

variable "Predefined_tags" {
  type = map(string)
  default = {
    CreatedBy = "Terraform",
    "map-migrated" = "migPHEWKGG1FG"
  }
  nullable  = true
  sensitive = false
}
