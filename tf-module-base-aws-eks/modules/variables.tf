variable "node_ami_auto_update" {
  type        = bool
  description = "Enable or disable automatic updates for the EKS node AMI"
  default   =  false
}

variable "cluster_subnet_ids" {
  type        = list(string)
  description = "List of existing subnet IDs where the EKS cluster and node groups will be deployed"
  nullable    = false  
}

variable "nodegroup_subnet_ids" {
  type        = list(string)
  description = "List of existing subnet IDs where the EKS cluster and node groups will be deployed"
  nullable    = false  
}

variable "vpc_id" {
  type        = string
  description = "ID of the existing VPC where the EKS cluster will be deployed"
  nullable    = false 
}

variable "region" {
  type        = string
  description = "AWS region where resources will be created"
  default     = "ap-south-1"
  nullable    = false

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[1-9]{1}$", var.region))
    error_message = "Must be a valid AWS region format (e.g., us-west-2)."
  }
}

variable "environment" {
  type        = string
  description = "Environment for the cluster (dev/staging/prod)"
  nullable    = false

  // validation {
  //   condition     = contains(["dev", "staging", "prod", "dr",""], var.environment)
  //   error_message = "Environment must be one of: dev, staging, prod."
  // }
}


variable "cluster_version" {
  type        = string
  description = "Kubernetes version of eks cluster"
  nullable    = false
}

variable "jumpserver_instancetype" {
  description = "instance type for Jumpserver"
  default     = "t3.medium"
  type = string
}

variable "jumpserver_instanceprofile" {
  description = "instance profile for Jumpserver"
  default     = ""
  type = string
}

variable "jumpserver_userdata" {
  type = string
  description = "user data script for EC2 instance initialization"
  default = ""
}

variable "nodegroups" {
  type = map(object({
    instance_type = string
    ebs_size = list(string)
    min_nodes = string
    max_nodes = string
    desired_nodes = string
    ami_family  = string
    subnets = optional(list(string))
    taints = list(list(string))
    labels = map(string)
    update_config = map(string)
  }))
  description = "Configuration map for EKS node groups including instance specifications, scaling parameters, and Kubernetes labels/taints"
}

variable "ebs_kms_key" {
  type = string
  
}
variable "azure_devops_agent_ips" {
  type = list(string)
  description = "List of Azure DevOps agent IP addresses that require access to the cluster"
  default = []
}

variable "jumpserver_security_group" {
  default = null
  type = string
  description = "Security group ID to be associated with the jumpserver"
}

variable "create_jumpserver" {
  default = true
  type = bool
  
}

variable "jumpserver_ami" {
  type = string
  default = ""
  
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["audit"]
}

variable "addons" {
  type = map(object({
    name = string
    version = optional(string)
    most_recent = optional(bool, false)
    resolve_conflicts = optional(string, "OVERWRITE")
  }))
  description = "Map of EKS add-ons to be enabled for the cluster with their configurations"
  default = {
    coredns = {
      name = "coredns"
    },
    vpc-cni = {
      name = "vpc-cni" 
    },
    kube-proxy = {
      name = "kube-proxy"
    }
  }
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry"
  type        = bool
  default     = false
}

variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any
  default     = {}
}

variable "proxy_ip" {
  type = string
  description = "Proxy server IP address for cluster outbound connections"
  default = "10.10.2.88:8080"
}

variable "no_proxy_ip" {
  type = string
  description = "IP addresses or CIDR ranges to exclude from proxy routing"
  default = "127.0.0.1"
}

variable "user_data_version" {
  type = string
  description = "Version tag for the user data configuration"
  default = "1"
}

variable "project_name" {
  type        = string
  description = "Identifier for the project this infrastructure belongs to"
  default     = null
}

variable "application-id" {
  type        = string
  default     = null
  description = "application ID for the account"
}

variable "application-manager" {
  type        = string
  default     = null
  description = "manager name who owns the application"
}

variable "application-name" {
  type        = string
  default     = null
  description = "name of the application"
}

variable "application-owner" {
  type        = string
  default     = null
  description = "manager name who owns the application"
}

variable "application-rating" {
  type        = string
  default     = null
  description = "rating of the application low | high"
}

variable "budget-type" {
  type        = string
  default     = null

  }

variable "entity" {
  type        = string
  default     = null
  description = "type of entity"
}

variable "vertical-tlt" {
  type        = string
  default     = null
  description = "value"
}

variable "ticket-id" {
  type        = string
  default     = null
  description = "ticket ID for the infra creation request"
}