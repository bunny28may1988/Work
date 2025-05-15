variable "default_tags" {
  type        = map(string)
  description = "Default tags to be applied to all resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to be used for EKS provisioning"
}

variable "app_subnet_ids" {
  type        = list(string)
  description = "App Subnet IDs to be used for EKS cluster"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS Key ARN for encrypting resources in EKS"
}

variable "eks_cluster_sg_id" {
  type        = string
  description = "Security Group ID of EKS Cluster"
}

variable "nlb_sg_id" {
  type        = string
  description = "Security Group ID of NLB"
}

variable "devops_sg_id" {
  type        = string
  description = "Security group id of devops agents"
}

variable "devops_iam_user_arn" {
  type        = string
  description = "IAM User ARN used in the Devops agents"
}

variable "jump_server_sg_id" {
  type        = string
  description = "Security Group ID of Jump Server"
}

variable "jump_server_iam_role_arn" {
  type        = string
  description = "IAM Role ARN used mapped to the Jump servers"
}

variable "read_only_iam_role_arn" {
  type        = string
  description = "IAM Role ARN for the read only user role in console"
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS Cluster"
}
variable "eks_cluster_version" {
  type        = string
  description = "Version of the EKS Cluster"
}

variable "eks_access_policy_name" {
  type        = string
  description = "Name of the IAM policy with EKS permissions for worker nodes to talk to cluster"
}

variable "eks_access_policy_arn" {
  type        = string
  description = "ARN of the IAM policy with EKS permissions for worker nodes to talk to cluster"
}

variable "eks_node_groups" {
  type = list(object({
    # Name of the node group
    name = string
    # AMI Id of the worker node
    ami_id = string
    # Desired instances in the node group
    desired_size = number
    # Max capacity of the node group
    max_size = number
    # Min capacity of the node group
    min_size = number
    # Node Instance type to be used
    instance_type = string
    # Size of the EBS volume to mount to in XVDA
    xvda_ebs_volume_size = number
    # Size of the EBS volume to mount to in XVDF
    xvdf_ebs_volume_size = number
    # Type of the EBS volume to mount to
    ebs_volume_type = string
    # IOPS requirement for EBS volume
    ebs_iops = number
    # Throughput requirement for EBS volume
    ebs_throughput = number
  }))
  description = "Node groups to provision in the EKS Cluster"
}

variable "devops_agent_ips" {
  type        = list(string)
  description = "List of IP address part of the Devops CI/CD agents"
}