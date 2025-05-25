module "devops_agent_ec2" {
  source       = "./modules/EC2"
  ssh_key_name = null # or "your-key-name" if you have one
  create_instance = {
    "ec2-devopsAgent" = {
      ami           = "ami-0580abca8c40953e1"
      instance_name = "ec2-devopsAgent"
      instance_type = "t3.medium"
      subnet_id     = local.app_subnet_ids[0]
      #vpc_security_group_ids = [module.devops_agent_sg.sg_id[0], local.arcon_sg]
      vpc_security_group_ids = [local.arcon_sg, module.security_groups.sg_id["ec2-DevopsAgent_sg"]]
      iam_instance_profile   = local.iam_ssm_role_name
      kms_key_id             = local.kms_key_arn
      ebs_block_device = [{
        device_name           = "/dev/xvda"
        volume_size           = 100
        volume_type           = "gp3"
        encrypted             = true
        kms_key_id            = local.kms_key_arn
        delete_on_termination = true
        tags                  = local.default_tags
      }]
      ec2_tags = merge(local.default_tags, {
        Name = "ec2-devopsAgent"
      })
      volume_tags = merge(local.default_tags, {
        Name = "ec2-devopsAgent_volume"
      })
      # Add other required EC2 module variables here
    }
  }
}