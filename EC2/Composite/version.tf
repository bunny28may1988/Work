terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.44.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13.0"
    }
  }
  backend "s3" {
    bucket = "skilluputilities"
    key    = "terraform/Workspace/EC2-DevOpsAgent/EC2/ec2terraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = var.aws.region

  assume_role {
    role_arn = var.aws.assume_role_arn
  }
}