resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    "Name" = "${var.name}.public"
  }, var.common_tags)
}

resource "aws_route" "public_route_igw" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    "Name" = "${var.name}.private"
  }, var.common_tags)
}

// NAT Gateway는 EIP + 추가비용이 나가기 때문에 상시 띄워놓지는 않는다. 필요할 경우에만 만들어서 쓰고 지울 것.
resource "aws_route" "private_route_igw" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.enable_nat_gateway ? aws_nat_gateway.main[0].id : aws_internet_gateway.main.id
}
