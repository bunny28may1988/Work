variable "create_vpc" {
  type = map(object({
    cidr_block                           = string
    instance_tenancy                     = string
    ipv4_ipam_pool_id                    = string
    ipv4_netmask_length                  = number
    ipv6_cidr_block                      = string
    ipv6_ipam_pool_id                    = string
    ipv6_netmask_length                  = number
    ipv6_cidr_block_network_border_group = string
    enable_dns_support                   = bool
    assign_generated_ipv6_cidr_block     = bool
    tags                                 = map(string)
  }))
  description = "create vpc"

  default = {
    default_vpc = {
      cidr_block                           = "10.0.0.0/16"
      instance_tenancy                     = "default"
      ipv4_ipam_pool_id                    = null
      ipv4_netmask_length                  = 24
      ipv6_cidr_block                      = null
      ipv6_ipam_pool_id                    = null
      ipv6_netmask_length                  = 64
      ipv6_cidr_block_network_border_group = null
      enable_dns_support                   = null
      assign_generated_ipv6_cidr_block     = null
      tags = {
        "CreatedBy" = "default value by Terraform"
      }
    }
  }
}
variable "internet_gateway" {
  default     = false
  type        = bool
  description = "Creation of internet gateway: Accepted values- true/false"
}

variable "igw_tags" {
  type = map
  description = "Internet gateway tags"
  default = {
      "CreatedBy" = "default value by Terraform"
  }
}
