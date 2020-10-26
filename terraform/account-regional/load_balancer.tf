# Create a new application load balancer
resource "aws_lb" "loadbalancer" {
  name            = "${var.Environment}-${var.Application}-${var.Role[2]}"
  internal        = true
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.thisproject1global-lb-sg.id}"]
  subnets         = "${matchkeys("${values("${var.vpc_network["${var.Environment}"]}")}", "${keys("${var.vpc_network["${var.Environment}"]}")}", "${var.load_balancer_subnets}")}"
  enable_deletion_protection = false

  tags = {
        Role = "${var.Role[2]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[2]}-${var.Application}"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.loadbalancer.arn}"

  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service Unavailable"
      status_code  = "503"
    }
  }
}
resource "aws_lb_listener" "front_end2" {
  load_balancer_arn = "${aws_lb.loadbalancer.arn}"

  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${var.https_listener_cert["${var.Environment}"]}"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service Unavailable"
      status_code  = "503"
    }
  }
}


## public ALB


resource "aws_lb" "loadbalancer_pub" {
  depends_on     = ["aws_s3_bucket.public_alb_logs"]
  name            = "${var.Environment}-${var.Application}-${var.Role[2]}-pub"
  internal        = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.public_thisproject1global-lb-sg.id}"]
  subnets         = "${matchkeys("${values("${var.vpc_network["${var.Environment}"]}")}", "${keys("${var.vpc_network["${var.Environment}"]}")}", "${var.public_load_balancer_subnets}")}"
  enable_deletion_protection = false

  tags = {
        Role = "${var.Role[2]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[2]}-${var.Application}-pub"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }

 access_logs {
   enabled = true
   bucket = "${aws_s3_bucket.public_alb_logs.id}"
 }

}

resource "aws_lb_listener" "front_end_pub" {
  load_balancer_arn = "${aws_lb.loadbalancer_pub.arn}"

  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service Unavailable"
      status_code  = "503"
    }
  }
}
resource "aws_lb_listener" "front_end2_pub" {
  load_balancer_arn = "${aws_lb.loadbalancer_pub.arn}"

  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${var.https_listener_cert["${var.Environment}"]}"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service Unavailable"
      status_code  = "503"
    }
  }
}


resource "aws_lb_listener" "front_end3_pub" {
  load_balancer_arn = "${aws_lb.loadbalancer_pub.arn}"

  port              = "5065"
  protocol          = "HTTPS"
  certificate_arn   = "${var.https_listener_cert["${var.Environment}"]}"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service Unavailable"
      status_code  = "503"
    }
  }
}

## Additional Certs

resource "aws_lb_listener_certificate" "additional_cert_private" {
  count = "${var.additional_listener_cert_install["${var.region}"]}"
  listener_arn    = "${aws_lb_listener.front_end2.arn}"
  certificate_arn = "${var.additional_listener_cert["${var.Environment}"]}"
}

resource "aws_lb_listener_certificate" "additional_cert_public" {
  count = "${var.additional_listener_cert_install["${var.region}"]}"
  listener_arn    = "${aws_lb_listener.front_end2_pub.arn}"
  certificate_arn = "${var.additional_listener_cert["${var.Environment}"]}"
}

resource "aws_lb_listener_certificate" "additional_cert_public_webrtc" {
  count = "${var.additional_listener_cert_install["${var.region}"]}"
  listener_arn    = "${aws_lb_listener.front_end3_pub.arn}"
  certificate_arn = "${var.additional_listener_cert["${var.Environment}"]}"
}