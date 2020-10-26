resource "aws_sqs_queue" "sqs1" {
  name                      = "${var.Environment}-${var.Application}-wav2mp3-queue"
  delay_seconds             = 0
  visibility_timeout_seconds = 30
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.sqs2.arn}\",\"maxReceiveCount\":5}"
  
  tags = {
        Role = "${var.Role[8]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[8]}-${var.Application}-wav2mp3-queue"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }
}


resource "aws_sqs_queue_policy" "sqs1_policy" {
  queue_url = "${aws_sqs_queue.sqs1.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "${aws_sqs_queue.sqs1.arn}/SQSDefaultPolicy",
  "Statement": [
    {
      "Sid": "Sid1554770191728",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "SQS:SendMessage",
      "Resource": "${aws_sqs_queue.sqs1.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.topic1.arn}"
        }
      }
    }
  ]
}
POLICY
}


resource "aws_sqs_queue" "sqs2" {
  name                      = "${var.Environment}-${var.Application}-wav2mp3-queue-deadletter"
  delay_seconds             = 0
  visibility_timeout_seconds = 30
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  
  
  tags = {
        Role = "${var.Role[8]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[8]}-${var.Application}-wav2mp3-queue-deadletter"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }
}