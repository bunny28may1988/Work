variable "default_tags" {
  type        = map(string)
  description = "Default tags to be applied to all resources"
}
variable "ec2_jump_server_name" {
  type        = string
  description = "Name of the jump server EC2"
}
variable "ec2_jump_server_ami" {
  type        = string
  description = "AMI to use for the Jump Server"
}
variable "ec2_jump_server_instance_type" {
  type        = string
  description = "EC2 Instance Type to use for the Jump Server"
}
variable "arcon_sg" {
  type        = string
  description = "Security Group of Arcon servers to use for the Jump Server"
}
variable "jump_server_sg" {
  type        = string
  description = "Security Group of the Jump Server"
}
variable "ec2_jump_server_subnet_id" {
  type        = string
  description = "Subnet ID to use for the Jump Server"
}
variable "ec2_jump_server_private_ip" {
  type        = string
  description = "Private IP to be assigned to the Jump Server"
}
variable "ec2_jump_server_az" {
  type        = string
  description = "Availability Zone to use for the Jump Server"
}
variable "ec2_iam_instance_profile" {
  type        = string
  description = "IAM Instance Profile to use for the Jump Server"
}
variable "ec2_kms_key_arn" {
  type        = string
  description = "KMS Key ID to use for encrypting volumes in Jump server"
}