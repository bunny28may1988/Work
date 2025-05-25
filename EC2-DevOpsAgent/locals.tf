locals {
  vpc_id = "vpc-0c8bfc45e36783b46"
  app_subnet_ids = [
    "subnet-03110dfcd440f9ec7",
    "subnet-01087e5089ed2508c"
  ]
  arcon_sg          = "sg-0e5d049f2e20d49c0"
  iam_ssm_role_name = "iam-role-supplychain-ssm-nonprod-1"
  iam_ssm_role_arn  = "arn:aws:iam::471112531675:role/iam-role-supplychain-ssm-nonprod-1"
  kms_key_arn       = "arn:aws:kms:***:471112531675:key/df0dc025-5e73-4c0a-b0f0-941f0855d303"

  application = {
    id           = "APP-01396"
    name         = "DevOps"
    owner        = "Kannan Varadharajan"
    manager      = "Mohan Pemmaraju"
    tlt          = "Vijay Narayanan"
    rating       = "Medium"
    budget_type  = "ctb"
    map-migrated = "migPHEWKGG1FG"
  }
  environment = {
    name = "nonprod"
  }
  default_tags = {
    "application-id"       = local.application.id
    "application-manager"  = local.application.manager
    "application-name"     = local.application.name
    "application-owner"    = local.application.owner
    "application-rating"   = local.application.rating
    "aws-control-tower"    = "yes"
    "budget-type"          = local.application.budget_type
    "created-by-terraform" = "yes"
    "entity"               = "kmbl"
    "environment"          = local.environment.name
    "managed-by"           = "terraform"
    "project-name"         = local.application.name
    "terraform-version"    = "1.6"
    "vertical-tlt"         = local.application.tlt
    "map-migrated"         = local.application.map-migrated
  }
}