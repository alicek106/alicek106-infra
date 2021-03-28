# ref: https://stackoverflow.com/questions/64080219/terraform-output-object-with-multiple-attributes-for-each-of-for-resources
output "vpc_id" {
  value = module.vpc_network.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc_network.public_subnet_ids
}

output "public_route_table_id" {
  value = module.vpc_network.public_route_table_id
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

