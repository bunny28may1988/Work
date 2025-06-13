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
  nw-Op = data.terraform_remote_state.network.outputs
}

locals {
  Private-VPC_SG  = data.terraform_remote_state.network.outputs.all_security_group_ids["Network_VPC-SG"]
  Public-VPC_SG   = data.terraform_remote_state.network.outputs.all_security_group_ids["Public_VPC-SG"]
  Private-SSH_SG  = data.terraform_remote_state.network.outputs.all_security_group_ids["SSH-VPC"]
  Public-SSH_SG   = data.terraform_remote_state.network.outputs.all_security_group_ids["SSH-Internet"]
  subnet_Private  = data.terraform_remote_state.network.outputs.private_subnet_ids
  subnet_Public   = data.terraform_remote_state.network.outputs.public_subnet_ids
  InstanceProfile = data.terraform_remote_state.network.outputs.EC2_instance_profile_name
}