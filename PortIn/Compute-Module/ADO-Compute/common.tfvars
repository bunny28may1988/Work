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
  name = "DevOps"
}

compute = {
  ec2 = {
    ADO_Agent_ami           = "ami-06031e2c49c278c8f"
    ADO_Agent_instance_type = "t3.micro"
    ADO_Agent_name          = "ADO-Agent"
    #ADO_Agent_security_group_ids = ["sg-077258ec4ca129f75"]
    #ADO_Agent_subnet_id          = "subnet-02f9081c25cd15218"
  }
  ruut = {
    ruut_volume_size       = 100
    ruut_volume_type       = "gp3"
    ruut_volume_iops       = 3000
    ruut_volume_throughput = 125
    ruut_volume_encrypted  = false
    ruut_volume_kms_key_id = null
  }
  sg = {
    ADO_Agent_SG_Name = "ADO-Agent_SG"
    #ADO_Compute_VPC-ID = "vpc-09e9894e58a67982a"
  }
}