
module "sg" {
  source              = "../SG"
  default_tags        = local.default_tags
  vpc_id              = local.vpc_id
  jump_server_sg_name = var.security.sg.jump_server_sg_name
  vpc_cidr_block      = data.aws_vpc.main.cidr_block
  vpc_sg_name         = var.security.sg.vpc_sg_name
}


module "ec2" {
  source                        = "../EC2"
  default_tags                  = local.default_tags
  arcon_sg                      = local.arcon_sg
  jump_server_sg                = module.sg.jump_server_sg_id
  ec2_iam_instance_profile      = local.iam_ssm_role_name
  ec2_jump_server_name          = var.compute.ec2.jump_server_name
  ec2_jump_server_ami           = var.compute.ec2.jump_server_ami_id
  ec2_jump_server_subnet_id     = local.app_subnet_ids[0]
  ec2_jump_server_az            = data.aws_subnet.app_subnets[0].availability_zone
  ec2_jump_server_instance_type = var.compute.ec2.jump_server_instance_type
  ec2_kms_key_arn               = local.kms_key_arn
}