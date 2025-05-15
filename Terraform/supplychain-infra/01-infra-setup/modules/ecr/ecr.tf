# Create ECR repositories for pushing images from CI/CD pipelines
module "ecr_repositories" {
  for_each                                  = toset(var.ecr_repositories)
  source                                    = "../../../../../terraform-aws-modules-elastic-container-registry/modules"
  repository_type                           = "private"
  repository_name                           = each.key
  repository_image_tag_mutability           = var.ecr_has_mutable_tags ? "MUTABLE" : "IMMUTABLE"
  repository_encryption_type                = "KMS"
  repository_kms_key                        = var.kms_key_arn
  repository_image_scan_on_push             = true
  create_lifecycle_policy                   = false
  repository_force_delete                   = true
  create_registry_replication_configuration = var.enable_region_replication
  registry_replication_rules = [
    {
      destinations = [
        {
          registry_id = data.aws_caller_identity.current.account_id
          region      = var.replication_region
        }
      ]
    }
  ]
  tags = merge(local.default_tags, {
    Name = "ECR Repository ${each.key}"
  })
}