############################
# Variables for EC2 ADO Agent
############################

############################
# EC2 Variables #
############################

variable "EC2_name" {
  description = "Name of the EC2 ADO Agent"
  type        = string
}
variable "EC2_ami" {
  description = "AMI for the EC2 ADO Agent"
  type        = string
}
variable "EC2_instance_type" {
  description = "Instance type for the EC2 ADO Agent"
  type        = string
}
variable "EC2_security_group_ids" {
  description = "Security group IDs for the EC2 ADO Agent"
  type        = list(string)
}
variable "EC2_subnet_id" {
  description = "Subnet ID for the EC2 ADO Agent"
  type        = string
}
variable "EC2_instance_profile" {
  description = "IAM instance profile for the EC2 ADO Agent"
  type        = string
  default     = null
}
variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
}
############################
# Root Volume Variables #
############################

variable "EC2_root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
}
variable "EC2_root_volume_type" {
  description = "Type of the root volume"
  type        = string
}
variable "EC2_root_volume_iops" {
  description = "IOPS for the root volume"
  type        = number
  default     = null
}
variable "EC2_root_volume_throughput" {
  description = "Throughput for the root volume"
  type        = number
  default     = null
}
variable "EC2_root_volume_encrypted" {
  description = "Whether the root volume is encrypted"
  type        = bool
  default     = false
}
variable "EC2_root_volume_kms_key_id" {
  description = "KMS key ID for the root volume encryption"
  type        = string
  default     = null
}
/*
############################
# Variables for EC2 JumpServer
############################

############################
# EC2 Variables #
############################

variable "EC2_name-02" {
  description = "Name of the EC2 ADO Agent"
  type        = string
}
variable "EC2_ami-02" {
  description = "AMI for the EC2 ADO Agent"
  type        = string
}
variable "EC2_instance_type-02" {
  description = "Instance type for the EC2 ADO Agent"
  type        = string
}
variable "EC2_security_group_ids-02" {
  description = "Security group IDs for the EC2 ADO Agent"
  type        = list(string)
}
variable "EC2_subnet_id-02" {
  description = "Subnet ID for the EC2 ADO Agent"
  type        = string
}
variable "EC2_instance_profile-02" {
  description = "IAM instance profile for the EC2 ADO Agent"
  type        = string
  default     = null
}
############################
# Root Volume Variables #
############################

variable "EC2_root_volume_size-02" {
  description = "Size of the root volume in GB"
  type        = number
}
variable "EC2_root_volume_type-02" {
  description = "Type of the root volume"
  type        = string
}
variable "EC2_root_volume_iops-02" {
  description = "IOPS for the root volume"
  type        = number
  default     = null
}
variable "EC2_root_volume_throughput-02" {
  description = "Throughput for the root volume"
  type        = number
  default     = null
}
variable "EC2_root_volume_encrypted-02" {
  description = "Whether the root volume is encrypted"
  type        = bool
  default     = false
}
variable "EC2_root_volume_kms_key_id-02" {
  description = "KMS key ID for the root volume encryption"
  type        = string
  default     = null
}*/