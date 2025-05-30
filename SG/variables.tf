variable "default_tags" {
  type        = map(string)
  description = "Default tags to be applied to all resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to create the security groups under"
}

variable "vpc_sg_name" {
  type        = string
  description = "Name of the security group for the VPC CIDR block"
}

variable "vpc_cidr_block" {
  type = string
  description = "CIDR Block of the current VPC"
}

variable "eks_cluster_sg_name" {
  type        = string
  description = "Name of the security group for the EKS Cluster"
}

variable "jump_server_sg_name" {
  type        = string
  description = "Name of the security group for the Jump server"
}

variable "devops_sg_name" {
  type        = string
  description = "Name of the security group for the Devops Agents"
}

variable "devops_agent_ips" {
  type        = list(string)
  description = "List of IP address part of the Devops CI/CD agents"
}