data "http" "my_public_ip" {
  url = "https://checkip.amazonaws.com"
}

resource "aws_route53_record" "headscale" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "headscale.alicek106.com"
  type    = "A"
  ttl     = 300
  records = [chomp(data.http.my_public_ip.response_body)]
}
