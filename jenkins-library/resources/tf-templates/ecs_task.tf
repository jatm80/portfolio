locals {
  x_ecs_cluster_name = "${lookup("${var.ecs_cluster_name["${var.Region}"]}", "${var.Project}","${var.Environment}-${var.Project}-cluster")}"
}




data "aws_ecs_cluster" "docker_cluster" {
  cluster_name = "${local.x_ecs_cluster_name}"
  }


## Logs

resource "aws_cloudwatch_log_group" "xyzgroup1global" {
  name = "${var.Environment}-${var.Region}-${var.Application}-logs-group"
  retention_in_days = 3

  tags = {
        Role = "${var.Role[1]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[1]}-${var.Application}"
        Application = "${var.Application}"
        Region = "${var.Region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }
}

# this template_file helps converting the 
# var.ecs_environment_variables object into a json array
data "template_file" "ecs_environment_variables_string" {
  template = <<EOF
  {
    "name": "$${name}",
    "value": "$${value}"
  }
  EOF
  count    = "${length(var.ecs_environment_variables)}"
  vars = {
    name  = "${element(keys(var.ecs_environment_variables[count.index]), 0)}"
    value = "${element(values(var.ecs_environment_variables[count.index]), 0)}"
  }
}

data "template_file" "region_env_var" {
  template = <<EOF
  {
    "name": "$${name}",
    "value": "$${value}"
  }
  EOF
  vars = {
    name  = "AWS_REGION"
    value = "${var.Region}"
  }
}


resource "aws_ecs_task_definition" "taskdef" {
  family    = "${var.Environment}-${var.Application}-taskdef"
  network_mode = "bridge"
  requires_compatibilities =  ["EC2"]
  task_role_arn = "${data.aws_iam_role.xyzgroup1global-taskrole.arn}"
  container_definitions=<<EOF
[
   {
      "environment": [${join(",", data.template_file.ecs_environment_variables_string.*.rendered)},${data.template_file.region_env_var.rendered}],
      "portMappings": [
          {
              "protocol": "tcp", 
              "containerPort": 80
          }
      ], 
      "name":"${var.Environment}-${var.Application}",
      "mountPoints":[

      ],
      "image":"${var.nexus_url}/${var.docker_image}:${var.docker_tag}",
      "logConfiguration":{
         "logDriver":"awslogs",
         "options":{
            "awslogs-region":"${var.Region}",
            "awslogs-stream-prefix":"${var.Application}",
            "awslogs-group":"${aws_cloudwatch_log_group.xyzgroup1global.name}"
         }
      },
      "memory": ${var.ecs_memory == "" ? var.ecs_memory_defaults["${var.Environment}"] : var.ecs_memory},
      "memoryReservation" :  ${var.ecs_memory_resevation == "" ? var.ecs_memory_resevation_defaults["${var.Environment}"] : var.ecs_memory_resevation},
      "cpu": ${var.ecs_cpu == "" ? var.ecs_cpu_defaults["${var.Environment}"] : var.ecs_cpu},
      "privileged":true,
      "essential":true,
      "volumesFrom":[

      ]
   }
]
EOF
}

data "aws_ecs_task_definition" "taskdef_data" {
  task_definition = "${aws_ecs_task_definition.taskdef.family}"
  depends_on = [ "aws_ecs_task_definition.taskdef" ]
}