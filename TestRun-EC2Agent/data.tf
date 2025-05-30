# Represents the state produced by the provisioning of network components in the `networks` project.
data "terraform_remote_state" "network" {
  backend = "s3"
  config  = {
    bucket = var.aws.network_tf_bucket
    key    = var.aws.network_tf_bucket_key
    region = var.aws.network_tf_bucket_region
  }
}

data "aws_vpc" "main" {
  id = local.vpc_id
}

data "aws_subnet" "app_subnets" {
  for_each = {for idx, id in local.app_subnet_ids : idx => id}
  id       = each.value
}

data "aws_kms_key" "kms_key" {
  key_id = local.kms_key_arn
}

data "aws_caller_identity" "current" {}