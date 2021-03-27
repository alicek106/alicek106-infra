module "vpc_network_public" {
  source   = "./vpc_network_public"
  for_each = { for vpc_name in local.public_vpc_list : vpc_name => vpc_name }

  name               = each.key
  region             = local.regions[each.key]
  vpc_cidr_block     = local.vpc_cidr_blocks[each.key]
  subnet_cidr_blocks = local.subnet_cidr_blocks_public[each.key]
  common_tags        = local.common_tags
}
