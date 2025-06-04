data "terraform_remote_state" "NWSateFile" {
  backend = "s3"
  config = {
    bucket = "skilluputilities"
    key    = "terraform/Workspace/EC2-DevOpsAgent/Network/networkterraform.tfstate"
    region = "ap-south-1"
  }
}


locals {
  network_sg = data.terraform_remote_state.NWSateFile.outputs.all_security_group_ids["Network_VPC-SG"]
  vpc_id  = data.terraform_remote_state.NWSateFile.outputs.vpc_id
  vpc_cidr = data.terraform_remote_state.NWSateFile.outputs.vpc_cidr_block
  subnet_ids = data.terraform_remote_state.NWSateFile.outputs.private_subnet_ids
 }

output "vpc-id" {
  value = local.vpc_id
}

output "SG_ID" {
  value = local.network_sg
}

output "subnet_ids" {
  value = [for sn in local.subnet_ids : sn]
}

output "vpc_cidr" {
  value = local.vpc_cidr
}