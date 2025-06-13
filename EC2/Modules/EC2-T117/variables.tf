variable "create_key" {
  description = "Boolean flag to create SSH key pair"
  type        = bool
  default     = false
  nullable    = true
  sensitive   = false
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair"
  type        = string
  nullable    = true
  sensitive   = false
}

variable "create_instance" {
  description = "Map of configurations for creating EC2 instances"
  type = map(object({
    ami                         = string
    instance_type               = optional(string)
    hibernation                 = optional(bool)
    user_data                   = optional(string)
    user_data_base64            = optional(string)
    user_data_replace_on_change = optional(bool)
    availability_zone           = optional(string)
    subnet_id                   = optional(string)
    vpc_security_group_ids      = optional(list(string))
    monitoring                  = optional(bool)
    get_password_data           = optional(bool)
    iam_instance_profile        = optional(string)
    associate_public_ip_address = optional(bool)
    private_ip                  = optional(string)
    secondary_private_ips       = optional(list(string))
    ipv6_address_count          = optional(number)
    ipv6_addresses              = optional(list(string))
    ebs_optimized               = optional(bool)

    capacity_reservation_specification = optional(list(object({
      capacity_reservation_preference = optional(string)
      capacity_reservation_target = optional(object({
        capacity_reservation_id                 = optional(string)
        capacity_reservation_resource_group_arn = optional(string)
      }))
    })), [])

    root_block_device = optional(list(object({
      delete_on_termination = optional(bool)
      encrypted             = optional(bool)
      iops                  = optional(number)
      kms_key_id            = optional(string)
      volume_size           = optional(number)
      volume_type           = optional(string)
      throughput            = optional(number)
      tags                  = optional(map(string))
    })), [])

    # ebs_block_device = optional(list(object({
    #   delete_on_termination = optional(bool)
    #   device_name           = optional(string)
    #   encrypted             = optional(bool)
    #   iops                  = optional(number)
    #   kms_key_id            = optional(string)
    #   snapshot_id           = optional(string)
    #   volume_size           = optional(number)
    #   volume_type           = optional(string)
    #   throughput            = optional(number)
    # })))

    ephemeral_block_device = optional(list(object({
      device_name  = optional(string)
      no_device    = optional(bool)
      virtual_name = optional(string)
    })), [])

    metadata_options = optional(list(object({
      http_endpoint               = optional(string)
      http_tokens                 = optional(string)
      http_put_response_hop_limit = optional(string)
      instance_metadata_tags      = optional(bool)
    })), [])

    network_interface = optional(list(object({
      device_index          = optional(number)
      network_interface_id  = optional(string)
      delete_on_termination = optional(bool)
    })), [])

    launch_template = optional(list(object({
      id      = optional(string)
      name    = optional(string)
      version = optional(string)
    })), [])

    enclave_options_enabled              = optional(bool)
    disable_api_termination              = optional(bool)
    disable_api_stop                     = optional(bool)
    instance_initiated_shutdown_behavior = optional(string)
    placement_group                      = optional(string)
    tenancy                              = optional(string)
    host_id                              = optional(string)
    cpu_credits                          = optional(string)
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))

    tags = optional(map(string))
  }))

  validation {
    condition     = length([for i in values(var.create_instance) : i.ami if substr(i.ami, 0, 4) != "ami-"]) == 0
    error_message = "The ami value must start with \"ami-\"."
  }
  nullable  = true
  sensitive = false
}

variable "create_ebs_volumes" {
  description = "Map of configurations for creating EBS volumes"
  type = map(object({
    availability_zone    = string
    encrypted            = optional(bool)
    final_snapshot       = optional(string)
    iops                 = optional(number)
    multi_attach_enabled = optional(bool)
    size                 = optional(number)
    snapshot_id          = optional(string)
    outpost_arn          = optional(string)
    type                 = optional(string)
    kms_key_id           = optional(string)
    throughput           = optional(number)
    tags                 = optional(map(string))
  }))
  default   = {}
  nullable  = true
  sensitive = false
}

variable "volume_attachments" {
  description = "Map of configurations for attaching EBS volumes to EC2 instances"
  type = map(object({
    device_name                    = string
    volume_key                     = string
    instance_key                   = string
    force_detach                   = optional(bool)
    skip_destroy                   = optional(bool)
    stop_instance_before_detaching = optional(bool)
  }))
  default   = {}
  nullable  = true
  sensitive = false
}

variable "Predefined_tags" {
  type = map(string)
  default = {
    CreatedBy      = "Terraform",
    "map-migrated" = "migPHEWKGG1FG"
  }
  nullable  = true
  sensitive = false
}
