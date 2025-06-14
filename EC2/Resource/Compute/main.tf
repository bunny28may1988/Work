module "EC2_Agent" {
  source       = "../../Modules/EC2-T117"
  ssh_key_name = "ap-south-1"
  create_instance = {
    (var.EC2_name) = {
      ami                    = var.EC2_ami
      instance_type          = var.EC2_instance_type
      vpc_security_group_ids = var.EC2_security_group_ids
      subnet_id              = var.EC2_subnet_id
      iam_instance_profile   = var.EC2_instance_profile
      user_data              = file("${path.module}/user-data.sh")
      key_name               = "ap-south-1"
      root_block_device = [{
        delete_on_termination = true
        volume_size           = var.EC2_root_volume_size
        volume_type           = var.EC2_root_volume_type
        encrypted             = var.EC2_root_volume_encrypted
        kms_key_id            = var.EC2_root_volume_kms_key_id
        iops                  = var.EC2_root_volume_iops
        throughput            = var.EC2_root_volume_throughput
        tags = merge(local.default_tags, {
          Name   = "${var.EC2_name}_volume"
          Module = "ADO-Agent"
        })
      }]
      tags = merge(local.default_tags, {
        Name   = var.EC2_name
        Module = "ADO-Agent"
      })

    },
    (var.EC2_name) = {
      ami                    = var.EC2_ami
      instance_type          = var.EC2_instance_type
      vpc_security_group_ids = var.EC2_security_group_ids
      subnet_id              = var.EC2_subnet_id
      iam_instance_profile   = var.EC2_instance_profile
      key_name               = "ap-south-1"
      root_block_device = [{
        delete_on_termination = true
        volume_size           = var.EC2_root_volume_size
        volume_type           = var.EC2_root_volume_type
        encrypted             = var.EC2_root_volume_encrypted
        kms_key_id            = var.EC2_root_volume_kms_key_id
        iops                  = var.EC2_root_volume_iops
        throughput            = var.EC2_root_volume_throughput
        tags = merge(local.default_tags, {
          Name   = "${var.EC2_name}_volume"
          Module = "JumpServer"
        })
      }]
      tags = merge(local.default_tags, {
        Name   = var.EC2_name
        Module = "JumpServer"
      })

    }
  }
}