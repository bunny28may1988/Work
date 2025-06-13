resource "aws_subnet" "private" {
  for_each = {
    "ap-south-1a" = "10.0.1.0/24"
    "ap-south-1b" = "10.0.2.0/24"
  }

  vpc_id            = aws_vpc.ADO-Agent_VPC.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "ADO-Private-${each.key}"
  }
}

resource "aws_subnet" "public" {
  for_each = {
    "ap-south-1c" = "10.0.3.0/24"
  }

  vpc_id            = aws_vpc.ADO-Agent_VPC.id
  cidr_block        = each.value
  availability_zone = each.key

  map_public_ip_on_launch = true

  tags = {
    Name = "ADO-Public-${each.key}"
  }
}