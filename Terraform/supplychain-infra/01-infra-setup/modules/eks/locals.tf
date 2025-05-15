locals {
  default_tags = merge(var.default_tags, {
    Module = "eks"
  })

  # Find latest version from AWS Console
  eks_addons_coredns_version    = "v1.11.1-eksbuild.9"
  eks_addons_vpc_cni_version    = "v1.18.2-eksbuild.1"
  eks_addons_kube_proxy_version = "v1.29.3-eksbuild.5"
}

###################################################
## Security Groups for the EKS Cluster and Nodes ##
###################################################
locals {
  # Add security group rules to the Cluster APIs
  cluster_security_group_additional_rules = {
    ingress_jump_server_443 = {
      description              = "Access EKS from EC2 instance (jump server)."
      protocol                 = "-1"
      from_port                = 0
      to_port                  = 0
      type                     = "ingress"
      source_security_group_id = var.jump_server_sg_id
    }
    nlb_ingress_443 = {
      description              = "Ingress from NLB to cluster"
      protocol                 = "TCP"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = var.nlb_sg_id
    }
    devops_ingress_443 = {
      description              = "Ingress from Devops agent to cluster"
      protocol                 = "TCP"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = var.devops_sg_id
    }
  }

  # Add security group rules to the nodes in the Cluster
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Cluster node internal communication"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_cluster_all = {
      description                   = "Allow all Cluster API to node groups"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    node_nlb_ingress_8443 = {
      description              = "Ingress from NLB to nodes"
      protocol                 = "TCP"
      from_port                = 8443
      to_port                  = 8443
      type                     = "ingress"
      source_security_group_id = var.nlb_sg_id
    }
  }
}

########################################
## Access Entries for the EKS Cluster ##
########################################
locals {
  eks_access_entries = {
    devops_agent = {
      principal_arn       = var.devops_iam_user_arn
      type                = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    },
    jump_server = {
      principal_arn       = var.jump_server_iam_role_arn
      type                = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    },
    read_only = {
      principal_arn       = var.read_only_iam_role_arn
      type                = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}