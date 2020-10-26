variable "domain_suffix" { default = "" }

# Base url for data api3 API
resource "aws_ssm_parameter" "api3_api_endpoint" {
  name  = "/${var.Application}-${var.Environment}/Endpoints/Api3Api"
  type  = "String"
  value = "http://api3${var.domain_suffix}.${var.Environment}.project1.localdomain/"
}

# Base url for the api1 API
resource "aws_ssm_parameter" "api1_api_endpoint" {
  name  = "/${var.Application}-${var.Environment}/Endpoints/api1Api"
  type  = "String"
  value = "http://api1${var.domain_suffix}.${var.Environment}.project1.localdomain/"
}

resource "aws_ssm_parameter" "appkey_api_endpoint" {
  name  = "/${var.Application}-${var.Environment}/Endpoints/AppKeyApi"
  type  = "String"
  value = "https://appkey-api${var.domain_suffix}.${var.Environment}.gps.localdomain"
}

resource "aws_ssm_parameter" "authorisation_api_endpoint" {
  name  = "/${var.Application}-${var.Environment}/Endpoints/AuthorizationApi"
  type  = "String"
  value = "https://authorization-api${var.domain_suffix}.${var.Environment}.gps.localdomain"
}

# audio API

resource "aws_ssm_parameter" "audio_api_endpoint" {
  name  = "/${var.Application}-${var.Environment}/Endpoints/AudioApi"
  type  = "String"
  value = "https://audio-api${var.domain_suffix}.${var.Environment}.project1.localdomain"
}