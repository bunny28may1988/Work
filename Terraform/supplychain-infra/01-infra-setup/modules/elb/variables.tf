variable "default_tags" {
  type        = map(string)
  description = "Default tags to be applied to all resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to create the NLB under"
}

variable "app_subnet_ids" {
  type        = list(string)
  description = "App Subnet IDs to be used for NLB"
}

variable "nlb_name" {
  type        = string
  description = "Name of the NLB"
}

variable "nlb_sg_id" {
  type        = string
  description = "Security Group ID for the NLB"
}

variable "vpc_sg_id" {
  type        = string
  description = "Security Group ID for the VPC CIDR Block"
}
