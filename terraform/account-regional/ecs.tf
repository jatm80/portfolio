########### ECS
resource "aws_ecs_cluster" "docker_cluster" {
  name = "${var.Environment}-${var.Application}-cluster"
 
  setting {
    name = "containerInsights"
    value = "enabled"
   }


  tags = {
        Role = "${var.Role[0]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[0]}-${var.Application}"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }
}


# EC2 Docker

resource "aws_autoscaling_group" "auto_scaling_thisproject1global" {
  name_prefix  = "${var.Environment}-${var.Application}-${var.Role[0]}-"

  availability_zones = [
    "${var.region}a",
    "${var.region}b",
  ]

  max_size                  = "${lookup("${var.ecs_size["${var.Environment}"]}", "max")}"
  min_size                  = 1
  desired_capacity          = "${lookup("${var.ecs_size["${var.Environment}"]}", "desired")}"
   lifecycle {
    ignore_changes = [ "max_size", "min_size", "desired_capacity" ]
  }
  health_check_grace_period = 180
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.thisproject1global_lc.name}"

  vpc_zone_identifier = "${matchkeys("${values("${var.vpc_network["${var.Environment}"]}")}", "${keys("${var.vpc_network["${var.Environment}"]}")}", "${var.subnet_ids}")}"

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

   tags = [
    {
      "key"                 = "Role"
      "value"               = "${var.Role[0]}"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Tribe"
      "value"               = "${var.Tribe}"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Environment"
      "value"               = "${var.Environment}"
      "propagate_at_launch" = true
    },
	    {
      "key"                 = "Name"
      "value"               = "${var.Environment}-${var.Role[0]}-${var.Application}-ecs"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Application"
      "value"               = "${var.Application}"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Region"
      "value"               = "${var.region}"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Tier"
      "value"               = "${var.Tier}"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Owner"
      "value"               = "${var.Owner}"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Tool_Name"
      "value"               = "${var.Tool_Name}"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Tool_Task"
      "value"               = "${var.Tool_Task}"
      "propagate_at_launch" = true
    }
  ]
  
}


# Launch Configuration

resource "aws_launch_configuration" "thisproject1global_lc" {
  name_prefix          = "${var.Environment}-${var.Application}-"
  image_id             = "${var.image["docker_container"]}"
  instance_type        = "${var.instance_type["${var.Environment}"]}"
  enable_monitoring    = true
  key_name             = "${var.key_name}"
  iam_instance_profile = "${data.aws_iam_instance_profile.thisproject1global_profile.arn}"
  security_groups             = ["${aws_security_group.thisproject1global-ec2-sg.id}"]
  associate_public_ip_address = false

  root_block_device {
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data = "${data.template_file.user_data_thisproject1global_packer.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data_thisproject1global_packer" {
  template = "${file("user_data_template_thisproject1global.tpl")}"
  vars = {
    ecs_cluster = "${var.Environment}-${var.Application}-cluster"
    time_zone = "${var.time_zone}"
  }
}