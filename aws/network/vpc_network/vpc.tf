data "aws_region" "current" {
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({
    "Name" = var.name
  }, var.common_tags)

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    "Name" = var.name
  }, var.common_tags)
}

resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? 1 : 0
  subnet_id     = aws_subnet.public_subnet[0].id
  allocation_id = aws_eip.nat_gateway[0].id

  tags = merge({
    "Name" = var.name
  }, var.common_tags)
}

resource "aws_eip" "nat_gateway" {
  count = var.enable_nat_gateway ? 1 : 0
  vpc   = true
}
