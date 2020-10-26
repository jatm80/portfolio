variable "ari_rabbitconfiguration_uris" { type = "map" }
variable "ari_rabbitconfiguration_hostnames" { type = "map" }

# EventPublisherServiceSettings 

resource "aws_ssm_parameter" "ari_asterisk_username" {
  name  = "/${var.Application}-${var.Environment}/Ari/AsteriskSettings/Username"
  type  = "SecureString"
  value = "--place-holder--"
  lifecycle {
    ignore_changes = ["value"]
  }
}
resource "aws_ssm_parameter" "ari_asterisk_password" {
  name  = "/${var.Application}-${var.Environment}/Ari/AsteriskSettings/Password"
  type  = "SecureString"
  value = "--place-holder--"
  lifecycle {
    ignore_changes = ["value"]
  }
}

# EventPublisherServiceSettings

resource "aws_ssm_parameter" "ari_event_publisher_exchange_name" {
  name  = "/${var.Application}-${var.Environment}/Ari/EventPublisherServiceSettings/ExchangeName"
  type  = "String"
  value = "${var.Environment == "uat" ? "This.Project.EventsUat" : "This.Project.Events"}"
}

resource "aws_ssm_parameter" "ari_event_publisher_firehose_stream_name" {
  name  = "/${var.Application}-${var.Environment}/Ari/EventPublisherServiceSettings/FireHoseDeliveryStreamName"
  type  = "String"
  value = "${aws_kinesis_firehose_delivery_stream.kinesis_firehose_ext_s3.name}"
}

# Rabbit Configuration

resource "aws_ssm_parameter" "ari_rabbitconfiguration_uri" {
  name  = "/${var.Application}-${var.Environment}/Ari/RabbitConfiguration/Uri"
  type  = "String"
  value = "${var.ari_rabbitconfiguration_uris["${var.Environment}"]}"
}

resource "aws_ssm_parameter" "ari_rabbitconfiguration_hostname" {
  name  = "/${var.Application}-${var.Environment}/Ari/RabbitConfiguration/Hostnames"
  type  = "StringList"
  value = "${var.ari_rabbitconfiguration_hostnames["${var.Environment}"]}"
}

resource "aws_ssm_parameter" "ari_rabbitconfiguration_username" {
  name  = "/${var.Application}-${var.Environment}/Ari/RabbitConfiguration/Username"
  type  = "SecureString"
  value = "--placeholder--"
  lifecycle {
    ignore_changes = ["value"]
  }
}
resource "aws_ssm_parameter" "ari_rabbitconfiguration_password" {
  name  = "/${var.Application}-${var.Environment}/Ari/RabbitConfiguration/Password"
  type  = "SecureString"
  value = "--placeholder--"
  lifecycle {
    ignore_changes = ["value"]
  }
}
resource "aws_ssm_parameter" "ari_rabbitconfiguration_requested_heart_beat" {
  name  = "/${var.Application}-${var.Environment}/Ari/RabbitConfiguration/RequestedHeartBeat"
  type  = "String"
  value = 5
}
resource "aws_ssm_parameter" "ari_rabbitconfiguration_network_recovery_interval_seconds" {
  name  = "/${var.Application}-${var.Environment}/Ari/RabbitConfiguration/NetworkRecoveryIntervalInSeconds"
  type  = "String"
  value = 5
}

/** configuration for api1MessageHandler */

resource "aws_ssm_parameter" "ari_api1_message_handler_server_hostnames" {
  name  = "/${var.Application}-${var.Environment}/Ari/api1MessageHandler/Server/Hostnames"
  type  = "StringList"
  value = "${aws_ssm_parameter.api3_api_rabbit_configuration_hostname.value}" # same server with api3 api
  lifecycle {
    ignore_changes = ["value"]
  }
}
resource "aws_ssm_parameter" "ari_api1_message_handler_server_username" {
  name  = "/${var.Application}-${var.Environment}/Ari/api1MessageHandler/Server/Username"
  type  = "SecureString"
  value = "${aws_ssm_parameter.api3_api_rabbit_configuration_request_username.value}" # same server with api3 api
  lifecycle {
    ignore_changes = ["value"]
  }
}
resource "aws_ssm_parameter" "ari_api1_message_handler_server_password" {
  name  = "/${var.Application}-${var.Environment}/Ari/api1MessageHandler/Server/Password"
  type  = "SecureString"
  value = "${aws_ssm_parameter.api3_api_rabbit_configuration_network_password.value}" # same server with api3 api
  lifecycle {
    ignore_changes = ["value"]
  }
}
resource "aws_ssm_parameter" "ari_api1_message_handler_queue_name" {
  name  = "/${var.Application}-${var.Environment}/Ari/api1MessageHandler/QueueName"
  type  = "String"
  value = "This.Project.Originate"
}
