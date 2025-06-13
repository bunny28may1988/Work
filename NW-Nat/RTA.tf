# Associate PRIVATE subnets to PRIVATE route table
resource "aws_route_table_association" "private_subnets" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.main["private"].id
}

# Associate PUBLIC subnets to PUBLIC route table
resource "aws_route_table_association" "public_subnets" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.main["public"].id
}