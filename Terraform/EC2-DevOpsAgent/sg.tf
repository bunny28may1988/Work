module "security_groups" {
  source = "./modules/SG"

  create_security_groups = {
    "ec2-DevopsAgent_sg" = {
      name                   = "ec2-DevopsAgent_sg"
      description            = "Security Group for Self VPC CIDR Block"
      vpc_id                 = "vpc-0c8bfc45e36783b46"
      revoke_rules_on_delete = false
      Predefined_tags = merge(local.default_tags, {
        Name = "ec2-DevopsAgent_sg"
      })
    }
  }

  ingress_rules = {
    "ec2-DevopsAgent_sg-https" = {
      sg_key      = "ec2-DevopsAgent_sg"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow HTTPS from anywhere"
      Predefined_tags = merge(local.default_tags, {
        Name = "ec2-DevopsAgent_sg-https"
      })
    }
  }

  egress_rules = {
    "ec2-DevopsAgent_sg-all" = {
      sg_key      = "ec2-DevopsAgent_sg"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound traffic"

      Predefined_tags = merge(local.default_tags, {
        Name = "ec2-DevopsAgent_sg-all"
      })
    }
  }

}