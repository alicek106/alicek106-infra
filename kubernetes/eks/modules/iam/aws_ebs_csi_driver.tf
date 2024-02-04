data "aws_iam_policy_document" "ebs_csi_driver" {
  count = var.enable_aws_ebs_csi_driver ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateSnapshot",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumesModifications"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateTags"
    ]
    resources = [
      "arn:aws:ec2:*:*:volume/*",
      "arn:aws:ec2:*:*:snapshot/*"
    ]
    condition {
      test = "StringEquals"
      values = [
        "CreateVolume",
        "CreateSnapshot"
      ]
      variable = "ec2:CreateAction"
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteTags"
    ]
    resources = [
      "arn:aws:ec2:*:*:volume/*",
      "arn:aws:ec2:*:*:snapshot/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateVolume"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      values   = ["true"]
      variable = "aws:RequestTag/ebs.csi.aws.com/cluster"
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateVolume"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      values   = ["*"]
      variable = "aws:RequestTag/CSIVolumeName"
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteVolume"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      values   = ["*"]
      variable = "ec2:ResourceTag/CSIVolumeName"
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteVolume"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      values   = ["true"]
      variable = "ec2:ResourceTag/ebs.csi.aws.com/cluster"
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteSnapshot"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      values   = ["*"]
      variable = "ec2:ResourceTag/CSIVolumeSnapshotName"
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteSnapshot"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      values   = ["true"]
      variable = "ec2:ResourceTag/ebs.csi.aws.com/cluster"
    }
  }
}

resource "aws_iam_policy" "ebs_csi_driver" {
  count  = var.enable_aws_ebs_csi_driver ? 1 : 0
  name   = "k8s-${var.cluster_name}-ebs-csi-driver"
  policy = data.aws_iam_policy_document.ebs_csi_driver[0].json
}

data "aws_iam_policy_document" "ebs_csi_driver_assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:sub"
      values   = ["system:serviceaccount:aws-ebs-csi-driver:ebs-*"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver" {
  count              = var.enable_aws_ebs_csi_driver ? 1 : 0
  name               = "k8s-${var.cluster_name}-ebs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  count      = var.enable_aws_ebs_csi_driver ? 1 : 0
  role       = aws_iam_role.ebs_csi_driver[0].name
  policy_arn = aws_iam_policy.ebs_csi_driver[0].arn
}
