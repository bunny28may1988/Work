output "sg-id" {
  value = local.sg_id.sg_id[var.EC2_ADO-Compute_SG-Name]
}

locals {
  sg_id = { for sg_key, sg_value in module.security_groups : sg_key => sg_value } 
}