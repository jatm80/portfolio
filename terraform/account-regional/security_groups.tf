####  Security Group

resource "aws_security_group" "thisproject1global-lb-sg" {
  name_prefix = "${var.Environment}-${var.Application}-"
  description = "${var.Environment}-${var.Application}"
  vpc_id      = "${var.vpc_id["${var.Environment}"]}"

  tags = {
        Role = "${var.Role[1]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[1]}-${var.Application}-lb"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${lookup("${var.vpc_network["${var.Environment}"]}", "cidr")}"]
  }


  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["10.0.0.0/8"]
  }
}


resource "aws_security_group" "thisproject1global-ec2-sg" {
  name_prefix = "${var.Environment}-${var.Application}-"
  description = "${var.Environment}-${var.Application}"
  vpc_id      = "${var.vpc_id["${var.Environment}"]}"

  tags = {
        Role = "${var.Role[1]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[1]}-${var.Application}-ec2"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${lookup("${var.vpc_network["${var.Environment}"]}", "cidr")}"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 51678
    to_port     = 51678
    cidr_blocks = ["10.240.8.0/21"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["10.0.0.0/8"]
  }

}

# This will allow requests from Regional IPs(check WAF) only

resource "aws_security_group" "public_thisproject1global-lb-sg" {
  name_prefix = "${var.Environment}-${var.Application}-pub"
  description = "${var.Environment}-${var.Application}-public"
  vpc_id      = "${var.vpc_id["${var.Environment}"]}"

  tags = {
        Role = "${var.Role[1]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[1]}-${var.Application}-lb"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }

  egress {
    description = ""
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "No access on 80"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["${lookup("${var.vpc_network["${var.Environment}"]}", "cidr")}"]
  }

  ingress {
    description = "Allow HTTPS"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "Allow HTTPS for WebSocket"
    protocol    = "tcp"
    from_port   = 5065
    to_port     = 5065
    cidr_blocks = ["0.0.0.0/0"]
  }
}