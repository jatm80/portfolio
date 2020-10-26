variable "cross_account_region2" {
  type = "map"
  default = {
    stg = "111111111111"
    uat= "111111111111"
    prod = "111111111111"
  }
}
variable "Environment" { default = "stg" }
variable "Application" { default = "this-project1" }

variable "region" {
  default = "ap-southeast-2"
}

variable "aws_profile" {
  default = ""
}
variable "aws_credentials_file" {
  default = ""
}

variable "aws_account" {
  default = {
    stg = "111111111111"
    uat= "111111111111"
    prod = "111111111111"
  }
}


variable "au_s3_legacy" {
  default = {
    stg = "mediastorage-stg"
    uat= "mediastorage-stg"
    prod = "mediastorage-production"
  }
}

variable "s3_bucket_prefix" {
  default = "region2-"
 }