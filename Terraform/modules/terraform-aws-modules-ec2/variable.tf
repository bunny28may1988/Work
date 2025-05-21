################ Key Pair ##############

variable "ssh_key_name" {
  default = null
  type = string
  description = "SSH key to attach with EC2 instance"
}

variable "create_key" {
  default = false
  type = bool
  description = "If you want to create Create KMS Key"
}
#######################  EC2  #####################3

variable "create_instance" {
  type    = any
  default = {}
  description = "Create EC2 instance"
}
