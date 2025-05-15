module "ecr" {
  source                    = "./modules/ecr"
  default_tags              = local.default_tags
  kms_key_arn               = local.kms_key_arn
  ecr_repositories          = try(var.compute.ecr.repositories, [])
  ecr_has_mutable_tags      = try(var.compute.ecr.has_mutable_tags, false)
  enable_region_replication = try(var.compute.ecr.enable_region_replication, false)
  replication_region        = var.compute.ecr.replication_region
}

module "sg" {
  source              = "./modules/sg"
  default_tags        = local.default_tags
  vpc_id              = local.vpc_id
  eks_cluster_sg_name = var.security.sg.eks_cluster_sg_name
  jump_server_sg_name = var.security.sg.jump_server_sg_name
  devops_sg_name      = var.security.sg.devops_sg_name
  devops_agent_ips    = var.security.sg.devops_agent_ips
  vpc_cidr_block      = data.aws_vpc.main.cidr_block
  vpc_sg_name         = var.security.sg.vpc_sg_name
}

module "nlb" {
  for_each       = try(var.network, {})
  source         = "./modules/elb"
  vpc_id         = local.vpc_id
  app_subnet_ids = local.app_subnet_ids
  default_tags   = local.default_tags
  nlb_name       = each.value
  nlb_sg_id      = local.nlb_sg
  vpc_sg_id      = module.sg.vpc_sg_id
}

module "ec2" {
  source                        = "./modules/ec2"
  default_tags                  = local.default_tags
  arcon_sg                      = local.arcon_sg
  jump_server_sg                = module.sg.jump_server_sg_id
  ec2_iam_instance_profile      = local.iam_ssm_role_name
  ec2_jump_server_name          = var.compute.ec2.jump_server_name
  ec2_jump_server_ami           = var.compute.ec2.jump_server_ami_id
  ec2_jump_server_subnet_id     = local.app_subnet_ids[0]
  ec2_jump_server_private_ip    = cidrhost(data.aws_subnet.app_subnets[0].cidr_block, var.compute.ec2.jump_server_private_ip_index)
  ec2_jump_server_az            = data.aws_subnet.app_subnets[0].availability_zone
  ec2_jump_server_instance_type = var.compute.ec2.jump_server_instance_type
  ec2_kms_key_arn               = local.kms_key_arn
}

module "eks" {
  source                   = "./modules/eks"
  default_tags             = local.default_tags
  vpc_id                   = local.vpc_id
  app_subnet_ids           = local.app_subnet_ids
  kms_key_arn              = local.kms_key_arn
  eks_cluster_sg_id        = module.sg.eks_cluster_sg_id
  jump_server_sg_id        = module.sg.jump_server_sg_id
  jump_server_iam_role_arn = local.iam_ssm_role_arn
  devops_sg_id             = module.sg.devops_sg_id
  devops_iam_user_arn      = var.security.iam.devops_iam_user_arn
  read_only_iam_role_arn   = var.security.iam.read_only_iam_role_arn
  nlb_sg_id                = local.nlb_sg
  eks_cluster_name         = var.compute.eks.cluster_name
  eks_cluster_version      = var.compute.eks.cluster_version
  eks_node_groups          = var.compute.eks.node_groups
  eks_access_policy_name   = local.eks_access_policy_name
  eks_access_policy_arn    = local.eks_access_policy_arn
  devops_agent_ips         = var.security.sg.devops_agent_ips
}

module "s3" {
  for_each            = try(var.s3_bucket, {})
  source              = "./modules/s3"
  s3_bucket_name      = each.value
  kms_arn             = local.kms_key_arn
  default_tags        = local.default_tags
  devops_iam_user_arn = var.security.iam.devops_iam_user_arn
}

module "secrets" {
  for_each           = var.cluster.services
  source             = "./modules/secrets"
  default_tags       = local.default_tags
  kms_key_arn        = local.kms_key_arn
  secret_name_prefix = "${each.value.namespace}/${each.key}/${var.environment.name}/"
  secret_names       = each.value.secret_names
}

module "generic_secrets" {
  for_each           = try(var.generic_secrets.apps, {})
  source             = "./modules/secrets"
  default_tags       = local.default_tags
  kms_key_arn        = local.kms_key_arn
  secret_name_prefix = "${each.key}/${each.value.namespace}/${var.environment.name}/"
  secret_names       = each.value.secret_names
}

module "irsa" {
  for_each              = var.cluster.services
  source                = "./modules/irsa"
  default_tags          = local.default_tags
  environment           = var.environment.name
  eks_cluster_name      = var.compute.eks.cluster_name
  kms_key_arn           = local.kms_key_arn
  eks_oidc_provider     = module.eks.oidc_provider
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  service_name          = each.key
  namespace             = each.value.namespace
  secret_arns           = module.secrets[each.key].secret_arns
  service_iam_policies  = each.value.policies
}

moved {
  from = module.s3.module.supplychain-s3-bucket.aws_s3_bucket.this[0]
  to   = module.s3["bucket1"].module.supplychain-s3-bucket.aws_s3_bucket.this[0]
}

moved {
  from = module.nlb.module.nlb.aws_lb.this[0]
  to   = module.nlb["nlb1"].module.nlb.aws_lb.this[0]
}

moved {
  from = module.service_iam
  to   = module.irsa
}

module "supplychain-athena" {
  source          = "./modules/athena"
  workgroup_name  = var.data_catalog.athena.workgroup_name
  output_location = var.data_catalog.athena.output_location
  default_tags    = local.default_tags
}

module "supplychain-glue" {
  source                = "./modules/glue"
  catalog_id            = data.aws_caller_identity.current.account_id
  catalog_database_name = var.data_catalog.glue.catalog_database_name
  catalog_table_name    = var.data_catalog.glue.catalog_table_name
  location_uri          = var.data_catalog.glue.location_uri
  default_tags          = local.default_tags
}

module "iam_resource_policies" {
  for_each        = try(var.cross_account_secret_access, {})
  source          = "./modules/iam_policies"
  default_tags    = local.default_tags
  policy_mappings = {
    for role_arn in each.value.destination_role_arns :
    role_arn => {
      attach_secrets_ro_resource_policy = true
      secret_names                      = [each.value.name]
    }
  }
}

module "iam_role_service_policies" {
  source          = "./modules/iam_policies"
  default_tags    = local.default_tags
  policy_mappings = {
    ro_policy = {
      attach_all_ro_policy = true
      role_name            = var.security.iam.read_only_iam_role_name
    }
  }
}

module "iam_user_service_policies" {
  source          = "./modules/iam_policies"
  default_tags    = local.default_tags
  policy_mappings = {
    data_catalog_ro_policy = {
      attach_athena_ro_policy    = true
      athena_workgroup_name      = var.data_catalog.athena.workgroup_name
      glue_catalog_database_name = var.data_catalog.glue.catalog_database_name
      glue_catalog_table_name    = var.data_catalog.glue.catalog_table_name
      user_name                  = var.security.iam.devops_iam_user_name
    }
  }
}