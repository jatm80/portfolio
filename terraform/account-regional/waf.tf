resource "aws_wafregional_geo_match_set" "geo_match_set" {
  name = "${var.tfwafrule["${var.Environment}"]}MatchSet${var.iso_region["${var.region}"]}"

  lifecycle {
    create_before_destroy = true
  }

  geo_match_constraint {
    type  = "Country"
    value = "US"
  }

  geo_match_constraint {
    type  = "Country"
    value = "region1"
  }

  geo_match_constraint {
    type  = "Country"
    value = "CA"
  }

  geo_match_constraint {
    type  = "Country"
    value = "AR"
  }

    geo_match_constraint {
    type  = "Country"
    value = "CL"
  }

    geo_match_constraint {
    type  = "Country"
    value = "MX"
  }

}


resource "aws_wafregional_rule" "waf_georule" {
  depends_on  = ["aws_wafregional_geo_match_set.geo_match_set"]
  name        = "${var.tfwafrule["${var.Environment}"]}Geo${var.iso_region["${var.region}"]}"
  metric_name = "${var.tfwafrule["${var.Environment}"]}Geo${var.iso_region["${var.region}"]}"

  predicate {
    data_id = "${aws_wafregional_geo_match_set.geo_match_set.id}"
    negated = false
    type    = "GeoMatch"
  }
}


resource "aws_wafregional_rate_based_rule" "waf_rate_based_rule" {
  name        = "${var.tfwafrule["${var.Environment}"]}RB${var.iso_region["${var.region}"]}"
  metric_name = "${var.tfwafrule["${var.Environment}"]}RB${var.iso_region["${var.region}"]}"

  lifecycle {
    create_before_destroy = true
  }

  rate_key   = "IP"
  rate_limit = 100

  predicate {
    data_id = "${aws_wafregional_geo_match_set.geo_match_set.id}"
    negated = false
    type    = "GeoMatch"
  }
}


resource "aws_wafregional_web_acl" "waf_acl_public_alb" {
  depends_on  = ["aws_wafregional_rate_based_rule.waf_rate_based_rule"]
  name        = "${var.tfwebacl["${var.Environment}"]}${var.iso_region["${var.region}"]}"
  metric_name = "${var.tfwebacl["${var.Environment}"]}${var.iso_region["${var.region}"]}"

  lifecycle {
    create_before_destroy = true
  }

 default_action {
    type = "BLOCK"
  }

  // Rule 1 
  rule {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = "${aws_wafregional_rule.waf_georule.id}"
  }

// Rule 2
  rule {
    action {
      type = "ALLOW"
    }

    priority = 10
    rule_id  = "${aws_wafregional_rate_based_rule.waf_rate_based_rule.id}"
    type = "RATE_BASED"
  }

}


resource "aws_wafregional_web_acl_association" "waf_acl_public_alb_assoc" {
  resource_arn = "${aws_lb.loadbalancer_pub.arn}"
  web_acl_id   = "${aws_wafregional_web_acl.waf_acl_public_alb.id}"
}