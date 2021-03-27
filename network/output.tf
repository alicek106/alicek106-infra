# ref: https://stackoverflow.com/questions/64080219/terraform-output-object-with-multiple-attributes-for-each-of-for-resources
output "vpc_id" {
  value = {
    for name, details in module.vpc_network_public :
    name => details.vpc_id
  }
}

output "vpc_subnet_ids" {
  value = {
    for name, details in module.vpc_network_public :
    name => details.subnet_ids
  }
}

output "vpc_route_table_id" {
  value = {
    for name, details in module.vpc_network_public :
    name => details.route_table_id
  }
}
