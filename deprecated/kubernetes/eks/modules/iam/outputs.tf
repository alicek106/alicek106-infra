output "node_group_default_instance_profile_arn" {
  value = aws_iam_instance_profile.node_group_default_instance_profile.arn
}

output "node_group_default_role_arn" {
  value = aws_iam_role.node_group_default_role.arn
}
