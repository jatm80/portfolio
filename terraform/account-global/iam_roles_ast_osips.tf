#
# IAM Roles
#

# opensips roles

resource "aws_iam_role" "roleopensips" {
  name = "${var.Environment}-${var.Application}-role-opensips"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instance_profile_opensips" {
  name = "${var.Environment}-${var.Application}-instrole-opensips"
  role = "${aws_iam_role.roleopensips.name}"
}

# opensips polies

resource "aws_iam_role_policy" "policy" {
  name = "${var.Environment}-${var.Application}-opensips-ec2pol"
  role = "${aws_iam_role.roleopensips.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
       {
         "Action":[
              "ec2:CreateSnapshot",
              "ec2:CreateImage",
              "ec2:DescribeImages",
              "ec2:DescribeInstances",
              "ec2:DescribeTags"
         ],
         "Effect":"Allow",
         "Resource": "*"
       }
    ]
}
EOF
}

resource "aws_iam_role_policy" "CloudWatch-Log-Agent-Osips" {
  name = "${var.Environment}-${var.Application}-opensips-logspoli"
  role = "${aws_iam_role.roleopensips.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:PutLogEvents",
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "SecretsMgr-read-opensips" {
  name = "${var.Environment}-${var.Application}-opensips-smpoli"
  role = "${aws_iam_role.roleopensips.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
              "secretsmanager:GetSecretValue",
              "ssm:DescribeParameters",
              "ssm:GetParametersByPath",
              "ssm:GetParameter",
              "ssm:GetParameters"
            ], 
            "Resource": "*"
        }
    ]
}
EOF
}


#

## Asterisk ################################

# roles

resource "aws_iam_role" "roleasterisk" {
  name = "${var.Environment}-${var.Application}-role-asterisk"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instance_profile_asterisk" {
  name = "${var.Environment}-${var.Application}-instrole-asterisk"
  role = "${aws_iam_role.roleasterisk.name}"
}

# asterisk polies

resource "aws_iam_role_policy" "asterisk-ec2pol" {
  name = "${var.Environment}-${var.Application}-asterisk-ec2pol"
  role = "${aws_iam_role.roleasterisk.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1468208496000",
            "Effect": "Allow",
            "Action": [
              "ec2:CreateSnapshot",
              "ec2:CreateImage",
              "ec2:DescribeImages",
              "ec2:DescribeInstances",
              "ec2:DescribeTags"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "S3Access-asterisk-events" {
  name = "${var.Environment}-${var.Application}-asterisk-s3eventspoli"
  role = "${aws_iam_role.roleasterisk.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObject",
                "s3:DeleteObjectVersion",
                "s3:Get*",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:PutObjectVersionAcl",
                "s3:RestoreObject",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::${var.Application}-events-${var.Environment}",
                "arn:aws:s3:::${var.Application}-events-${var.Environment}/*",
                "arn:aws:s3:::${var.Application}-${var.s3_bucket_prefix}events-${var.Environment}",
                "arn:aws:s3:::${var.Application}-${var.s3_bucket_prefix}events-${var.Environment}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "firehose:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "firehose-asterisk-events" {
  name = "${var.Environment}-${var.Application}-asterisk-firehosepoli"
  role = "${aws_iam_role.roleasterisk.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "firehose:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "CloudWatch-Log-Agent" {
  name = "${var.Environment}-${var.Application}-asterisk-logspoli"
  role = "${aws_iam_role.roleasterisk.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:PutLogEvents",
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "mediastorage-S3access" {
  name = "${var.Environment}-${var.Application}-asterisk-s3audiopoli"
  role = "${aws_iam_role.roleasterisk.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObject",
                "s3:DeleteObjectVersion",
                "s3:Get*",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:PutObjectVersionAcl",
                "s3:RestoreObject",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::${var.Application}-mediastorage-${var.Environment}",
                "arn:aws:s3:::${var.Application}-mediastorage-${var.Environment}/*",
                "arn:aws:s3:::${var.Application}-${var.s3_bucket_prefix}mediastorage-${var.Environment}",
                "arn:aws:s3:::${var.Application}-${var.s3_bucket_prefix}mediastorage-${var.Environment}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "this-project1-bin-S3access" {
  name = "${var.Environment}-${var.Application}-asterisk-s3bin"
  role = "${aws_iam_role.roleasterisk.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObject",
                "s3:DeleteObjectVersion",
                "s3:Get*",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:PutObjectVersionAcl",
                "s3:RestoreObject",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::${var.Application}-bin-${var.Environment}",
                "arn:aws:s3:::${var.Application}-bin-${var.Environment}/*",
                "arn:aws:s3:::${var.Application}-${var.s3_bucket_prefix}bin-${var.Environment}",
                "arn:aws:s3:::${var.Application}-${var.s3_bucket_prefix}bin-${var.Environment}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "SecretsMgr-read" {
  name = "${var.Environment}-${var.Application}-asterisk-smpoli"
  role = "${aws_iam_role.roleasterisk.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
              "secretsmanager:GetSecretValue",
              "ssm:DescribeParameters",
              "ssm:GetParametersByPath",
              "ssm:GetParameter",
              "ssm:GetParameters"
            ], 
            "Resource": "*"
        }
    ]
}
EOF
}
