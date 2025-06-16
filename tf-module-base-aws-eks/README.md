# AWS EKS Terraform Module

This module creates and manages an AWS Elastic Kubernetes Service (EKS) cluster with multiple node groups and additional supporting resources.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 5.0.0 |

## Features

- Creates and manages an EKS cluster with multiple node groups
- Supports both Bottlerocket and Amazon Linux 2023 AMI families
- Configures multiple EBS volumes for node groups
- Implements cluster access entries for IAM role-based access
- Optional jump server creation for cluster management
- Configures EKS add-ons (CoreDNS, VPC-CNI, kube-proxy)
- Enables CloudWatch logging for audit, API, authenticator, and controller manager


## Inputs

| Name | Description | Type | Default | Required | Update Triggers resource replacement/recreation  |
|------|-------------|------|---------|:--------:|:--------:|
| application-id | The application ID | `string` | n/a | yes | Cluster: No <br /> Node: No |
| application-name | The application name | `string` | n/a | yes |Cluster: Yes <br /> Node: Yes  |
| region | AWS region to deploy resources | `string` | n/a | yes | Cluster: Yes <br /> Node: Yes  |
| vpc_id | ID of the VPC | `string` | n/a | yes | Cluster: Yes <br /> Node: Yes  |
| cluster_subnet_ids | List of subnet IDs for the EKS cluster | `list(string)` | n/a | yes |No |
| nodegroup_subnet_ids | List of subnet IDs for the EKS managed node groups | `list(string)` | n/a | yes |No |
| cluster_version | Kubernetes version to use for the EKS cluster | `string` | n/a | yes | No |
| environment | Environment (e.g., dev, prod) | `string` | n/a | yes |Cluster: Yes <br /> Node: Yes  |
| cluster_enabled_log_types | List of log types to enable for the EKS cluster | `list(string)` | `["audit"]` | no |No |
| addons | Map of EKS add-ons to enable (aws recommended version gets installed by default unless a version is specified) | `Map(object)` | `coredns = { name = "coredns" }, vpc-cni = { name = "vpc-cni" }, kube-proxy = { name = "kube-proxy" } }` | no |No |
| azure_devops_agent_ips | List of IPs allowed to access the cluster from Azure DevOps | `list(string)` | `[]` | no |No |
| node_ami_auto_update | Enable or disable automatic AMI updates for node groups | `bool` | `false` | no |Cluster: No <br /> Node: Yes (rolling update)  |
| ebs_kms_key | ARN of the KMS key for EBS encryption | `string` | n/a | yes |Cluster: Yes <br /> Node: Yes  |
| nodegroups | Map of node groups configurations | `map(object)` | n/a | yes |Cluster: No <br /> Node: Yes  |
| proxy_ip | Proxy IP address for cluster | `string` | `"10.10.2.88:8080"` | no |Cluster: No <br /> Node: Yes  |
| no_proxy_ip | No proxy IP address for cluster | `string` | `"127.0.0.1"` | no |Cluster: No <br /> Node: Yes  |
| user_data_version | Version of user data script | `string` | `"1"` | no |
| access_entries | Map of access entries for the EKS cluster | `map(object)` | n/a | No |No |
| create_jumpserver | Whether to create a jump server | `bool` | `true` | no |No |
| jumpserver_instancetype | EC2 instance type for the jump server | `string` | `"t3.medium"` | no |Cluster: No <br /> Node: No <br /> Jumpserver: Yes |
| jumpserver_instanceprofile | Instance profile for the jump server | `string` | `""` | no |No |
| jumpserver_security_group | Security group ID for the jump server | `string` | n/a | No |No |
| jumpserver_userdata | User data script for EC2 jump server | `string` | n/a | yes |No |
| jumpserver_ami | Hardened AMI for jumphost | `string` | Hardened AMI provided by COE team | No |No |

### Nodegroups Configuration

The `nodegroups` parameter accepts a map of node group configurations with the following structure:

```hcl
nodegroups = {
  <group_name> = {
    instance_type           = string
    ebs_size                = list(string)  # Sizes in GB for multiple EBS volumes
    min_nodes               = number
    desired_nodes           = number
    max_nodes               = number
    ami_family              = string        # "bottlerocket" or "al2023"
    taints                  = list(object)
    labels                  = map(string)
    update_config = {
      max_unavailable_percentage = number
      # OR max_unavailable       = number
    }
  }
}
```

### Access Entries Configuration

The `access_entries` parameter configures cluster access and follows this structure:

```hcl
access_entries = {
  <entry_name> = {
    principal_arn = string
    type          = string  # "STANDARD" or other access type
    policy_associations = {
      <policy_name> = {
        policy_arn   = string
        access_scope = {
          type       = string  # "cluster" or other scope type
        }
      }
    }
  }
}
```

## Provider Configuration 

Ensure to use/append the below provider configuration for your AWS provider. This ensures that all the resources are tagged with necessary tags:

```hcl
provider "aws" {
  # ... other configuration ...
  default_tags{
    tags = {
      environment         = 
      project_name        = "<project>"
      application-id      = "<app-id>"
      application-name    = "<app-name>"
      application-manager = "<App-manager>"
      application-owner   = "<app-owner>"
      application-rating  = "<application-rating>"   
      budget-type         = "<budget-type>"
      entity              = "<entity>"
      vertical-tlt        = "<tlt-name>"
      ticket-id           = "<ticket>"
    }
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| cluster_arn | ARN of the EKS cluster |
| cluster_endpoint | Endpoint for the Kubernetes API server |
| cluster_certificate_authority_data | Base64 encoded certificate data required to communicate with the cluster |
| cluster_name | Name of EKS cluster |
| oidc_provider | OIDC url |
| nodegroup_arns | ARN of nodegroups|
| nodegroup_amis | AMI used in each nodegroup|
| jumpserver_ip | IP of jumphost|
| jumpserver_id | Instance-Id of jump serve|
| jumpserver_security_group_id | Security group of Jumpserver(created within the module)|
| cluster_security_group_id | ID of the EKS cluster security group|
| nodegroup_security_group_id | ID of the EKS nodegroup security group|
| cluster_role_arn | ARN of the IAM role used by the EKS cluster|
| nodegroup_role_arn | ARN of the IAM role used by the EKS nodegroups|
| installed_addon_names | List of all EKS add-on names installed|
| installed_addon_versions | Map of installed EKS add-on names and their versions|


## Usage

Complete Example:

```hcl
module "eks-main" {
  source = "<module-source-path>/tf-module-base-aws-eks/modules"
  
  application-id           = "app-000"
  application-name         = "app-name"
  cluster_subnet_ids       = ["subnet-028ae0be3fbf7836a", "subnet-07d2b2e4259a74114"]
  nodegroup_subnet_ids     = ["subnet-028ae0be3fbf7836a", "subnet-07d2b2e4259a74114"]
  vpc_id                   = "vpc-12345"
  region                   = "ap-south-2"
  cluster_version          = "1.31"
  environment              = "dev"
  cluster_enabled_log_types = ["audit", "api", "authenticator", "controllerManager"]
  addons                   = {
        coredns = {
          name = "coredns"
          version = "v1.11.4-eksbuild.10"

        },
        vpc-cni = {
          name = "vpc-cni"
          most_recent = true
        },
        kube-proxy = {
          name = "kube-proxy"

        }
      }
  azure_devops_agent_ips   = ["1.1.1.1/32","2.2.2.2/32"]
  node_ami_auto_update     = false
  ebs_kms_key              = "arn:aws:kms:ap-south-2:071833543603:key/0aa23b1d-fbf5-479a-aeac-ccca4f89a6b9"
  
  nodegroups = {
    group1 = {
      instance_type           = "t3.2xlarge"
      ebs_size                = ["100","150","125","50"]
      min_nodes               = 1
      desired_nodes           = 1
      max_nodes               = 5
      ami_family              = "bottlerocket"
      taints                  = []
      labels = {
        Environment = "DEV"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      update_config = {
        max_unavailable_percentage = 100
      }
    }
    group2 = {
      instance_type           = "t3.large"
      ebs_size                = ["90","80","70"]
      min_nodes               = 1
      desired_nodes           = 1
      max_nodes               = 1
      ami_family              = "al2023"
      taints                  = []
      labels = {
        Environment = "PROD"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      update_config = {
        max_unavailable_percentage = 100
      }
    }
  }
  
  proxy_ip                 = ""
  no_proxy_ip              = ""
  user_data_version        = "1"
  
  access_entries = {
    jump_server = {
      principal_arn = "arn:aws:iam::071833543603:role/sample-instance-profile-role"
      type = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    devops_user = {
      principal_arn = "arn:aws:iam::071833543603:role/KarpenterNodeRole-ec2-user-karpenter-demo"
      type = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
  
  create_jumpserver           = true
  jumpserver_instancetype     = "t3.medium"
  jumpserver_ami = "ami-00181f3e8e3fbc1d1"
  jumpserver_instanceprofile  = ""
  jumpserver_security_group   = "sg-12345"
  jumpserver_userdata                = file("${path.module}/ec2_user_data.sh")
}
```
Minimalistic Example

```hcl
module "eks-main" {
    source = "#{AgentPath}#/tf-module-base-aws-eks/modules"
    providers = {
        aws                     = aws.provisioning-role
    }
    application-id           = "app-000"
    application-name         = "app-name"
    cluster_subnet_ids       = ["subnet-028ae0be3fbf7836a", "subnet-07d2b2e4259a74114"]
    nodegroup_subnet_ids     = ["subnet-028ae0be3fbf7836a", "subnet-07d2b2e4259a74114"]
    vpc_id = "vpc-12345"
    region = "ap-south-1"
    cluster_version = "1.30"
    environment = "dev"
    ebs_kms_key = 
    nodegroups = {
      group1 = {
        instance_type           = "t3.2xlarge"
        ebs_size                = ["100","150","125","50"]
        min_nodes               = 1
        desired_nodes           = 1
        max_nodes               = 5
        ami_family              = "bottlerocket"
        taints                  = []
        labels = {
          Environment = "DEV"
          GithubRepo  = "terraform-aws-eks"
          GithubOrg   = "terraform-aws-modules"
        }
        update_config = {
          max_unavailable_percentage = 100
        }
      }
  }
    jumpserver_security_group = "sg-12345"
    jumpserver_userdata = file("${path.module}/ec2_user_data.sh")
}
```
