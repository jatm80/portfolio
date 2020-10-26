
data "aws_lb" "loadbalancer" {
  name = "${var.Environment}-${var.Project}-${var.Role[2]}"
}

resource "aws_lb_target_group" "target_groups" {
  name = "${var.Environment}-${var.ApplicationShortName}-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${lookup("${var.vpc_id["${var.Environment}"]}", "${var.Project}-${var.Region}")}"
  target_type = "instance"
  deregistration_delay = "${var.ecs_drain_seconds["${var.Environment}"]}"
  health_check  {
      port = "traffic-port"
      protocol = "HTTP"
      path = "/healthcheck"
      healthy_threshold = 3
      unhealthy_threshold = 3
      interval = 30
  }
  // See https://github.com/terraform-providers/terraform-provider-aws/issues/636
  lifecycle {
    create_before_destroy = true
    ignore_changes = ["name"]
  }
  tags = {
        Role = "${var.Role[2]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[2]}-${var.Application}-http"
        Application = "${var.Application}"
        Region = "${var.Region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }
}

