# Define route data as a local variable for reuse
locals {
  route_tables = {
    public = {
      name = "ADO-Agent-Public-RouteTable"
      routes = [
        {
          cidr_block = "0.0.0.0/0"
          gateway_id = aws_internet_gateway.ADO-Agent_IGW.id
        }
      ]
    }

    private = {
      name = "ADO-Private-RT"
      routes = [
        {
          cidr_block     = "0.0.0.0/16"
          nat_gateway_id = aws_nat_gateway.nat.id
        }
      ]
    }
  }
}

resource "aws_route_table" "main" {
  for_each = local.route_tables

  vpc_id = aws_vpc.ADO-Agent_VPC.id

  dynamic "route" {
    for_each = each.value.routes
    content {
      cidr_block     = try(route.value.cidr_block, null)
      gateway_id     = try(route.value.gateway_id, null)
      nat_gateway_id = try(route.value.nat_gateway_id, null)
    }
  }

  tags = merge(local.default_tags, {
    Name = each.value.name
  })
}