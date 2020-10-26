resource "aws_dynamodb_table" "dynamosteps" {
  name           = "this-project1-api2${var.dynamoEnv["${var.Environment}"]}"
  read_capacity  = "${lookup("${var.api2db["${var.Environment}"]}", "read")}"
  write_capacity = "${lookup("${var.api2db["${var.Environment}"]}", "write")}"
  hash_key       = "VirtualNumber"

 attribute {
    name = "VirtualNumber"
    type = "S"
   }
   attribute {
    name = "api1Id"
    type = "S"
  }

  global_secondary_index {
    name               = "api1Id-index"
    hash_key           = "api1Id"
    range_key          = ""
    write_capacity     = 50
    read_capacity      = 50
    projection_type    = "ALL"
    non_key_attributes = []
  }

  lifecycle {
    ignore_changes = [ "read_capacity", "write_capacity","global_secondary_index" ]
  }

  tags = {
        Role = "${var.Role[6]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[6]}-${var.Application}"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
  }
}