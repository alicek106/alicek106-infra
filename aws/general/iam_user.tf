data "aws_route53_zone" "main" {
  name         = "alicek106.com."
  private_zone = false
}

resource "aws_iam_user" "nixos_backup" {
  name = "nixos-backup-user"
}

resource "aws_iam_user_policy" "nixos_backup" {
  name = "nixos-backup-user-policy"
  user = aws_iam_user.nixos_backup.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "route53:*"
        Resource = "arn:aws:route53:::hostedzone/${data.aws_route53_zone.main.zone_id}"
      },
      {
        Effect   = "Allow"
        Action   = "route53:GetChange"
        Resource = "arn:aws:route53:::change/*"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListHostedZonesByName"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.backup.arn,
          "${aws_s3_bucket.backup.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_access_key" "nixos_backup" {
  user = aws_iam_user.nixos_backup.name
}

output "nixos_backup_access_key_id" {
  value     = aws_iam_access_key.nixos_backup.id
  sensitive = true
}

output "nixos_backup_secret_access_key" {
  value     = aws_iam_access_key.nixos_backup.secret
  sensitive = true
}
