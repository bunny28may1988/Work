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
  backend "s3" {}
}

provider "aws" {
  region = var.aws.region

  assume_role {
    # Currently we run the terraform provisioning in Cloud team owned AFT account which has assume role access to the AWS account.
    role_arn = var.aws.assume_role_arn
  }
}