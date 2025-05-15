module "jump_server_network_interface" {
  source = "../../../../../terraform-aws-modules-network-interface/modules"
  network_interface = {
    "${var.ec2_jump_server_name}_nic" = {
      nic_description       = "${var.ec2_jump_server_name}_nic"
      nic_subnet_id         = var.ec2_jump_server_subnet_id
      private_ips           = [var.ec2_jump_server_private_ip]
      security_groups       = [var.arcon_sg, var.jump_server_sg]
      source_dest_check_nic = false
      enable_elastic_ip     = false
      nic_tags = merge(local.default_tags, {
        Name = "${var.ec2_jump_server_name}_nic"
      })
    }
  }
}

module "ec2_jump_server" {
  source = "../../../../../terraform-aws-modules-ec2/modules"
  create_instance = {
    (var.ec2_jump_server_name) = {
      ami                  = var.ec2_jump_server_ami
      instance_type        = var.ec2_jump_server_instance_type
      availability_zone    = var.ec2_jump_server_az
      get_password_data    = false
      iam_instance_profile = var.ec2_iam_instance_profile
      user_data_base64     = base64encode(data.template_file.user_data.rendered)
      root_block_device = [
        {
          volume_size           = 50
          volume_type           = "gp3"
          delete_on_termination = true
          encrypted             = true
          kms_key_id            = var.ec2_kms_key_arn
          iops                  = 3000
          throughput            = 125
        }
      ]
      network_interface = [
        {
          device_index         = 0
          network_interface_id = module.jump_server_network_interface.nic_id["${var.ec2_jump_server_name}_nic"].id
        }
      ]
      metadata_options = [
        {
          http_tokens = "required"
        }
      ]
      ec2_tags = merge(local.default_tags, {
        Name = var.ec2_jump_server_name
      })
      volume_tags = merge(local.default_tags, {
        Name = "${var.ec2_jump_server_name}_volume"
      })
    }
  }
}