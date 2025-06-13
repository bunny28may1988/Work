##Key Pair 
resource "tls_private_key" "ssh_key" {
  count     = var.create_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  count      = var.create_key ? 1 : 0
  key_name   = var.ssh_key_name
  public_key = tls_private_key.ssh_key[0].public_key_openssh
}

##EC2 
resource "aws_instance" "instance" {
  for_each      = var.create_instance
  ami           = try(each.value["ami"], null)
  instance_type = try(each.value["instance_type"], null)
  #cpu_core_count       = try(each.value["cpu_core_count"], null)
  #cpu_threads_per_core = try(each.value["cpu_threads_per_core"], null)
  hibernation = try(each.value["hibernation"], null)

  user_data                   = try(each.value["user_data"], null)
  user_data_base64            = try(each.value["user_data_base64"], null)
  user_data_replace_on_change = try(each.value["user_data_replace_on_change"], null)

  availability_zone      = try(each.value["availability_zone"], null)
  subnet_id              = try(each.value["subnet_id"], null)
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
  ebs_optimized               = try(each.value["ebs_optimized"], null)

  dynamic "capacity_reservation_specification" {
  for_each = length(each.value["capacity_reservation_specification"]) > 0 ? each.value["capacity_reservation_specification"] : []

  content {
    capacity_reservation_preference = capacity_reservation_specification.value[0].capacity_reservation_preference

    dynamic "capacity_reservation_target" {
      for_each = capacity_reservation_specification.value[0].capacity_reservation_target != null ? [capacity_reservation_specification.value[0].capacity_reservation_target] : []
      content {
        capacity_reservation_id                 = capacity_reservation_target.value.capacity_reservation_id
        capacity_reservation_resource_group_arn = capacity_reservation_target.value.capacity_reservation_resource_group_arn
      }
    }
  }
}

  dynamic "root_block_device" {
    for_each = each.value.root_block_device != [] ? each.value.root_block_device : []

    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", false)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
      throughput            = lookup(root_block_device.value, "throughput", null)

      tags = merge(
        var.Predefined_tags != null ? var.Predefined_tags : {},
        lookup(root_block_device.value, "tags", {}),
      )
    }
  }

  ##### Used ebs block resource instead of "ebs_block_device" to avoid recreation ###

  # dynamic "ebs_block_device" {
  #   for_each = try(each.value.ebs_block_device, [])
  #   content {
  #     delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
  #     device_name           = ebs_block_device.value.device_name
  #     encrypted             = lookup(ebs_block_device.value, "encrypted", null)
  #     iops                  = lookup(ebs_block_device.value, "iops", null)
  #     kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
  #     snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
  #     volume_size           = lookup(ebs_block_device.value, "volume_size", null)
  #     volume_type           = lookup(ebs_block_device.value, "volume_type", null)
  #     throughput            = lookup(ebs_block_device.value, "throughput", null)
  #   }
  # }

  dynamic "ephemeral_block_device" {
    for_each = each.value.ephemeral_block_device != [] ? each.value.ephemeral_block_device : []
    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = lookup(ephemeral_block_device.value, "no_device", null)
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  dynamic "metadata_options" {
    for_each = each.value.metadata_options != [] ? each.value.metadata_options : []
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", "enabled")
      http_tokens                 = lookup(metadata_options.value, "http_tokens", "required")
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", "1")
      instance_metadata_tags      = lookup(metadata_options.value, "instance_metadata_tags", null)
    }
  }

  dynamic "network_interface" {
    for_each = each.value.network_interface != [] ? each.value.network_interface : []
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = network_interface.value.network_interface_id
      delete_on_termination = try(network_interface.value.delete_on_termination, false)
    }
  }

  dynamic "launch_template" {
    for_each = each.value.launch_template != [] ? each.value.launch_template : []
    content {
      id      = try(launch_template.value.id, null)
      name    = try(launch_template.value.name, null)
      version = try(launch_template.value.version, null)
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

  timeouts {
    create = try(each.value.timeouts.create, null)
    update = try(each.value.timeouts.update, null)
    delete = try(each.value.timeouts.delete, null)
  }



  tags = try(merge(var.Predefined_tags, each.value["tags"]), null)


  depends_on = [
    aws_key_pair.generated_key
  ]

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

 ##EBS Volume
resource "aws_ebs_volume" "main" {
  for_each = length(keys(var.create_ebs_volumes)) > 0 ? var.create_ebs_volumes : {}

  availability_zone    = try(each.value.availability_zone, null) # Required
  encrypted            = try(each.value.encrypted, null)
  final_snapshot       = try(each.value.final_snapshot, null)
  iops                 = try(each.value.iops, null)
  multi_attach_enabled = try(each.value.multi_attach_enabled, null)
  size                 = try(each.value.size, null)
  snapshot_id          = try(each.value.snapshot_id, null)
  outpost_arn          = try(each.value.outpost_arn, null)
  type                 = try(each.value.type, null)
  kms_key_id           = try(each.value.kms_key_id, null)
  throughput           = try(each.value.throughput, null)

  tags = merge(var.Predefined_tags,each.value.tags)
}

resource "aws_volume_attachment" "ebs_att" {
  for_each = var.volume_attachments

  device_name                    = each.value.device_name
  volume_id                      = aws_ebs_volume.main[each.value.volume_key].id
  instance_id                    = aws_instance.instance[each.value.instance_key].id
  force_detach                   = try(each.value.force_detach, null)
  skip_destroy                   = try(each.value.skip_destroy, null)
  stop_instance_before_detaching = try(each.value.stop_instance_before_detaching, null)
}