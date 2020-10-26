data "aws_lb_listener" "listener_http" {
  load_balancer_arn = "${data.aws_lb.loadbalancer.arn}"
  port              = 80
}

resource "aws_lb_listener_rule" "listener_rule_http" {
  listener_arn = "${data.aws_lb_listener.listener_http.arn}"

  action  {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_groups.arn}"
  }

  condition  {
    field  = "host-header"
    values = ["${var.Service_name}.${var.Service_domain}"]
  }
}