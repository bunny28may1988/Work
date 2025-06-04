locals {
  default_tags = {
    "application-id"       = var.application.id
    "application-manager"  = var.application.manager
    "application-name"     = var.application.name
    "application-owner"    = var.application.owner
    "application-rating"   = var.application.rating
    "aws-control-tower"    = "yes"
    "budget-type"          = var.application.budget_type
    "created-by-terraform" = "yes"
    "entity"               = "kmbl"
    "environment"          = var.environment.name
    "managed-by"           = "terraform"
    "project-name"         = var.application.name
    "terraform-version"    = "1.6"
    "vertical-tlt"         = var.application.tlt
    "map-migrated"         = var.application.map-migrated
  }
}

locals {
  network_sg = data.terraform_remote_state.NWSateFile.outputs.all_security_group_ids["Network_VPC-SG"]
  vpc_id     = data.terraform_remote_state.NWSateFile.outputs.vpc_id
  vpc_cidr   = data.terraform_remote_state.NWSateFile.outputs.vpc_cidr_block
  subnet_ids = data.terraform_remote_state.NWSateFile.outputs.private_subnet_ids
}