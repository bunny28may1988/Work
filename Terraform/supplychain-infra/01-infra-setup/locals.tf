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

# Outputs extracted from the network module
locals {
  vpc_id         = data.terraform_remote_state.network.outputs.vpc_id
  app_subnet_ids = [
    data.terraform_remote_state.network.outputs.app_subnet_1a, data.terraform_remote_state.network.outputs.app_subnet_1b
  ]
  arcon_sg               = data.terraform_remote_state.network.outputs.arcon_sg
  nlb_sg                 = data.terraform_remote_state.network.outputs.nlb_sg
  iam_ssm_role_name      = data.terraform_remote_state.network.outputs.iam_ssm_role_name
  iam_ssm_role_arn       = data.terraform_remote_state.network.outputs.ssm_role_arn
  kms_key_arn            = data.terraform_remote_state.network.outputs.kms_key
  eks_access_policy_name = data.terraform_remote_state.network.outputs.eks_access_policy_name
  eks_access_policy_arn  = data.terraform_remote_state.network.outputs.eks_access_policy_arn
}
