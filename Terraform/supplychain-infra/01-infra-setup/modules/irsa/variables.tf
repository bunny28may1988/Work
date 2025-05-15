variable "kms_key_arn" {
  type        = string
  description = "KMS Key ARN"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to be applied to all resources"
}

variable "eks_oidc_provider" {
  type        = string
  description = "OIDC Provider name for EKS Cluster"
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "OIDC Provider ARN for the EKS Cluster"
}

variable "service_name" {
  type        = string
  description = "Name of the service"
}

variable "namespace" {
  type        = string
  description = "Namespace of the service"
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS Cluster"
}

variable "secret_arns" {
  type        = list(string)
  description = "List of secrets to provide access to this service"
}

variable "service_iam_policies" {
  type = object({
    # Does this need read write access to elastic load balancer
    elb_rw            = bool
    # Does this need read write access to RDS clusters
    rds_rw            = bool
    # Does this need to write to cloudwatch logs
    logs_rw           = bool
    # Does this need to write to specific bucket
    s3_bucket_rw      = optional(string, "")
    # Does this need to write to dynamodb table
    dynamodb_table_rw = optional(string, "")
    # Does this need kms permissions
    kms_rw            = bool
    # Does this need eks_ro permissions
    eks_ro              = bool
  })
  description = "IAM policies to provision for this service"
}
