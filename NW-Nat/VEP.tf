resource "aws_vpc_endpoint" "ADO-Agent_s3-gateway" {
  vpc_id            = aws_vpc.ADO-Agent_VPC.id
  service_name      = "com.amazonaws.ap-south-1.s3"
  vpc_endpoint_type = "Gateway"

  # Correct usage for route table from for_each
  route_table_ids = [aws_route_table.main["private"].id]

  tags = merge(local.default_tags, {
    Name = "ADO-S3-Gateway-Endpoint"
  })
}