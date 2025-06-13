terraform {
  required_version = "~> 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "skilluputilities"
    key    = "terraform/Workspace/EC2-DevOpsAgent/Network/networkterraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = "ap-south-1"
  #profile = "default"

  assume_role {
    role_arn = "arn:aws:iam::392568849431:role/TerraformAssumeRole"
  }
}