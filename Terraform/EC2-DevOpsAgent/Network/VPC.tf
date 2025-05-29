resource "aws_vpc" "ADO-Agent_VPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "ADO-Agent_VPC"
  }
}