
module "ADO-Agent" {
  source                     = "../Resource/Compute/"
  EC2_name                   = var.Resource.EC2.ADO-Agent_Name
  EC2_ami                    = var.Resource.EC2.ADO-Agent_ami
  EC2_instance_type          = var.Resource.EC2.ADO-Agent_instance_type
  EC2_security_group_ids     = [local.VpcSg_id, local.VPC-SSH_SG]
  EC2_subnet_id              = local.subnet[0]
  EC2_instance_profile       = local.InstanceProfile #local.iam_ssm_role_name
  default_tags               = local.default_tags
  EC2_root_volume_size       = var.Resource.EC2.ADO-Agent_root_volume_size
  EC2_root_volume_type       = var.Resource.EC2.ADO-Agent_root_volume_type
  EC2_root_volume_iops       = var.Resource.EC2.ADO-Agent_root_volume_iops
  EC2_root_volume_encrypted  = true
  EC2_root_volume_throughput = var.Resource.EC2.ADO-Agent_root_volume_throughput
  EC2_root_volume_kms_key_id = null #local.kms_key_arn
}