# SSM Agent role
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = module.eks.worker_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = module.eks.worker_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
