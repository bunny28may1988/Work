resource "aws_internet_gateway" "ADO-Agent_IGW" {
  vpc_id = aws_vpc.ADO-Agent_VPC.id

  tags = {
    Name = "ADO-Agent_IGW"
  }
}