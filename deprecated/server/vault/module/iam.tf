data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vault" {
  statement {
    sid       = "consul"
    effect    = "Allow"
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
  }

  statement {
    sid    = "vault"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrpyt",
      "kms:DescribeKey",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "vault" {
  name   = "vault"
  policy = data.aws_iam_policy_document.vault.json
}

resource "aws_iam_role" "vault" {
  name               = "vault"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "vault" {
  role       = aws_iam_role.vault.name
  policy_arn = aws_iam_policy.vault.arn
}

resource "aws_iam_instance_profile" "vault" {
  name = "vault"
  role = aws_iam_role.vault.name
}
