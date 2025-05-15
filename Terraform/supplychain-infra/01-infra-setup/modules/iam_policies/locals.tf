locals {
  default_tags = merge(var.default_tags, {
    Module = "iam_policies"
  })
}

locals {
  partition  = data.aws_partition.current.partition
  account_id = data.aws_caller_identity.current.account_id
  region = data.aws_region.current.name
}