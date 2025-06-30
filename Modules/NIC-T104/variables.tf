variable "network_interface" {
  description = "A map of network interface configurations"
  type = map(object({
    nic_subnet_id             = string
    private_ips               = optional(list(string))
    security_groups           = optional(list(string))
    source_dest_check_nic     = optional(bool)
    nic_description           = optional(string)
    interface_type            = optional(string)
    ipv4_prefix_count         = optional(number)
    ipv4_prefixes             = optional(list(string))
    ipv6_address_count        = optional(number)
    ipv6_address_list_enabled = optional(bool)
    ipv6_address_list         = optional(list(string))
    ipv6_addresses            = optional(list(string))
    ipv6_prefix_count         = optional(number)
    ipv6_prefixes             = optional(list(string))
    private_ip_list           = optional(list(string))
    private_ip_list_enabled   = optional(bool)
    private_ips_count         = optional(number)
    attachment = optional(map(object({
      instance     = string
      device_index = number
    })))
    tags                      = optional(map(string))
    domain                    = optional(string)
    instance                  = optional(string)
    network_interface         = optional(string)
    associate_with_private_ip = optional(bool)
    public_ipv4_pool          = optional(string)
    enable_elastic_ip         = optional(bool)
    instance_id               = optional(string)
    network_interface_id      = optional(string)
    allow_reassociation       = optional(bool)
    private_ip_address        = optional(string)
    public_ip                 = optional(string)
  }))

  validation {
    condition     = length([for i in values(var.network_interface) : i.nic_subnet_id if substr(i.nic_subnet_id, 0, 7) != "subnet-"]) == 0
    error_message = "The nic_subnet_id  value must start with \"subnet-\"."
  }
  nullable  = true
  sensitive = false
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

