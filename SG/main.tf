module "security_groups" {
  source = "../modules/SG-T113 "

  enable_sg = {
    (var.vpc_sg_name) = {
      sg_name                = var.vpc_sg_name
      description            = "Security Group for Self VPC CIDR Block"
      vpc_id                 = var.vpc_id
      revoke_rules_on_delete = false

      ingress_rule = [
        {
          from_port        = 443
          to_port          = 443
          protocol         = "tcp"
          cidr_blocks      = [var.vpc_cidr_block]
          ipv6_cidr_blocks = []
          prefix_list_ids  = []
          security_groups  = []
          self             = false
          description      = "Self VPC CIDR Block"
        }
      ]
      egress_rule  = []

      sg_tags = merge(local.default_tags, {
        Name = var.vpc_sg_name
      })
    },
    (var.jump_server_sg_name) = {
      sg_name                = var.jump_server_sg_name
      description            = "Security Group for Jump Server"
      vpc_id                 = var.vpc_id
      revoke_rules_on_delete = false

      ingress_rule = []
      egress_rule  = [
        {
          from_port        = 0
          to_port          = 0
          protocol         = "-1"
          cidr_blocks      = ["0.0.0.0/0"]
          ipv6_cidr_blocks = []
          prefix_list_ids  = []
          security_groups  = []
          self             = false
          description      = "Allow all outbound traffic"
        }
      ]

      sg_tags = merge(local.default_tags, {
        Name = var.jump_server_sg_name
      })
    }
  }
}