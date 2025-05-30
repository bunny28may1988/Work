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

variable "security" {
  description = "Security related variables"
  type = object({
    sg = object({
      # Name of the security group for the EKS Cluster
      #eks_cluster_sg_name = string
      # Name of the security group for the Jump server
      jump_server_sg_name = string
      # Name of the security group for the VPC
      vpc_sg_name = string
      # Name of the security group for the DevOps agents
      #devops_sg_name = string
      # List of IP address part of the Devops CI/CD agents
      #devops_agent_ips = list(string)
    })

    iam = object({
      # IAM User ARN used in the Devops agents
      devops_iam_user_arn = string
      # IAM Role ARN for the read only user role in console
      read_only_iam_role_arn = string
    })
  })
}

variable "compute" {
  description = "Compute related variables"
  type = object({
  
    ec2 = object({
      # Name of the EC2 machine for Jump Server
      jump_server_name = string
      # Instance type of the EC2 machine for Jump Server
      jump_server_instance_type = string
      # AMI ID to use for EC2 Jump Server
      jump_server_ami_id = string
      # The index of the IP in the CIDR block of the first subnet to use for the Jump Server. Use negative number for choosing an IP from the end of the CIDR block.
      #jump_server_private_ip_index = string
    })
  })
}