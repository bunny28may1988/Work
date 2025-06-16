output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = try(aws_eks_cluster.main.arn, null)


}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = try(aws_eks_cluster.main.certificate_authority[0].data, null)

}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = try(aws_eks_cluster.main.endpoint, null)

}


output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = try(aws_eks_cluster.main.name, "")

}

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = try(replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", ""), null)
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = try(aws_iam_openid_connect_provider.oidc_provider.arn, null)
}



# Add-on Outputs
output "installed_addon_names" {
  description = "List of all EKS add-on names installed"
  value       = [for addon in aws_eks_addon.addons : addon.addon_name]
}

output "installed_addon_versions" {
  description = "Map of installed EKS add-on names and their versions"
  value       = {
    for k, addon in aws_eks_addon.addons : addon.addon_name => addon.addon_version
  }
}

# Node Group outputs
output "nodegroup_arns" {
  description = "ARNs of the EKS Node Groups"
  value       = {
    for k, ng in aws_eks_node_group.main : k => ng.arn
  }
}

output "nodegroup_amis" {
  description = "AMIs used by each nodegroup"
  value       = {
    for k, lt in aws_launch_template.eks_nodegroup_lt : k => lt.image_id
  }
}

# Jumpserver outputs
output "jumpserver_ip" {
  description = "Private IP address of the jumpserver"
  value       = var.create_jumpserver ? aws_instance.jumpserver[0].private_ip : null
}

output "jumpserver_id" {
  description = "EC2 instance ID of the jumpserver"
  value       = var.create_jumpserver ? aws_instance.jumpserver[0].id : null
}

output "jumpserver_security_group_id" {
  description = "ID of the security group attached to the jumpserver"
  value       = aws_security_group.jumpserver.id
}


# Access Entry outputs
output "access_entries" {
  description = "Map of access entries created for the cluster"
  value       = {
    for k, v in aws_eks_access_entry.this : k => {
      principal_arn     = v.principal_arn
      kubernetes_groups = v.kubernetes_groups
      type              = v.type
      user_name         = v.user_name
    }
  }
}

# Security Group outputs
output "cluster_security_group_id" {
  description = "ID of the EKS cluster security group"
  value       = aws_security_group.eks_cluster.id
}

output "nodegroup_security_group_id" {
  description = "ID of the EKS nodegroup security group"
  value       = aws_security_group.eks_nodegroup.id
}

# IAM Role outputs
output "cluster_role_arn" {
  description = "ARN of the IAM role used by the EKS cluster"
  value       = aws_iam_role.eks_cluster.arn
}

output "nodegroup_role_arn" {
  description = "ARN of the IAM role used by the EKS nodegroups"
  value       = aws_iam_role.eks_nodegroup.arn
}

