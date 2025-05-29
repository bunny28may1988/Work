module "security_groups" {
  source = "../modules/SG"

  create_security_groups = {
    "ec2-JumpServer_sg" = {
      name                   = "ec2-JumpServer_sg"
      description            = "Security Group for Self VPC CIDR Block"
      vpc_id                 = aws_vpc.ADO-Agent_VPC.id
      revoke_rules_on_delete = false
      Predefined_tags = merge(local.default_tags, {
        Name = "ec2-JumpServer_sg"
      })
    },
    "ec2-AdoAgent_sg" = {
      name                   = "ec2-AdoAgent_sg"
      description            = "Security Group for Self VPC CIDR Block"
      vpc_id                 = aws_vpc.ADO-Agent_VPC.id
      revoke_rules_on_delete = false
      Predefined_tags = merge(local.default_tags, {
        Name = "ec2-AdoAgent_sg"
      })
    }
  }

  ingress_rules = {

    "ec2-JumpServer_sg" = {
      sg_key      = "ec2-JumpServer_sg"
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow ssh from anywhere"
      Predefined_tags = merge(local.default_tags, {
        Name = "ec2-JumpServer_sg-SSH"
      })
    },
    "ec2-AdoAgent_sg" = {
      sg_key      = "ec2-AdoAgent_sg"
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = aws_vpc.ADO-Agent_VPC.cidr_block
      description = "Allow ssh from VPC CIDR Block"
      Predefined_tags = merge(local.default_tags, {
        Name = "ec2-AdoAgent_sg-SSH"
      })
    }
  }


  egress_rules = {
    "ec2-JumpServer_sg-all" = {
      sg_key      = "ec2-JumpServer_sg"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound traffic"

      Predefined_tags = merge(local.default_tags, {
        Name = "ec2-JumpServer_sg-all"
      })
    },
    "ec2-AdoAgent_sg-all" = {
      sg_key      = "ec2-AdoAgent_sg"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound traffic"

      Predefined_tags = merge(local.default_tags, {
        Name = "ec2-JumpServer_sg-all"
      })
    }
  }

}