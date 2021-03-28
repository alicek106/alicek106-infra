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

resource "aws_route" "private_route_igw" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
