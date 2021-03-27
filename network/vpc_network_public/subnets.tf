locals {
  subnet_count = length(var.subnet_cidr_blocks)
  vpc_id       = aws_vpc.main.id
  az_index     = [for block in var.subnet_cidr_blocks : split(":", block)[0]]
}

resource "aws_subnet" "subnet" {
  count = local.subnet_count

  availability_zone       = "${data.aws_region.current.name}${local.az_index[count.index]}"
  vpc_id                  = local.vpc_id
  cidr_block              = split(":", var.subnet_cidr_blocks[count.index])[1]
  map_public_ip_on_launch = true

  tags = merge({
    "Name"             = "${var.name}.public_subnet.${data.aws_region.current.name}${local.az_index[count.index]}"
    "AvailabilityZone" = "${data.aws_region.current.name}${local.az_index[count.index]}"
    "Type"             = "public"
  }, var.common_tags)
}

resource "aws_route_table_association" "association" {
  count          = local.subnet_count
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.route_table.id
}
