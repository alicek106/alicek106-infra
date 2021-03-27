output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = aws_subnet.subnet.*.id
}

output "route_table_id" {
  value = aws_route_table.route_table.id
}
