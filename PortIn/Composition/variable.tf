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

variable "compute" {
  description = "EC2 Related Variables"
  type = object({
    ec2 = object({
      ADO_Agent_name               = string
      ADO_Agent_ami                = string
      ADO_Agent_instance_type      = string
      ADO_Agent_security_group_ids = list(string)
      ADO_Agent_subnet_id          = string
    })
    ruut = object({
      ruut_volume_size       = number
      ruut_volume_type       = string
      ruut_volume_iops       = number
      ruut_volume_encrypted  = bool
      ruut_volume_throughput = number
      ruut_volume_kms_key_id = string
    })
  })
}