variable "EC2_ADO-Compute_SG-Name" {
  description = "Name of the Security Group for ADO Compute"
  type        = string
  default     = "Test-SG"
}
variable "application" {
  description = "Application metadata"
  type = object({
    # Application ID
    id = string
    # Name of the application
    name = string
    # Application Owner
    owner = string
    # Application Manager
    manager = string
    # Application TLT
    tlt = string
    # Application Rating
    rating = string
    # Budget type for application
    budget_type = string
    # map-migrated for application
    map-migrated = string
  })
}

variable "environment" {
  description = "Environment metadata"
  type = object({
    # Name of the environment
    name = string
  })
}