# Application specific variables
variable "application" {
  description = "Application metadata"
  type        = object({
    # Application ID
    id           = string
    # Name of the application
    name         = string
    # Application Owner
    owner        = string
    # Application Manager
    manager      = string
    # Application TLT
    tlt          = string
    # Application Rating
    rating       = string
    # Budget type for application
    budget_type  = string
    # map-migrated for application
    map-migrated = string
  })
}

variable "environment" {
  description = "Environment metadata"
  type        = object({
    # Name of the environment
    name = string
  })
}

variable "aws" {
  description = "AWS environment related metadata"
  type        = object({
    # The AWS region to deploy to.
    region                   = string
    # The provisioning IAM role which terraform can assume
    assume_role_arn          = string
    # Network provisioning terraform state S3 bucket
    network_tf_bucket        = string
    # Network provisioning terraform state S3 bucket key
    network_tf_bucket_key    = string
    # Network provisioning terraform state S3 bucket region
    network_tf_bucket_region = string
  })
}

variable "security" {
  description = "Security related variables"
  type        = object({
    sg = object({
      # Name of the security group for the EKS Cluster
      eks_cluster_sg_name = string
      # Name of the security group for the Jump server
      jump_server_sg_name = string
      # Name of the security group for the VPC
      vpc_sg_name         = string
      # Name of the security group for the DevOps agents
      devops_sg_name      = string
      # List of IP address part of the Devops CI/CD agents
      devops_agent_ips    = list(string)
    })

    iam = object({
      # IAM User ARN used in the Devops agents
      devops_iam_user_arn     = string
      devops_iam_user_name    = string
      # IAM Role ARN for the read only user role in console
      read_only_iam_role_arn  = string
      read_only_iam_role_name = string
    })
  })
}

variable "network" {
  description = "Network related variables"
  type        = map(string)
}

variable "s3_bucket" {
  description = "s3 bucket related variables"
  type        = map(string)
}


variable "compute" {
  description = "Compute related variables"
  type        = object({
    # Container image registry config
    ecr = object({
      # List of repositories to create. Recommended to create one per service or component which is being deployed.
      repositories              = list(string)
      # Does the image tag need to be mutable?
      has_mutable_tags          = bool
      # Whether to enable replication of ECR repositories across regions
      enable_region_replication = bool
      # Region to which replication of ECR images has to be setup
      replication_region        = optional(string, null)
    })

    # Kubernetes cluster config
    eks = object({
      # Name of the EKS Cluster to provision
      cluster_name    = string
      # Name of the ADO Cluster to provision
      # ado_cluster_name = string
      # Version of the EKS Cluster to provision
      cluster_version = string
      # List of node groups to provision
      node_groups     = list(object({
        #AMI of the worker node. Change this only when newer versions are required.
        ami_id               = string
        # Name of the node group
        name                 = string
        # Desired instances in the node group
        desired_size         = number
        # Max capacity of the node group
        max_size             = number
        # Min capacity of the node group
        min_size             = number
        # Node Instance type to be used
        instance_type        = string
        # Size of the EBS volume to mount to in XVDA
        xvda_ebs_volume_size = number
        # Size of the EBS volume to mount to in XVDF
        xvdf_ebs_volume_size = number
        # Type of the EBS volume to mount to
        ebs_volume_type      = string
        # IOPS requirement for EBS volume
        ebs_iops             = number
        # Throughput requirement for EBS volume
        ebs_throughput       = number
      }))
      # ado_node_groups = list(object({
      #   #AMI of the worker node. Change this only when newer versions are required.
      #   ami_id               = string
      #   # Name of the node group
      #   name                 = string
      #   # Desired instances in the node group
      #   desired_size         = number
      #   # Max capacity of the node group
      #   max_size             = number
      #   # Min capacity of the node group
      #   min_size             = number
      #   # Node Instance type to be used
      #   instance_type        = string
      #   # Size of the EBS volume to mount to in XVDA
      #   xvda_ebs_volume_size = number
      #   # Size of the EBS volume to mount to in XVDF
      #   xvdf_ebs_volume_size = number
      #   # Type of the EBS volume to mount to
      #   ebs_volume_type      = string
      #   # IOPS requirement for EBS volume
      #   ebs_iops             = number
      #   # Throughput requirement for EBS volume
      #   ebs_throughput       = number
      # }))
    })

    ec2 = object({
      # Name of the EC2 machine for Jump Server
      jump_server_name             = string
      # Instance type of the EC2 machine for Jump Server
      jump_server_instance_type    = string
      # AMI ID to use for EC2 Jump Server
      jump_server_ami_id           = string
      # The index of the IP in the CIDR block of the first subnet to use for the Jump Server. Use negative number for choosing an IP from the end of the CIDR block.
      jump_server_private_ip_index = string
    })
  })
}

variable "generic_secrets" {
  description = "Secrets to create in secrets manager"
  type        = object({
    apps = map(object({
      # prefix for secrets, can be namespace
      namespace    = string
      # Lists of secret to create
      secret_names = optional(list(string), [])
    }))
  })
  default = {
    apps = {}
  }
}

variable "cluster" {
  description = "EKS Cluster related variables"
  type        = object({
    # Lists of service deployed in the cluster
    services = map(object({
      # Namespace in which the service is deployed under
      namespace    = string
      # Lists of secret names this service needs
      secret_names = optional(list(string), [])
      # IAM Policies to associate to iam role
      policies     = object({
        # Does this need read write access to elastic load balancer
        elb_rw  = optional(bool, false)
        # Does this need read write access to RDS clusters
        rds_rw  = optional(bool, false)
        # Does this need to write to cloudwatch logs
        logs_rw = optional(bool, false)
        # Does this need to write to specific bucket
        s3_bucket_rw = optional(string, "")
        # Does this need to write to dynamodb table
        dynamodb_table_rw = optional(string, "")
        # Does this need to write to eks
        eks_rw  = optional(bool, false)
        # Does this need kms permissions
        kms_rw = optional(bool, false)
        # Does this need eks_ro permissions
        eks_ro = optional(bool, false)
      })
    }))
  })
}

variable cross_account_secret_access {
  description = "Cross account secret access"
  type        = map(object({
    # Name of the secret
    name                  = string
    # Destination role arn
    destination_role_arns = list(string)
  }))
  default = {}
}

variable "data_catalog" {
  description = "Data catalog related variables"
  type        = map(object({
    # Glue catalog id
    catalog_id            = optional(string)
    # Glue database name
    catalog_database_name = optional(string)
    # Glue table name
    catalog_table_name    = optional(string)
    # Athena workgroup output location
    location_uri          = optional(string)
    # Athena workgroup name
    workgroup_name        = optional(string)
    # Athena workgroup output location
    output_location       = optional(string)
  }))
}