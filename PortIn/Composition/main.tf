module "ADO-Agent" {
  source                               = "../ADO-Agent"
  EC2_ADO-Agent_name                   = var.compute.ec2.ADO_Agent_name
  EC2_ADO-Agent_ami                    = var.compute.ec2.ADO_Agent_ami
  EC2_ADO-Agent_instance_type          = var.compute.ec2.ADO_Agent_instance_type
  EC2_ADO-Agent_security_group_ids     = var.compute.ec2.ADO_Agent_security_group_ids
  EC2_ADO-Agent_subnet_id              = var.compute.ec2.ADO_Agent_subnet_id
  default_tags                         = local.default_tags
  EC2_ADO-Agent_root_volume_size       = var.compute.ruut.ruut_volume_size
  EC2_ADO-Agent_root_volume_type       = var.compute.ruut.ruut_volume_type
  EC2_ADO-Agent_root_volume_iops       = var.compute.ruut.ruut_volume_iops
  EC2_ADO-Agent_root_volume_encrypted  = var.compute.ruut.ruut_volume_encrypted
  EC2_ADO-Agent_root_volume_throughput = var.compute.ruut.ruut_volume_throughput
  EC2_ADO-Agent_root_volume_kms_key_id = var.compute.ruut.ruut_volume_kms_key_id
}