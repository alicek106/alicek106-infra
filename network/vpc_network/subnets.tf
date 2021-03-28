locals {
  public_subnet_count  = length(var.subnet_cidr_blocks_public)
  private_subnet_count = length(var.subnet_cidr_blocks_private) # reserve for later
  vpc_id               = aws_vpc.main.id
  az_index_public      = [for block in var.subnet_cidr_blocks_public : split(":", block)[0]]
  az_index_private     = [for block in var.subnet_cidr_blocks_private : split(":", block)[0]] # reserve for later
}

resource "aws_subnet" "public_subnet" {
  count = local.public_subnet_count

  availability_zone       = "${data.aws_region.current.name}${local.az_index_public[count.index]}"
  vpc_id                  = local.vpc_id
  cidr_block              = split(":", var.subnet_cidr_blocks_public[count.index])[1]
  map_public_ip_on_launch = true

  tags = merge({
    "Name"             = "${var.name}.public_subnet.${data.aws_region.current.name}${local.az_index_public[count.index]}"
    "AvailabilityZone" = "${data.aws_region.current.name}${local.az_index_public[count.index]}"
    "Type"             = "public"
  }, var.common_tags)
}

resource "aws_route_table_association" "rt_association_public" {
  count          = local.public_subnet_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "private_subnet" {
  count = local.private_subnet_count

  availability_zone       = "${data.aws_region.current.name}${local.az_index_private[count.index]}"
  vpc_id                  = local.vpc_id
  cidr_block              = split(":", var.subnet_cidr_blocks_private[count.index])[1]
  map_public_ip_on_launch = false

  tags = merge({
    "Name"             = "${var.name}.private_subnet.${data.aws_region.current.name}${local.az_index_private[count.index]}"
    "AvailabilityZone" = "${data.aws_region.current.name}${local.az_index_private[count.index]}"
    "Type"             = "private"
  }, var.common_tags)
}

resource "aws_route_table_association" "rt_association_private" {
  count          = local.private_subnet_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
