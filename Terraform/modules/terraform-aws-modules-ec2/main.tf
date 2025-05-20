########################## Key Pair #######################

resource "tls_private_key" "ssh_key" {
  count = var.create_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  count = var.create_key ? 1 : 0
  key_name   = var.ssh_key_name
  public_key = tls_private_key.ssh_key[0].public_key_openssh
}

########################  EC2  ###########################

resource "aws_instance" "instance" {
  for_each  = var.create_instance
  ami                  = try(each.value["ami"], null)
  instance_type        = try(each.value["instance_type"], null)
  cpu_core_count       = try(each.value["cpu_core_count"], null)
  cpu_threads_per_core = try(each.value["cpu_threads_per_core"], null)
  hibernation          = try(each.value["hibernation"], null)

  user_data                   = try(each.value["user_data"], null)
  user_data_base64            = try(each.value["user_data_base64"], null)
  user_data_replace_on_change = try(each.value["user_data_replace_on_change"], null)

  availability_zone      = try(each.value["availability_zone"], null)
  subnet_id = try(each.value["subnet_id"], null)
  vpc_security_group_ids = try(each.value["vpc_security_group_ids"], null)

  key_name             = var.ssh_key_name
  monitoring           = try(each.value["monitoring"], null)
  get_password_data    = try(each.value["get_password_data"], null)
  iam_instance_profile = try(each.value["iam_instance_profile"], null)

  associate_public_ip_address = try(each.value["associate_public_ip_address"], null)
  private_ip                  = try(each.value["private_ip"], null)
  secondary_private_ips       = try(each.value["secondary_private_ips"], null)
  ipv6_address_count          = try(each.value["ipv6_address_count"], null)
  ipv6_addresses              = try(each.value["ipv6_addresses"], null)
  ebs_optimized = try(each.value["ebs_optimized"], null)

  dynamic "capacity_reservation_specification" {
    for_each = lookup(each.value, "capacity_reservation_specification", {})
    content {
      capacity_reservation_preference = try(capacity_reservation_specification.value.capacity_reservation_preference, null)

      dynamic "capacity_reservation_target" {
        for_each = try([capacity_reservation_specification.value.capacity_reservation_target], [])
        content {
          capacity_reservation_id                 = try(capacity_reservation_target.value.capacity_reservation_id, null)
          capacity_reservation_resource_group_arn = try(capacity_reservation_target.value.capacity_reservation_resource_group_arn, null)
        }
      }
    }
  }

  dynamic "root_block_device" {
    for_each = lookup(each.value, "root_block_device", {})
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", false)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
      throughput            = lookup(root_block_device.value, "throughput", null)
      tags                  = lookup(root_block_device.value, "tags", null)
    }
  }

  dynamic "ebs_block_device" {
    for_each = lookup(each.value, "ebs_block_device", {})
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = lookup(each.value, "ephemeral_block_device", {})
    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = lookup(ephemeral_block_device.value, "no_device", null)
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  dynamic "metadata_options" {
    for_each = lookup(each.value, "metadata_options", {})
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", "enabled")
      http_tokens                 = lookup(metadata_options.value, "http_tokens", "optional")
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", "1")
      instance_metadata_tags      = lookup(metadata_options.value, "instance_metadata_tags", null)
    }
  }

 dynamic "network_interface" {
    for_each = lookup(each.value, "network_interface", {})
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = network_interface.value.network_interface_id
      delete_on_termination = try(network_interface.value.delete_on_termination, false)
    }
  }

  dynamic "launch_template" {
    for_each = lookup(each.value, "launch_template", {})
    content {
      id      = lookup(var.launch_template, "id", null)
      name    = lookup(var.launch_template, "name", null)
      version = lookup(var.launch_template, "version", null)
    }
  }

  enclave_options {
    enabled = try(each.value["enclave_options_enabled"], null)
  }

 
  disable_api_termination              = try(each.value["disable_api_termination"], null)
  disable_api_stop                     = try(each.value["disable_api_stop"], null)
  instance_initiated_shutdown_behavior = try(each.value["instance_initiated_shutdown_behavior"], null)
  placement_group                      = try(each.value["placement_group"], null)
  tenancy                              = try(each.value["tenancy"], null)
  host_id                              = try(each.value["host_id"], null)

  credit_specification {
    cpu_credits = try(each.value.cpu_credits, null)
  }

  dynamic "timeouts" {
    for_each = lookup(each.value, "launch_template", {})
    content {
    create = lookup(timeouts.value, "create", null)
    update = lookup(timeouts.value, "update", null)
    delete = lookup(timeouts.value, "delete", null)
    }
  }

  tags        =  try(each.value["ec2_tags"], null)
  volume_tags =  try(each.value["volume_tags"], null)

  depends_on = [ 
    aws_key_pair.generated_key
   ]

   lifecycle {
    ignore_changes = [
      user_data,
    ]
   }
}
