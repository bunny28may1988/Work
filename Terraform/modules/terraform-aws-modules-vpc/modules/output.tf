output "vpc_id" {
  value = aws_vpc.main
}

output "igw_id" {
  value = aws_internet_gateway.igw
}
