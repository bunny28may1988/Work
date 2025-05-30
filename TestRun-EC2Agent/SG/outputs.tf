
output "vpc_sg_id" {
  value = module.security_groups.security_group[var.vpc_sg_name].id
}

output "eks_cluster_sg_id" {
  value = module.security_groups.security_group[var.eks_cluster_sg_name].id
}

output "jump_server_sg_id" {
  value = module.security_groups.security_group[var.jump_server_sg_name].id
}

output "devops_sg_id" {
  value = module.security_groups.security_group[var.devops_sg_name].id
}
