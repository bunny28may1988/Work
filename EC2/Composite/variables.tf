# Application specific variables
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

variable "aws" {
  description = "AWS environment related metadata"
  type = object({
    # The AWS region to deploy to.
    region = string
    # The provisioning IAM role which terraform can assume
    assume_role_arn = string
    # Network provisioning terraform state S3 bucket
    network_tf_bucket = string
    # Network provisioning terraform state S3 bucket key
    network_tf_bucket_key = string
    # Network provisioning terraform state S3 bucket region
    network_tf_bucket_region = string
  })
}
variable "Resource" {
  description = "Resource related variables"
  type = object({
    Agent = object({
      ADO-Agent_Name                   = string
      ADO-Agent_ami                    = string
      ADO-Agent_instance_type          = string
      ADO-Agent_root_volume_size       = number
      ADO-Agent_root_volume_type       = string
      ADO-Agent_root_volume_iops       = optional(number, null)
      ADO-Agent_root_volume_throughput = optional(number, null)
    })
    Jump = object({
      JumpServer_Name                   = string
      JumpServer_ami                    = string
      JumpServer_instance_type          = string
      JumpServer_root_volume_size       = number
      JumpServer_root_volume_type       = string
      JumpServer_root_volume_iops       = optional(number, null)
      JumpServer_root_volume_throughput = optional(number, null)
    })
  })
}