module "security_groups" {
  source = "../modules/SG"

  create_security_groups = {
    "Network_VPC-SG" = {
      name                   = "Network_VPC_SG"
      description            = "Security Group for Self VPC CIDR Block"
      vpc_id                 = aws_vpc.ADO-Agent_VPC.id
      revoke_rules_on_delete = false
      Predefined_tags = merge(local.default_tags, {
        Name = "Network_VPC_SG"
      })
    },
    "SSH-VPC" = {
      name                   = "SSH-VPC"
      description            = "Security Group for SSH access inside the VPC"
      vpc_id                 = aws_vpc.ADO-Agent_VPC.id
      revoke_rules_on_delete = false
      Predefined_tags = merge(local.default_tags, {
        Name = "SSH-VPC"
      })
    },
    "SSH-Internet" = {
      name                   = "SSH-Internet"
      description            = "Security Group for SSH from Internet"
      vpc_id                 = aws_vpc.ADO-Agent_VPC.id
      revoke_rules_on_delete = false
      Predefined_tags = merge(local.default_tags, {
        Name = "SSH-Internet"
      })
    }
  }

  ingress_rules = {
    "Network_VPC-SG" = {
      sg_key      = "Network_VPC-SG"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = aws_vpc.ADO-Agent_VPC.cidr_block
      description = "Allow all  InBound with in  VPC CIDR Block"
      Predefined_tags = merge(local.default_tags, {
        Name = "Network_VPC-SG"
      })
    },
    "SSH-VPC" = {
      sg_key      = "SSH-VPC"
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = aws_vpc.ADO-Agent_VPC.cidr_block
      description = "Allow SSH access from VPC CIDR"
      Predefined_tags = merge(local.default_tags, {
        Name = "SSH-VPC"
      })
    },
    "SSH-Internet" = {
      sg_key      = "SSH-Internet"
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow SSH access from Internet"
      Predefined_tags = merge(local.default_tags, {
        Name = "SSH-Internet"
      })
    }
  }

  egress_rules = {
    "Network_VPC-SG" = {
      sg_key      = "Network_VPC-SG"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound traffic"
      Predefined_tags = merge(local.default_tags, {
        Name = "Network_VPC-SG"
      })
    }

  }
}