module "security_groups" {
  source = "../../../Resource-Modules/SG"

  create_security_groups = {
    (var.EC2_ADO-Compute_SG-Name) = {
      name                   = var.EC2_ADO-Compute_SG-Name
      description            = "Security Group for Self VPC CIDR Block"
      vpc_id                 = local.vpc_id
      revoke_rules_on_delete = false
      Predefined_tags = merge(local.default_tags, {
        Name = "${var.EC2_ADO-Compute_SG-Name}"
      })
    }
  }

  ingress_rules = {}

  egress_rules = {
    (var.EC2_ADO-Compute_SG-Name) = {
      sg_key      = var.EC2_ADO-Compute_SG-Name
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      ip_protocol = -1
      cidr_ipv4   = "0.0.0.0/0"
      Predefined_tags = merge(local.default_tags, {
        Name = "${var.EC2_ADO-Compute_SG-Name}-Egress"
      })
    }
  }

}