provider "aws" { 
  region = "${var.region}"
  version = "= 2.31.0"
  profile = "${var.aws_profile}"
  shared_credentials_file = "${var.aws_credentials_file}" 
}

terraform {
  backend "s3" { }
} 
