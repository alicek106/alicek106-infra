data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "consul" {
  statement {
    sid       = "consul"
    effect    = "Allow"
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "consul" {
  name   = "consul"
  policy = data.aws_iam_policy_document.consul.json
}

resource "aws_iam_role" "consul" {
  name               = "consul"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "consul" {
  role       = aws_iam_role.consul.name
  policy_arn = aws_iam_policy.consul.arn
}

resource "aws_iam_instance_profile" "consul" {
  name = "consul"
  role = aws_iam_role.consul.name
}
