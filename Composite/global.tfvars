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
  assume_role_arn          = "arn:aws:iam::471112531675:role/role-service-inf-terraform-chainloop-uat-01"
  network_tf_bucket        = "kmbl-terraform-state-s3-bucket"
  network_tf_bucket_key    = "network/network-internal/nonprod/poc/chainloop/network-network-supply-chain-01396-nonprod-poc.tfstate"
  network_tf_bucket_region = "ap-south-1"
}

Resource = {
  EC2 = {
    ADO-Agent_Name                   = "ADO-BuildAgent"
    ADO-Agent_ami                    = "ami-0580abca8c40953e1"
    ADO-Agent_instance_type          = "c6a.2xlarge"
    ADO-Agent_root_volume_size       = 500
    ADO-Agent_root_volume_type       = "gp3"
    ADO-Agent_root_volume_iops       = 3000
    ADO-Agent_root_volume_throughput = 125
  }
  NIC = {
    ADO-NIC_NAME = "ADO-BuildAgent-NIC"
    ADO-NIC_IP   = ["10.90.6.60"]
  }
}