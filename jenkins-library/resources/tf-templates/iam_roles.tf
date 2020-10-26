# data "aws_iam_role" "ecsservicerole" {
#   name = "${var.Environment}-${var.Project}-ecsservicerole"
# }

data "aws_iam_role" "xyzgroup1global-taskrole" {
  name = "${var.Environment}-${var.Project}-taskrole"
}

# data "aws_iam_instance_profile" "xyzgroup1global_profile" {
#   name = "${var.Environment}-${var.Project}-inst-profile"
# }
