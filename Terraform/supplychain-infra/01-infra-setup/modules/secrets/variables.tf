variable "default_tags" {
  type        = map(string)
  description = "Default tags to be applied to all resources"
}

variable "secret_name_prefix" {
  type        = string
  description = "Prefix to append to the secrets which are created"
}

variable "secret_names" {
  type        = list(string)
  description = "Name of the Secret "
}

variable "kms_key_arn" {
  type        = string
  description = "KMS Key to use for encrypting the secrets"
}

