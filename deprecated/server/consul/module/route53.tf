data "aws_route53_zone" "alicek106" {
  name = "alicek106.com."
}

resource "aws_route53_record" "consul" {
  zone_id = data.aws_route53_zone.alicek106.zone_id
  name    = "consul.alicek106.com"
  type    = "A"
  ttl     = "300"
  records = aws_instance.consul.*.private_ip
}
