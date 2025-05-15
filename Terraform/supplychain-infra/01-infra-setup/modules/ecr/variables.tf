variable "default_tags" {
  type = map(string)
  description = "Default tags to be applied to all resources"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS Key ARN for encrypting the images"
}

# ECR related variables
variable "ecr_repositories" {
  type = list(string)
  description = "Name of the ECR repositories to create"
}

variable "ecr_has_mutable_tags" {
  type        = bool
  description = "Should the ECR image tag be mutable or immutable?"
}

variable "enable_region_replication" {
  type        = bool
  description = "Whether to enable replication of ECR repositories across regions"
}

variable "replication_region" {
  type        = string
  nullable    = true
  description = "Region to which replication of ECR images has to be setup"
}