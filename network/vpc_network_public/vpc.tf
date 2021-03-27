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
