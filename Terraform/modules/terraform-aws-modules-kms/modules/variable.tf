variable "tags" {
  default = {
    Owner = "devops"
  }
  type = map(string)
}

variable "key_name" {
  type = string
  description = "KMS Key name"
  default = ""
}

variable "user_policy" {
  default = ""
  type    = string
  description = "Policy to attach with KMS  key"
}

variable "enable_key_rotation" {
  type    = bool
  default = true
  description = "value"
}

variable "description" {
  type    = string
  default = "KMS Key"
  description = "value"
}
