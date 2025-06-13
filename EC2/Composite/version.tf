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
    bucket = "kmbl-terraform-state-s3-bucket"
    key    = "devopssupplychain-01396/supplychain-devops-01396-ado_ec2/nonprod/supplychain-01396-devops-ado_ec2-nonprod.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = var.aws.region

  assume_role {
    role_arn = var.aws.assume_role_arn
  }
}