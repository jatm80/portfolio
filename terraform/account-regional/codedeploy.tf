
data "aws_autoscaling_groups" "auto_scaling_asterisk" {
  filter {
    name   = "key"
    values = ["CodeDeployTag"]
  }

  filter {
    name   = "value"
    values = ["${var.Environment}-${var.Role[0]}-${var.Application}-Asterisk-ARI"]
  }
}

resource "aws_codedeploy_app" "codedeploy_1" {
  name = "${var.Application}-cd-ari${var.dynamoEnv["${var.Environment}"]}"
}


resource "aws_codedeploy_deployment_group" "codedeploy_group" {
  app_name              = "${aws_codedeploy_app.codedeploy_1.name}"
  deployment_group_name = "${var.Application}-cd-grp${var.dynamoEnv["${var.Environment}"]}"
  service_role_arn      = "${data.aws_iam_role.codedeploy_role.arn}"
  autoscaling_groups    = "${data.aws_autoscaling_groups.auto_scaling_asterisk.names}"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "CodeDeployTag"
      type  = "KEY_AND_VALUE"
      value = "${var.Environment}-${var.Role[0]}-${var.Application}-Asterisk-ARI"
    }
  } 

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}


resource "aws_codedeploy_app" "codedeploy_2" {
  name = "${var.Application}-cd-eagi${var.dynamoEnv["${var.Environment}"]}"
}

