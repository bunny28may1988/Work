application = {
  id           = "APP-01396"
  name         = "DevOps"
  owner        = "Kannan Varadharajan"
  manager      = "Mohan Pemmaraju"
  tlt          = "Vijay Narayanan"
  rating       = "Medium"
  budget_type  = "ctb"
  map-migrated = "migPHEWKGG1FG"
}

environment = {
  name = "nonprod"
}

aws = {
  region                   = "ap-south-1"
  assume_role_arn          = "arn:aws:iam::392568849431:role/TerraformAssumeRole"
  network_tf_bucket        = "skilluputilities"
  network_tf_bucket_key    = "terraform/Workspace/EC2-DevOpsAgent/Network/networkterraform.tfstate"
  network_tf_bucket_region = "ap-south-1"
}

Resource = {
  Agent = {
    ADO-Agent_Name                   = "ADO-BuildAgent"
    ADO-Agent_ami                    = "ami-0b09627181c8d5778"
    ADO-Agent_instance_type          = "t2.micro"
    ADO-Agent_root_volume_size       = 50
    ADO-Agent_root_volume_type       = "gp3"
    ADO-Agent_root_volume_iops       = 3000
    ADO-Agent_root_volume_throughput = 125
  }
  Jump = {
    JumpServer_Name                   = "JumpServer"
    JumpServer_ami                    = "ami-0b09627181c8d5778"
    JumpServer_instance_type          = "t2.micro"
    JumpServer_root_volume_size       = 50
    JumpServer_root_volume_type       = "gp3"
    JumpServer_root_volume_iops       = 3000
    JumpServer_root_volume_throughput = 125
  }
}
