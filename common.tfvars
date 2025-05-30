application = {
  id          = "APP-01396"
  name        = "Supplychain Security"
  owner       = "Kannan Varadharajan"
  manager     = "Sriram Sivakumar"
  tlt         = "Vijay Narayanan"
  rating      = "Medium"
  budget_type = "ctb"
  map-migrated = "migPHEWKGG1FG"
}
environment = {
  name = "NonProd"
}

aws = {
  region          = "ap-south-1"
  assume_role_arn = "arn:aws:iam::471112531675:role/role-service-inf-terraform-chainloop-uat-01"
  #https://dev.azure.com/kmbl-devops/network/_git/network-internal?path=/chainloop-nonprod-account/azure-pipelines.yaml
  network_tf_bucket        = "kmbl-terraform-state-s3-bucket"
  network_tf_bucket_key    = "network/network-internal/nonprod/chainloop/network-network-chainloop-01396-nonprod-dev.tfstate"
  network_tf_bucket_region = "ap-south-1"
}

security = {
  sg = {
    jump_server_sg_name = "EC2_DevopsAgent_NonProd-sg-nonprod"
    vpc_sg_name         = "EC2_DevopsAgent_NonProd-vpc-sg-nonprod"
  }
}

compute = {
  ec2 = {
    jump_server_name             = "EC2_DevopsAgent_NonProd"
    jump_server_instance_type    = "t3a.medium"
    jump_server_ami_id           = "ami-09e034b1e98e8d08b"
  } 
}