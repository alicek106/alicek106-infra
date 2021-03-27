resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    "Name" = var.name
  }, var.common_tags)
}

resource "aws_route" "route_igw" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
