variable "workgroup_name" {
  type    = string
  default = ""
}

variable "output_location" {
  type    = string
  default = ""
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to be applied to all resources"
}