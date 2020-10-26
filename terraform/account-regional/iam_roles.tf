### ROLE FOR ECS SERVICE ####################################################
data "aws_iam_role" "ecsservicerole" {
    name = "${var.Environment}-${var.Application}-ecsservicerole"
}
###########  ECSTASK ROLE ##############
data "aws_iam_role" "thisproject1global-taskrole" {
    name = "${var.Environment}-${var.Application}-taskrole"
}    
# Instance Roles #################################
data "aws_iam_role" "thisproject1global-role" {
    name = "${var.Environment}-${var.Application}-role"
}
data "aws_iam_instance_profile" "thisproject1global_profile" {
  name = "${var.Environment}-${var.Application}-inst-profile"
}
# CodeDeploy
data "aws_iam_role" "codedeploy_role" {
  name = "${var.Environment}-${var.Application}-CodeDeploy-role"
}
# Lambda iam role
data "aws_iam_role" "lambda_role" {
  name = "${var.Environment}-${var.Application}-lambda_role"
}
## Custom Policies for Lambda role
## Kinesis Firehose role
data "aws_iam_role" "firehose_role" {
  name = "${var.Environment}-${var.Application}-firehose-role"
}
### DynamoDB ASRole
data "aws_iam_role" "DynamoDBAutoscaleRole" {
  name =  "DynamoDBAutoscaleRole-${var.Environment}"
}