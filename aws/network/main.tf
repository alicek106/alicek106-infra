module "vpc_network" {
  source = "./vpc_network"

  name                       = terraform.workspace
  vpc_cidr_block             = local.current_vpc_cidr_block
  subnet_cidr_blocks_public  = local.current_subnet_cidr_blocks.public
  subnet_cidr_blocks_private = local.current_subnet_cidr_blocks.private
  common_tags                = local.common_tags
  enable_nat_gateway         = false
}
