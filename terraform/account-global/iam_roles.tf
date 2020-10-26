### ROLE FOR ECS SERVICE ####################################################

resource "aws_iam_role" "ecsservicerole" {
    name = "${var.Environment}-${var.Application}-ecsservicerole"
    assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerServiceRole" {
  role       = "${aws_iam_role.ecsservicerole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
               
}


###########  ECSTASK ROLE ##############

resource "aws_iam_role" "thisproject1global-taskrole" {
    name = "${var.Environment}-${var.Application}-taskrole"
    assume_role_policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ecs-tasks.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
}
EOF
} 

resource "aws_iam_policy" "sqs_polies" {
  name = "${var.Environment}-${var.Application}-sqs-polies"
  
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "sqspolicy1",
            "Effect": "Allow",
            "Action": "sqs:*",
            "Resource": "arn:aws:sqs:*:${var.aws_account["${var.Environment}"]}:*"
        }
    ]
}
EOF
}



resource "aws_iam_policy" "secretsmgr_readonly_polies" {
  name = "${var.Environment}-${var.Application}-SecretsMgrRead-polies"
  

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action":[ 
              "secretsmanager:GetSecretValue",
              "ssm:Describe*",
              "ssm:List*",
              "ssm:Get*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "s3_ecstask_polies" {
  name = "${var.Environment}-${var.Application}-ECSTaskS3-polies"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
       {
         "Action":[
                "s3:DeleteObject",
                "s3:DeleteObjectVersion",
                "s3:Get*",
                "s3:Put*",
                "s3:List*",
                "s3:RestoreObject"
         ],
         "Effect":"Allow",
         "Resource": "*"
       }
    ]
}
EOF
}


resource "aws_iam_policy" "assume_role_polies" {
  name = "${var.Environment}-${var.Application}-assumerole-polies"
  
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": [
                "arn:aws:iam::${var.cross_account_region2["${var.Environment}"]}:role/this-project1-taskrole"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "CloudWatchFullAccess" {
  role       = "${aws_iam_role.thisproject1global-taskrole.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "ECSTaskExecutionRole" {
  role       = "${aws_iam_role.thisproject1global-taskrole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonDynamoDBFullAccess" {
  role       = "${aws_iam_role.thisproject1global-taskrole.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"               
}

resource "aws_iam_role_policy_attachment" "SecretsManagerReadOnlyAccess" {
  role       = "${aws_iam_role.thisproject1global-taskrole.name}"
  policy_arn = "${aws_iam_policy.secretsmgr_readonly_polies.arn}"               
}

resource "aws_iam_role_policy_attachment" "SQS1Access" {
  role       = "${aws_iam_role.thisproject1global-taskrole.name}"
  policy_arn = "${aws_iam_policy.sqs_polies.arn}"               
}

resource "aws_iam_role_policy_attachment" "S3BucketAccess" {
  role       = "${aws_iam_role.thisproject1global-taskrole.name}"
  policy_arn = "${aws_iam_policy.s3_ecstask_polies.arn}"               
}

resource "aws_iam_role_policy_attachment" "AssumeRoleAccess" {
  role       = "${aws_iam_role.thisproject1global-taskrole.name}"
  policy_arn = "${aws_iam_policy.assume_role_polies.arn}"               
}

# Instance Roles #################################

resource "aws_iam_role" "thisproject1global-role" {
    name = "${var.Environment}-${var.Application}-role"
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

resource "aws_iam_instance_profile" "thisproject1global_profile" {
  name = "${var.Environment}-${var.Application}-inst-profile"
  role = "${aws_iam_role.thisproject1global-role.name}"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerServiceforEC2Role" {
  role       = "${aws_iam_role.thisproject1global-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


# CodeDeploy
resource "aws_iam_role" "codedeploy_role" {
  name = "${var.Environment}-${var.Application}-CodeDeploy-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = "${aws_iam_role.codedeploy_role.name}"
}

# Lambda iam role
resource "aws_iam_role" "lambda_role" {
  name = "${var.Environment}-${var.Application}-lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSEC2FullAccess" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "AWSCloudWatchEventsFullAccess" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
}

resource "aws_iam_role_policy_attachment" "AWSASGFullAccess" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

resource "aws_iam_role_policy_attachment" "AWSCloudWatchLogsFullAccess" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "AWSLambdaFullAccess" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


resource "aws_iam_role_policy_attachment" "lambda_polies_attachment" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_polies.arn}"
}

## Custom Policies for Lambda role

resource "aws_iam_policy" "lambda_polies" {
  name = "${var.Environment}-${var.Application}-lambda-polies"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
       {
         "Action":[
                "s3:DeleteObject",
                "s3:DeleteObjectVersion",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:GetObjectVersion",
                "s3:GetObjectVersionAcl",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:PutObjectVersionAcl",
                "s3:RestoreObject",
                "transcribe:*"
         ],
         "Effect":"Allow",
         "Resource": "*"
       }
    ]
}
EOF
}

## Kinesis Firehose role


resource "aws_iam_role" "firehose_role" {
  name = "${var.Environment}-${var.Application}-firehose-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


## Custom Policies for Firehose role

resource "aws_iam_policy" "firehose_polies" {
  name = "${var.Environment}-${var.Application}-firehose-polies"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "glue:GetTableVersions"
            ],
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "firehose_polies_attachment" {
  role       = "${aws_iam_role.firehose_role.name}"
  policy_arn = "${aws_iam_policy.firehose_polies.arn}"
}
### DynamoDB ASRole
resource "aws_iam_role" "DynamoDBAutoscaleRole" {
  name =  "DynamoDBAutoscaleRole-${var.Environment}"
    assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "dax.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "AmazonDynamoDBFullAccess2" {
  role       = "${aws_iam_role.DynamoDBAutoscaleRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"               
}
