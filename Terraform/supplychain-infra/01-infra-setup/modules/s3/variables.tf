variable "kms_arn" {
  type        = string
  description = "kms key arn for bucket encryption"
}

variable "s3_bucket_name" {
  type        = string
  description = "bucket name for creation"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to be applied to all resources"
}

variable "devops_iam_user_arn" {
  type        = string
  description = "IAM User ARN used in the Devops agents"
}