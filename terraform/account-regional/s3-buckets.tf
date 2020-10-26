resource "aws_s3_bucket" "public_alb_logs" {
  bucket = "${var.Application}-alb-logs-${var.Environment}-${var.region}"
  acl    = "bucket-owner-full-control"

  lifecycle_rule {
        id      = "Expire after 7 days"
        enabled = true
        expiration {
            days = 7
        }
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.alb_accountid["${var.region}"]}:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.Application}-alb-logs-${var.Environment}-${var.region}/AWSLogs/${var.aws_account["${var.Environment}"]}/*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.Application}-alb-logs-${var.Environment}-${var.region}/AWSLogs/${var.aws_account["${var.Environment}"]}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.Application}-alb-logs-${var.Environment}-${var.region}"
        }
    ]
}
	POLICY

  tags = {
        Role = "${var.Role[1]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[5]}-${var.Application}"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }
}


resource "aws_s3_bucket" "s3bucket_1" {
  bucket = "${var.Application}-${var.s3_bucket_prefix}bin-${var.Environment}"
  acl    = "private"

  tags = {
        Role = "${var.Role[1]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[5]}-${var.Application}"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }
}


resource "aws_s3_bucket" "s3bucket_2" {
  bucket = "${var.Application}-${var.s3_bucket_prefix}mediastorage-${var.Environment}"
  acl    = "private"
  lifecycle_rule {
        id      = "Expire after 7 days"
        enabled = true
        prefix = "samples/"
        expiration {
            days = 7
        }
    }
  tags = {
        Role = "${var.Role[1]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[5]}-${var.Application}"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }
}

resource "aws_s3_bucket" "s3bucket_3" {
  bucket = "${var.Application}-${var.s3_bucket_prefix}events-${var.Environment}"
  acl    = "private"

  tags = {
        Role = "${var.Role[1]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "This Project Events"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }
}

resource "aws_s3_bucket" "s3bucket_4" {
  bucket = "${var.Application}-${var.s3_bucket_prefix}api1-ui-${var.Environment}"
  acl    = "private"

  website {
    index_document = "index.html"
  }


  tags = {
        Role = "${var.Role[1]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[5]}-${var.Application}"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }
}

resource "aws_s3_bucket" "dstui_bucket" {
  bucket = "${var.Application}-${var.s3_bucket_prefix}dstui-${var.Environment}"
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }


  tags = {
        Role = "${var.Role[1]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[5]}-${var.Application}"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }
}

resource "aws_s3_bucket_policy" "s3bucket_2_policy" {
	bucket = "${aws_s3_bucket.s3bucket_2.id}"

	policy = <<POLICY
{
		  "Version":"2012-10-17",
		  "Statement":[
			{
			  "Sid":"2",
			  "Effect":"Allow",
			  "Principal": {
				"AWS": "${aws_cloudfront_origin_access_identity.origin_access_identity_mediastorage.iam_arn}"
			  },
			  "Action":["s3:GetObject"],
			  "Resource":["arn:aws:s3:::${aws_s3_bucket.s3bucket_2.id}/*"]
			}
		  ]
		}
	POLICY
}

resource "aws_s3_bucket_policy" "s3bucket_4_policy" {
	bucket = "${aws_s3_bucket.s3bucket_4.id}"

	policy = <<POLICY
{
		  "Version":"2012-10-17",
		  "Statement":[
			{
			  "Sid":"2",
			  "Effect":"Allow",
			  "Principal": {
				"AWS": "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"
			  },
			  "Action":["s3:GetObject"],
			  "Resource":["arn:aws:s3:::${aws_s3_bucket.s3bucket_4.id}/*"]
			}
		  ]
		}
	POLICY
}

resource "aws_s3_bucket_object" "s3bucket_2_recordings" {
    bucket = "${aws_s3_bucket.s3bucket_2.id}"
    acl    = "private"
    key    = "recordings/"
    source = "/dev/null"
}

resource "aws_s3_bucket_object" "s3bucket_2_voicemails" {
    bucket = "${aws_s3_bucket.s3bucket_2.id}"
    acl    = "private"
    key    = "voicemails/"
    source = "/dev/null"
}

resource "aws_s3_bucket_object" "s3bucket_2_sounds" {
    bucket = "${aws_s3_bucket.s3bucket_2.id}"
    acl    = "private"
    key    = "sounds/"
    source = "/dev/null"
}


# Sounds
resource "aws_s3_bucket_object" "s3bucket_2_sounds_region1" {
    bucket = "${aws_s3_bucket.s3bucket_2.id}"
    acl    = "private"
    key    = "sounds/region1/"
    source = "/dev/null"
}

resource "aws_s3_bucket_object" "s3bucket_2_sounds_MX" {
    bucket = "${aws_s3_bucket.s3bucket_2.id}"
    acl    = "private"
    key    = "sounds/MX/"
    source = "/dev/null"
}
resource "aws_s3_bucket_object" "s3bucket_2_sounds_CL" {
    bucket = "${aws_s3_bucket.s3bucket_2.id}"
    acl    = "private"
    key    = "sounds/CL/"
    source = "/dev/null"
}
resource "aws_s3_bucket_object" "s3bucket_2_sounds_AR" {
    bucket = "${aws_s3_bucket.s3bucket_2.id}"
    acl    = "private"
    key    = "sounds/AR/"
    source = "/dev/null"
}


## Recordings

resource "aws_s3_bucket_object" "s3bucket_2_recordings_region1" {
    bucket = "${aws_s3_bucket.s3bucket_2.id}"
    acl    = "private"
    key    = "recordings/region1/"
    source = "/dev/null"
}

resource "aws_s3_bucket_object" "s3bucket_2_recordings_MX" {
    bucket = "${aws_s3_bucket.s3bucket_2.id}"
    acl    = "private"
    key    = "recordings/MX/"
    source = "/dev/null"
}
resource "aws_s3_bucket_object" "s3bucket_2_recordings_CL" {
    bucket = "${aws_s3_bucket.s3bucket_2.id}"
    acl    = "private"
    key    = "recordings/CL/"
    source = "/dev/null"
}
resource "aws_s3_bucket_object" "s3bucket_2_recordings_AR" {
    bucket = "${aws_s3_bucket.s3bucket_2.id}"
    acl    = "private"
    key    = "recordings/AR/"
    source = "/dev/null"
}


## Voicemails

resource "aws_s3_bucket_object" "s3bucket_2_voicemails_region1" {
    bucket = "${aws_s3_bucket.s3bucket_2.id}"
    acl    = "private"
    key    = "voicemails/region1/"
    source = "/dev/null"
}

resource "aws_s3_bucket_object" "s3bucket_2_voicemails_MX" {
    bucket = "${aws_s3_bucket.s3bucket_2.id}"
    acl    = "private"
    key    = "voicemails/MX/"
    source = "/dev/null"
}
resource "aws_s3_bucket_object" "s3bucket_2_voicemails_CL" {
    bucket = "${aws_s3_bucket.s3bucket_2.id}"
    acl    = "private"
    key    = "voicemails/CL/"
    source = "/dev/null"
}
resource "aws_s3_bucket_object" "s3bucket_2_voicemails_AR" {
    bucket = "${aws_s3_bucket.s3bucket_2.id}"
    acl    = "private"
    key    = "voicemails/AR/"
    source = "/dev/null"
}