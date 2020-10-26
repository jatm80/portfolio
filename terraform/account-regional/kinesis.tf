resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_ext_s3" {
  name        = "${var.Environment}-${var.Application}-events"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = "${data.aws_iam_role.firehose_role.arn}"
    bucket_arn = "${aws_s3_bucket.s3bucket_3.arn}"

   cloudwatch_logging_options {
     enabled = true
     log_stream_name="${var.Environment}-${var.Application}-events"
     log_group_name = "${aws_cloudwatch_log_group.kinesis_firehose_cwlogs.name}"
   }

  }

 

  tags = {
        Role = "${var.Role[3]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[3]}-${var.Application}"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }

}


## Logs

resource "aws_cloudwatch_log_group" "kinesis_firehose_cwlogs" {
  name = "${var.Environment}-${var.Application}-events"
  retention_in_days = 3

  tags = {
        Role = "${var.Role[3]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[3]}-${var.Application}"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }
}

resource "aws_cloudwatch_log_stream" "kinesis_firehose_cwlog_stream" {
  name           = "${var.Environment}-${var.Application}-events"
  log_group_name = "${aws_cloudwatch_log_group.kinesis_firehose_cwlogs.name}"
}
