variable "create_security_groups" {
  type = map(object({
    name                   = optional(string)
    name_prefix            = optional(string)
    description            = optional(string)
    vpc_id                 = optional(string)
    revoke_rules_on_delete = optional(bool)
    tags                   = optional(map(string))
  }))

  description = "map of security group"
  nullable    = true
  sensitive   = false


    validation {
    condition     = length([for subnet in values(var.create_security_groups) : subnet.vpc_id if substr(subnet.vpc_id, 0, 4) != "vpc-"]) == 0
    error_message = "The vpc_id value must start with \"vpc-\"."
  }
}

variable "ingress_rules" {
  type = map(object({
    sg_key         = string
    from_port      = optional(number)
    to_port        = optional(number)
    ip_protocol    = string
    cidr_ipv4      = optional(string)
    cidr_ipv6      = optional(string)
    description    = optional(string)
    prefix_list_id = optional(string)
    tags           = optional(map(string))

  }))
  description = "map of ingress rule"
  nullable    = true
  sensitive   = false

  validation {
    condition     = length([for cidr in values(var.ingress_rules) : cidr.cidr_ipv4 if !can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\/\\d{1,2}$", cidr.cidr_ipv4))]) <= 0
    error_message = "The cidr_ipv4 value must be in valid CIDR notation for ingress rule."
  }
}

variable "egress_rules" {
  type = map(object({
    sg_key         = string
    from_port      = optional(number)
    to_port        = optional(number)
    ip_protocol    = string
    cidr_ipv4      = optional(string)
    cidr_ipv6      = optional(string)
    description    = optional(string)
    prefix_list_id = optional(string)
    tags           = optional(map(string))

  }))
  description = "map of egress rule"
  nullable    = true
  sensitive   = false

   validation {
    condition     = length([for cidr in values(var.egress_rules) : cidr.cidr_ipv4 if !can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\/\\d{1,2}$", cidr.cidr_ipv4))]) <= 0
    error_message = "The cidr_ipv4 value must be in valid CIDR notation for egress rule."
  }
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
 
