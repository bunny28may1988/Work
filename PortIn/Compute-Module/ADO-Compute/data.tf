data "terraform_remote_state" "NWSateFile" {
  backend = "s3"
  config = {
    bucket = "skilluputilities"
    key    = "terraform/Workspace/EC2-DevOpsAgent/Network/networkterraform.tfstate"
    region = "ap-south-1"
  }
}

