data "aws_lb_listener" "listener_https_pub" {
  load_balancer_arn = "${data.aws_lb.loadbalancer_pub.arn}"
  port              = 443
}

resource "aws_lb_listener_rule" "listener_rule_https_pub" {
  listener_arn = "${data.aws_lb_listener.listener_https_pub.arn}"

  action  {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_groups.arn}"
  }

  condition  {
    field  = "host-header"
    values = ["${var.Service_name}.${var.Service_domain}"]
  }
}