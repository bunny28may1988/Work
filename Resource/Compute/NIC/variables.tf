
variable "EC2_Agent_NIC_Name" {
  description = "The name of the EC2 Agent NIC"
  type        = string
  default     = "EC2-Agent-NIC"
}
variable "EC2_Agent_NIC_SG" {
  description = "The security group to attach to the EC2 Agent NIC"
  type        = list(string)
  default     = []
}

variable "EC2_Agent_NIC_Subnet" {
  description = "The subnet ID to attach the EC2 Agent NIC"
  type        = string
}
variable "EC2_Agent_Private_ips" {
  description = "The private IP address to assign to the EC2 Agent NIC"
  type        = list(string)
  default     = []
}
variable "default_tags" {
  type        = map(string)
  description = "Default tags to be applied to all resources"
}
