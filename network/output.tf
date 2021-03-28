# ref: https://stackoverflow.com/questions/64080219/terraform-output-object-with-multiple-attributes-for-each-of-for-resources
output "vpc_id" {
  value = module.vpc_network.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc_network.public_subnet_ids
}

# return subnet id, cidr
output "public_subnet" {
  value = {
    for idx, az in local.current_subnet_cidr_blocks.public :
    "${local.current_region}${split(":", az)[0]}" => {
      id   = module.vpc_network.public_subnet_ids[idx]
      cidr = split(":", az)[1]
    }
  }
}

output "public_route_table_id" {
  value = module.vpc_network.public_route_table_id
}

output "private_subnet" {
  value = {
    for idx, az in local.current_subnet_cidr_blocks.private :
    "${local.current_region}${split(":", az)[0]}" => {
      id   = module.vpc_network.private_subnet_ids[idx]
      cidr = split(":", az)[1]
    }
  }
}

output "private_subnet_ids" {
  value = module.vpc_network.private_subnet_ids
}

output "private_route_table_id" {
  value = module.vpc_network.private_route_table_id
}

output "region" {
  value = local.current_region
}
