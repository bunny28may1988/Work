module "EC2_Agent" {
  source       = "../../Modules/EC2-T117"
  ssh_key_name = null
  create_instance = {
    (var.EC2_name) = {
      ami                  = var.EC2_ami
      instance_type        = var.EC2_instance_type
      iam_instance_profile = var.EC2_instance_profile
      user_data_base64     = base64encode(file("${path.module}/user-data.sh"))
      network_interface = [{
        device_index         = 0
        network_interface_id = module.ADO_BuildAgent_NIC.NIC_ID[0]
      }]
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

    }
  }
}
module "ADO_BuildAgent_NIC" {
  source                = "./NIC"
  EC2_Agent_NIC_Name    = var.ADO_BuildAgent_NIC_Name
  EC2_Agent_NIC_Subnet  = var.ADO_BuildAgent_NIC_Subnet
  EC2_Agent_Private_ips = var.ADO_BuildAgent_Private_ips
  EC2_Agent_NIC_SG      = var.ADO_BuildAgent_NIC_SG
  default_tags          = local.default_tags
}

resource "aws_ebs_volume" "extra_data_volume" {
  availability_zone = "ap-south-1a"
  size              = 500
  type              = "gp3"
  iops              = 3000
  throughput        = 125
  encrypted         = var.EC2_root_volume_encrypted
  kms_key_id        = var.EC2_root_volume_kms_key_id

  tags = merge(local.default_tags, {
    Name   = "${var.EC2_name}_data_volume"
    Module = "ADO-Agent"
  })
}

resource "aws_volume_attachment" "attach_extra_data_volume" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.extra_data_volume.id
  instance_id = module.EC2_Agent.instance_ids[0]
  force_detach = false
  skip_destroy = false
}
