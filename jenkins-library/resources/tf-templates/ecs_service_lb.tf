resource "aws_ecs_service" "xyzgroup1global" {
  task_definition = "arn:aws:ecs:${var.Region}:${lookup("${var.aws_account["${var.Environment}"]}", "${var.Project}")}:task-definition/${aws_ecs_task_definition.taskdef.family}:${max("${aws_ecs_task_definition.taskdef.revision}", "${data.aws_ecs_task_definition.taskdef_data.revision}")}"
  cluster         = "${data.aws_ecs_cluster.docker_cluster.id}"
  name            = "${var.Environment}-${var.Application}-service"
  desired_count   = "${var.ecs_desired_count}"
  launch_type     = "EC2"
  health_check_grace_period_seconds = 10
  load_balancer  {
    container_name = "${var.Environment}-${var.Application}"
    target_group_arn = "${aws_lb_target_group.target_groups.arn}"
    container_port = 80
  }
}