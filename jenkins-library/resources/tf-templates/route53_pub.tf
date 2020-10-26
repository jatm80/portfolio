data "aws_route53_zone" "primary_pub" {
  name = "${var.Service_domain}."
  private_zone = false
}

resource "aws_route53_record" "domain_pub" {
  zone_id = "${data.aws_route53_zone.primary_pub.zone_id}"
  name    = "${var.Service_name}.${data.aws_route53_zone.primary_pub.name}"
  type    = "A"
  alias {
    name                   = "${data.aws_lb.loadbalancer_pub.dns_name}"
    zone_id                = "${data.aws_lb.loadbalancer_pub.zone_id}"
    evaluate_target_health = true
  }
}
