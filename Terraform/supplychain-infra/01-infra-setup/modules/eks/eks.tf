module "eks" {
  source                          = "../../../../../terraform-aws-modules-eks/modules/eks"
  cluster_name                    = var.eks_cluster_name
  cluster_version                 = var.eks_cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false
  create_cloudwatch_log_group     = false
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.app_subnet_ids
  control_plane_subnet_ids        = var.app_subnet_ids
  create_kms_key                  = false
  cluster_encryption_config       = {
    provider_key_arn = var.kms_key_arn
    resources        = ["secrets"]
  }
  enable_irsa                             = true
  cluster_security_group_additional_rules = local.cluster_security_group_additional_rules
  cluster_additional_security_group_ids   = [var.eks_cluster_sg_id]
  create_node_security_group              = true
  node_security_group_additional_rules    = local.node_security_group_additional_rules
  authentication_mode                     = "API_AND_CONFIG_MAP"
  access_entries                          = local.eks_access_entries
  eks_managed_node_groups                 = {
    for group in var.eks_node_groups :
    group.name => {
      # Keep specific ami id to avoid unplanned outages due to version upgrades
      ami_id                       = group.ami_id
      # ami_id                       = data.aws_ami.eks_ami_latest.id
      enable_bootstrap_user_data   = true
      pre_bootstrap_user_data      = data.template_file.pre_bootstrap_data.rendered
      instance_types               = [group.instance_type]
      min_size                     = group.min_size
      max_size                     = group.max_size
      desired_size                 = group.desired_size
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        (var.eks_access_policy_name) = var.eks_access_policy_arn
      }
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs         = {
            name                  = "${group.name}_ebs_xvda"
            volume_size           = group.xvda_ebs_volume_size
            volume_type           = group.ebs_volume_type
            iops                  = group.ebs_iops
            throughput            = group.ebs_throughput
            delete_on_termination = true
            encrypted             = true
            kms_key_id            = var.kms_key_arn
            tags                  = merge(local.default_tags, {
              Name = "${group.name}_ebs_xvda"
            })
          }
        }
        xvdf = {
          device_name = "/dev/xvdf"
          ebs         = {
            name                  = "${group.name}_ebs_xvdf"
            volume_size           = group.xvdf_ebs_volume_size
            volume_type           = group.ebs_volume_type
            iops                  = group.ebs_iops
            throughput            = group.ebs_throughput
            delete_on_termination = true
            encrypted             = true
            kms_key_id            = var.kms_key_arn
            tags                  = merge(local.default_tags, {
              Name = "${group.name}_ebs_xvdf"
            })
          }
        }
      }
      tags = merge(local.default_tags, {
        Name = group.name
      })
    }
  }
  tags = merge(local.default_tags, {
    Name = var.eks_cluster_name
  })
  cluster_tags = merge(local.default_tags, {
    Name = var.eks_cluster_name
  })
}

module "eks_blueprints_addons" {
  source = "../../../../../terraform-aws-modules-eks/modules/eks_blueprints_addons"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    coredns = {
      most_recent                 = false
      # Keep specific versions to avoid unplanned outages due to version upgrades
      addon_version               = local.eks_addons_coredns_version
      resolve_conflicts_on_update = "OVERWRITE"
    }
    vpc-cni = {
      most_recent                 = false
      # Keep specific versions to avoid unplanned outages due to version upgrades
      addon_version               = local.eks_addons_vpc_cni_version
      resolve_conflicts_on_update = "OVERWRITE"
    }
    kube-proxy = {
      most_recent                 = false
      # Keep specific versions to avoid unplanned outages due to version upgrades
      addon_version               = local.eks_addons_kube_proxy_version
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }
  tags = merge(local.default_tags, {
    Name = "${var.eks_cluster_name}_addons"
  })
  depends_on = [
    module.eks
  ]
}