# Secrets Manager for Handsfree service

resource "aws_secretsmanager_secret" "this_secretmanager" {
  name = "${var.Environment}-${var.Application}-other"

  tags = {
        Role = "${var.Role[7]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[7]}-${var.Application}"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }

}


resource "aws_secretsmanager_secret" "this_secretmanager_rmq" {
  name = "${var.Environment}-${var.Application}-ari-rabbit-configuration"

  tags = {
        Role = "${var.Role[7]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[7]}-${var.Application}-ari-rabbit-configuration"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }

}

resource "aws_secretsmanager_secret" "this_secretmanager_asterisk" {
  name = "${var.Environment}-${var.Application}-ari-asterisk-configuration"

  tags = {
        Role = "${var.Role[7]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[7]}-${var.Application}-ari-asterisk-configuration"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }

}



resource "aws_secretsmanager_secret" "this_secretmanager_api1" {
  name = "${var.Environment}-${var.Application}-ari-api1api-configuration"

  tags = {
        Role = "${var.Role[7]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[7]}-${var.Application}-ari-api1api-configuration"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }

}