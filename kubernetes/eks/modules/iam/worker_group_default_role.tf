locals {
  iam_role_policy_prefix     = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
  node_default_iam_role_name = "k8s-${var.cluster_name}-node-default"
}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "node_group_default_role" {
  name                  = local.node_default_iam_role_name
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "node_group_default_role" {
  for_each = toset([
    "${local.iam_role_policy_prefix}/AmazonEKSWorkerNodePolicy",
    "${local.iam_role_policy_prefix}/AmazonEC2ContainerRegistryReadOnly",
    "${local.iam_role_policy_prefix}/AmazonEKS_CNI_Policy",
  ])

  policy_arn = each.value
  role       = aws_iam_role.node_group_default_role.name
}

resource "aws_iam_instance_profile" "node_group_default_instance_profile" {
  role = aws_iam_role.node_group_default_role.name
  name = local.node_default_iam_role_name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.node_group_default_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.node_group_default_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
