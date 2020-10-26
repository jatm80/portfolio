resource "aws_sns_topic" "topic1" {
  name = "${var.Environment}-${var.Application}-audio-uploaded"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {"AWS":"*"},
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:${var.Environment}-${var.Application}-audio-uploaded",
        "Condition":{
		      "StringEquals":{ "AWS:SourceAccount":"${var.aws_account["${var.Environment}"]}" } ,
		      "ArnLike": {"AWS:SourceArn": "arn:aws:s3:*:*:*" }
        }
    }]
}
POLICY

}

resource "aws_sns_topic_subscription" "sns_subs_sqs" {
  topic_arn = "${aws_sns_topic.topic1.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.sqs1.arn}"
}

resource "aws_sns_topic_subscription" "sns_subs_lambda" {
  topic_arn = "${aws_sns_topic.topic1.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.lambda1.arn}"
}


resource "aws_s3_bucket_notification" "s3bucket_2_notification" {
  bucket = "${aws_s3_bucket.s3bucket_2.id}"

  topic {
    topic_arn     = "${aws_sns_topic.topic1.arn}"
    events        = ["s3:ObjectCreated:*","s3:ObjectRemoved:*","s3:ObjectRestore:Completed","s3:ObjectRestore:Post","s3:ReducedRedundancyLostObject"]
    filter_suffix = ".wav"
  }
}



