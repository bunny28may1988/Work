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
    }
  }

  ingress_rules = {
    "Network_VPC-SG" = {
      sg_key      = "Network_VPC-SG"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = aws_vpc.ADO-Agent_VPC.cidr_block
      description = "Allow ssh from VPC CIDR Block"
      Predefined_tags = merge(local.default_tags, {
        Name = "Network_VPC-SG"
      })
    }
  }

  egress_rules = {}

}