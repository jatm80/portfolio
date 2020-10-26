###
resource "aws_cloudwatch_log_group" "lambda_clwgrp" {
  name              = "/aws/lambda/${aws_lambda_function.lambda1.function_name}"
  retention_in_days = 3
  count = "${var.enable_cloudwatch["${var.Environment}"]}"
}

resource "aws_lambda_function" "lambda1" {
  function_name = "${var.Environment}-${var.Application}-services"
  s3_bucket ="${aws_s3_bucket.s3bucket_1.id}"
  s3_key = "lambda-jenkins-echo-this.project1-this.project1.services-42.zip"
  
  role             = "${data.aws_iam_role.lambda_role.arn}"
  handler          = "CallRecordingTranscriber::CallRecordingTranscriber.Function::FunctionHandler"
  runtime          = "dotnetcore2.1"

  timeout          =  300

  tags = {
        Role = "${var.Role[7]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[7]}-${var.Application}"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }

  vpc_config {
     subnet_ids = [
       "${lookup("${var.vpc_network["${var.Environment}"]}", "privateA")}",
       "${lookup("${var.vpc_network["${var.Environment}"]}", "privateB")}",
        ]

     security_group_ids = [
       "${aws_security_group.thisproject1global-lb-sg.id}"
     ]   
  }

  environment {
    variables = {
      Environment       = "${var.Environment}"
      AWSRegion         = "${var.region}"
    }
  }
}



resource "aws_lambda_permission" "lambda_permissions" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda1.arn}"
  principal = "s3.amazonaws.com"
  source_arn = "${aws_s3_bucket.s3bucket_2.arn}"
}

resource "aws_lambda_permission" "lambda_permissions_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda1.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.topic1.arn}"
}
