# ref: https://stackoverflow.com/questions/64080219/terraform-output-object-with-multiple-attributes-for-each-of-for-resources
output "vpc_id_public" {
  value = {
    for name, details in merge(module.vpc_network_public_apne2) :
    name => details.vpc_id
  }
}

output "vpc_subnet_ids_public" {
  value = {
    for name, details in merge(module.vpc_network_public_apne2) :
    name => details.subnet_ids
  }
}

output "vpc_route_table_id_public" {
  value = {
    for name, details in merge(module.vpc_network_public_apne2) :
    name => details.route_table_id
  }
}

output "regions" {
  value = local.regions
}

