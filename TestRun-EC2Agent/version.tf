terraform {
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.44.0"
    }
    
  }
  backend "s3" {
       bucket = "kmbl-terraform-state-s3-bucket"
       key = "devopssupplychain-01396/supplychain-devops-01396-op/nonprod/supplychain-01396-devops-EC2DevopsAgentTest-nonprod.tfstate"
       region = "ap-south-1"
   }
}

provider "aws" {
  region  = "ap-south-1"
  assume_role {
    role_arn     = "arn:aws:iam::471112531675:role/role-service-inf-terraform-chainloop-uat-01"
    session_name = "terraform"
  }
}