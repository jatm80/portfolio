####### this-project1-api2 #######
#  Read 
resource "aws_appautoscaling_target" "dynamodb_table_read_target_api2" {
  max_capacity       =  "${lookup("${var.api2db["${var.Environment}"]}", "maxread")}"
  min_capacity       =  "${lookup("${var.api2db["${var.Environment}"]}", "minread")}"
  resource_id        = "table/${aws_dynamodb_table.dynamosteps.name}"
  role_arn           = "${data.aws_iam_role.DynamoDBAutoscaleRole.arn}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
    lifecycle {
    ignore_changes = ["role_arn"]
  }
}

resource "aws_appautoscaling_policy" "dynamodb_table_read_policy_api2" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_read_target_api2.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.dynamodb_table_read_target_api2.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.dynamodb_table_read_target_api2.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.dynamodb_table_read_target_api2.service_namespace}"

  lifecycle {
    ignore_changes = ["target_tracking_scaling_policy_configuration[0].target_value"]
  }

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 50.0
  }
}

#Secondary Index Read
resource "aws_appautoscaling_target" "dynamodb_api2_index_read_target" {
  max_capacity       =  "${lookup("${var.api2Secondary["${var.Environment}"]}", "maxread")}"
  min_capacity       =  "${lookup("${var.api2Secondary["${var.Environment}"]}", "minread")}"
  resource_id        = "table/${aws_dynamodb_table.dynamosteps.name}/index/api1Id-index"
  role_arn           = "${data.aws_iam_role.DynamoDBAutoscaleRole.arn}"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"
  lifecycle {
    ignore_changes = ["role_arn"]
  }

}

resource "aws_appautoscaling_policy" "dynamodb_table_read_policy_api2_index" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_api2_index_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.dynamodb_api2_index_read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.dynamodb_api2_index_read_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.dynamodb_api2_index_read_target.service_namespace}"

 lifecycle {
    ignore_changes = ["target_tracking_scaling_policy_configuration[0].target_value"]
  }

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 50.0
  }
}

# Write
resource "aws_appautoscaling_target" "dynamodb_table_write_target_api2" {
  max_capacity       = "${lookup("${var.api2db["${var.Environment}"]}", "maxwrite")}"
  min_capacity       = "${lookup("${var.api2db["${var.Environment}"]}", "minwrite")}"
  resource_id        = "table/${aws_dynamodb_table.dynamosteps.name}"
  role_arn           = "${data.aws_iam_role.DynamoDBAutoscaleRole.arn}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
    lifecycle {
    ignore_changes = ["role_arn"]
  }
}

resource "aws_appautoscaling_policy" "dynamodb_table_write_policy_api2" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_write_target_api2.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.dynamodb_table_write_target_api2.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.dynamodb_table_write_target_api2.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.dynamodb_table_write_target_api2.service_namespace}"
 
  lifecycle {
    ignore_changes = ["target_tracking_scaling_policy_configuration[0].target_value"]
  }

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 50.0
  }
}
#Secondary Index Write

resource "aws_appautoscaling_target" "dynamodb_api2_index_write_target" {
  max_capacity       =  "${lookup("${var.api2Secondary["${var.Environment}"]}", "maxwrite")}"
  min_capacity       =  "${lookup("${var.api2Secondary["${var.Environment}"]}", "minwrite")}"
  resource_id        = "table/${aws_dynamodb_table.dynamosteps.name}/index/api1Id-index"
  role_arn           = "${data.aws_iam_role.DynamoDBAutoscaleRole.arn}"
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  service_namespace  = "dynamodb"
    lifecycle {
    ignore_changes = ["role_arn"]
  }
}

resource "aws_appautoscaling_policy" "dynamodb_table_write_policy_api2_index" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_api2_index_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.dynamodb_api2_index_write_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.dynamodb_api2_index_write_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.dynamodb_api2_index_write_target.service_namespace}"

  lifecycle {
    ignore_changes = ["target_tracking_scaling_policy_configuration[0].target_value"]
  }

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 50.0
  }
}