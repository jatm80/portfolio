# Target Groups

data "aws_lb_target_group" "lbtargetgroup1" {
  count = "${var.enable_cloudwatch["${var.Environment}"]}"
  name     = "${var.Environment}-${var.Application}-audio-api-${var.Role[2]}"
}

#Dashboard

resource "aws_cloudwatch_dashboard" "main_alb" {
  count = "${var.enable_cloudwatch["${var.Environment}"]}"
  dashboard_name = "${var.Environment}-${var.Application}-alb"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 12,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "${aws_autoscaling_group.auto_scaling_thisproject1global.name}", { "period": 60, "label": "Average" } ],
                    [ "...", { "period": 60, "stat": "Maximum", "label": "Max" } ],
                    [ "...", { "period": 60, "stat": "Minimum", "label": "Min" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "period": 300,
                "annotations": {
                    "horizontal": [
                        {
                            "label": "Scale Up",
                            "value": 55
                        },
                        {
                            "color": "#2ca02c",
                            "label": "Scale Down",
                            "value": 30
                        }
                    ]
                }
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", "${data.aws_lb_target_group.lbtargetgroup1[count.index].arn_suffix}", "LoadBalancer", "${aws_lb.loadbalancer.arn_suffix}", { "stat": "p99.9", "period": 60, "label": "99.9" } ],
                    [ "...", { "stat": "p99.5", "period": 60, "label": "99.5" } ],
                    [ "...", { "stat": "p99", "period": 60, "label": "99" } ],
                    [ "...", { "stat": "p95", "period": 60, "label": "95" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "period": 300,
                "title": "Latency Percentiles"
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                   [ "AWS/ApplicationELB", "RequestCount", "TargetGroup", "${data.aws_lb_target_group.lbtargetgroup1[count.index].arn_suffix}", "LoadBalancer", "${aws_lb.loadbalancer.arn_suffix}", "AvailabilityZone", "${var.region}c", { "stat": "Sum", "period": 60 } ],
                   [ "...", "${var.region}b", { "stat": "Sum", "period": 60 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "period": 300,
                "title": "Request Count"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 6,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                  [ "AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", "${data.aws_lb_target_group.lbtargetgroup1[count.index].arn_suffix}", "LoadBalancer", "${aws_lb.loadbalancer.arn_suffix}", { "stat": "Maximum", "period": 60 } ],
                  [ "AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", "${data.aws_lb_target_group.lbtargetgroup1[count.index].arn_suffix}", "LoadBalancer", "${aws_lb.loadbalancer.arn_suffix}", { "stat": "Maximum", "period": 60 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 6,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetConnectionErrorCount", "LoadBalancerName", "${aws_lb.loadbalancer.arn_suffix}", { "stat": "Maximum", "period": 60 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                      [ "AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", "${data.aws_lb_target_group.lbtargetgroup1[count.index].arn_suffix}", "LoadBalancer", "${aws_lb.loadbalancer.arn_suffix}", "AvailabilityZone", "${var.region}b", { "stat": "Maximum" } ],
                      [ "...", "${var.region}c", { "stat": "Maximum" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "period": 300,
                "title": "Max Latency"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 6,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                   [ "AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "TargetGroup", "${data.aws_lb_target_group.lbtargetgroup1[count.index].arn_suffix}", "LoadBalancer", "${aws_lb.loadbalancer.arn_suffix}", { "stat": "Sum", "period": 60, "label": "Backend_5XX" } ],
                   [ ".", "HTTPCode_Target_4XX_Count", ".", ".", ".", ".", { "stat": "Sum", "period": 60, "label": "Backend_4XX" } ],
                   [ ".", "HTTPCode_ELB_5XX_Count", "LoadBalancer", "${aws_lb.loadbalancer.arn_suffix}", { "stat": "Sum", "period": 60, "label": "ELB_5XX" } ],
                   [ ".", "HTTPCode_ELB_4XX_Count", ".", ".", { "stat": "Sum", "period": 60, "label": "ELB_4XX" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                      [ "AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", "${data.aws_lb_target_group.lbtargetgroup1[count.index].arn_suffix}", "LoadBalancer", "${aws_lb.loadbalancer.arn_suffix}", "AvailabilityZone", "${var.region}b", { "stat": "Average" } ],
                      [ "...", "${var.region}c", { "stat": "Average" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "title": "Average Latency",
                "period": 300,
                "annotations": {
                    "horizontal": [
                        {
                            "color": "#ff7f0e",
                            "label": "Slowness warning",
                            "value": 0.025,
                            "fill": "above"
                        }
                    ]
                }
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 12,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ { "expression": "m1-m2", "label": "Max - Min", "id": "e1" } ],
                    [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "${aws_autoscaling_group.auto_scaling_thisproject1global.name}", { "stat": "Maximum", "period": 60, "id": "m1", "visible": false } ],
                    [ "...", { "stat": "Minimum", "period": 60, "id": "m2", "visible": false } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "title": "CPU diff",
                "period": 300,
                "annotations": {
                    "horizontal": [
                        {
                            "color": "#ff7f0e",
                            "label": "Potential live lock",
                            "value": 25,
                            "fill": "above"
                        }
                    ]
                }
            }
        }
    ]
}
EOF
}
