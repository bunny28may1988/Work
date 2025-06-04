variable "EC2_ADO-Compute_SG-Name" {
    description = "Name of the Security Group for ADO Compute"
    type        = string
}
variable "default_tags" {
    description = "Default tags to apply to all resources"
    type        = map(string)
}

variable "ADO_vpc-id" {
    description = "VPC ID where the security group will be created"
    type        = string
}