data "aws_route53_zone" "primary" {
  name = "${var.Service_domain}."
  private_zone = false
}

resource "aws_route53_record" "domain" {
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "${var.Service_name}.${data.aws_route53_zone.primary.name}"
  type    = "A"
  alias {
    name                   = "${data.aws_lb.loadbalancer.dns_name}"
    zone_id                = "${data.aws_lb.loadbalancer.zone_id}"
    evaluate_target_health = true
  }
}
