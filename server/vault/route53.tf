data "aws_route53_zone" "alicek106" {
  name = "alicek106.com."
}

resource "aws_route53_record" "vault" {
  zone_id = data.aws_route53_zone.alicek106.zone_id
  name    = "vault.alicek106.com"
  type    = "A"
  ttl     = "300"
  records = aws_instance.vault.*.private_ip
}
