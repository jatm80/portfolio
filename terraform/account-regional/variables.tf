variable "region" {
  default = "ap-southeast-2"
}

variable "aws_profile" {
  default = ""
}
variable "aws_credentials_file" {
  default = ""
}

variable "vpc_id" {
  type = "map" 
  default = {
    stg = "vpc-asdasda"
    uat = "vpc-asdad"
    prod = "vpc-0dasda"
  } 
}

variable "aws_account" {
  type = "map"
  default = {
    stg = "111111111111"
    uat = "2222222222222"
    prod = "3333333333333"
  }  
}
variable "r53_zoneid" {
  type = "map" 
  default = {
    stg = "Z123123123213"
    uat = "Z123123123213"
    prod = "Z123123123213"
  }
}
variable "vpc_network" {
  type = "map"
  default = {
    stg ={
     cidr = ""
     publicA = ""
     publicB = ""
     privateA = ""
     privateB = ""
    }
    uat = {
     cidr = ""
     publicA = ""
     publicB = ""
     privateA = ""
     privateB = ""
    }
    prod = {
     cidr = ""
     publicA = ""
     publicB = ""
     privateA = ""
     privateB = ""
    }
  }
}
variable "tfwafrule" {
  type = "map" 
  default = {
    stg = ""
    uat = ""
    prod = ""
  }
}
variable "tfwebacl" {
  type = "map" 
  default = {
    stg = ""
    uat = ""
    prod = ""
  }
}
variable "wafipsetname" {
  type = "map" 
  default = {
    stg = ""
    uat = ""
    prod = ""
  }
}

variable "enable_cloudwatch" {
  type = "map"
  default = {
    stg = 1
    uat = 0
    prod = 1
  }
}

variable "api1_cert_arn" {
  type = "map"
  default = {
    stg =""
    uat = ""
    prod = ""
  }
}

variable "s3_legacy" {
  type = "map"
  default = {
    stg = "mediastorage-stg"
    uat= "mediastorage-stg"
    prod = "mediastorage-production"
  }
}

variable "cross_account_region2" {
  type = "map"
  default = {
    stg = "1111111111111"
    uat= "111111111111"
    prod = "2222222222222222"
  }
}


####################################
# DynamoDB Autoscaling

variable "api3db" {
  type = "map"
  default = {
    stg ={
     read = 2
     write = 2
     maxread = 4
     maxwrite = 4
     minread = 2
     minwrite = 2
    }
    uat ={
     read = 5
     write = 5
     maxread = 10
     maxwrite = 10
     minread = 5
     minwrite = 5
    }
    prod = {
     read = 5
     write = 5
     maxread = 10
     maxwrite = 10
     minread = 5
     minwrite = 5
    }
  }
}
variable "api2db" {
  type = "map"
  default = {
    stg ={
     read = 2
     write = 2
     maxread = 4
     maxwrite = 4
     minread = 2
     minwrite = 2
    }
    uat ={
     read = 15
     write = 5
     maxread = 30
     maxwrite = 10
     minread = 15
     minwrite = 5
    }
    prod = {
     read = 15
     write = 5
     maxread = 200
     maxwrite = 200
     minread = 15
     minwrite = 5
    }
  }
}
variable "api2Secondary" {
  type = "map"
  default = {
    stg ={
     read = 2
     write = 2
     maxread = 4
     maxwrite = 4
     minread = 2
     minwrite = 2
    }
    uat ={
     read = 5
     write = 5
     maxread = 10
     maxwrite = 10
     minread = 5
     minwrite = 5
    }
    prod = {
     read = 5
     write = 5
     maxread = 200
     maxwrite = 200
     minread = 5
     minwrite = 5
    }
  }
}
variable "api1sdb" {
  type = "map"
  default = {
    stg ={
     read = 2
     write = 2
     maxread = 4
     maxwrite = 4
     minread = 2
     minwrite = 2
    }
    uat ={
     read = 5
     write = 5
     maxread = 10
     maxwrite = 10
     minread = 5
     minwrite = 5
    }
    prod = {
     read = 5
     write = 5
     maxread = 10
     maxwrite = 10
     minread = 5
     minwrite = 5
    }
  }
}
variable "api1propertiesdb" {
  type = "map"
  default = {
    stg ={
     read = 0
     write = 0
     maxread = 0
     maxwrite = 0
     minread = 0
     minwrite = 0
    }
    uat ={
     read = 5
     write = 5
     maxread = 10
     maxwrite = 10
     minread = 5
     minwrite = 5
    }
    prod = {
     read = 5
     write = 5
     maxread = 10
     maxwrite = 10
     minread = 5
     minwrite = 5
    }
  }
}

variable "ecs_size" {
  type = "map"
  default = {
    stg ={
     max = 2
     desired = 1
    }
    uat ={
     max = 3
     desired = 1
    }
    prod = {
     max = 3
     desired = 3
    }
  }
}



variable "ignorestaging" {
  type = "map"
  default = {
    stg = 0
    uat = 1
    prod = 1
  }
}
####################################
# TAGs

variable "Role" { 
         type = "list" 
         default = ["asg","sg","lb","kn","lc","s3","db","sm","sqs"]
          }
variable "Tribe" { default = "echo" }
variable "Environment" { default = "stg" }
variable "Tool_Task" { default = "this.project1.-" }
variable "Application" { default = "this-project1" }
variable "Client_Vertical" { default = "null" }
variable "Tier" { default = "api" }
variable "Owner" { default = "Jesus Tovar:jesus.tovar+null.com.au" }
variable "Tool_Name" { default = "Terraform+Jenkins"}
variable "Service_name" { default = "steps"}

# AMIs ID
variable "image" {
  type = "map"
  default = {
    docker_container 	= "ami-05222d845b5812e7f" # amzn-ami-2018.03.20200319-amazon-ecs-optimized
  }
}

variable "instance_type" {
  type = "map"
  default = {
    stg    = "t3.medium"
    uat    = "t3.medium"
    prod   = "c5.xlarge"
  }
}

variable "https_listener_cert" {
  type = "map"
  default = {
    stg    = ""
    uat    = ""
    prod   = ""
  }
}

variable "additional_listener_cert" {
  type = "map"
  default = { 
    stg = "" 
    uat = ""
    prod = ""
  }
}

variable "additional_listener_cert_install" {
  type = "map"
  default = {
    ap-southeast-2 = 0
    us-west-2 = 1
  }
}



variable "dynamoEnv" {
  type = "map"
  default = {
    stg    = ""
    uat    = "-uat"
    prod   = ""
  }
}

variable "key_name" {
  default = "key"
}

variable "load_balancer_subnets" {
  type    = "list"
}

variable "public_load_balancer_subnets" {
  type    = "list"
}

variable "subnet_ids" {
  type    = "list"
}

variable "s3_bucket_prefix" { }

variable "time_zone" { }

variable "iso_region" {
  type = "map"
  default = {
    ap-southeast-2 = "region1"
    us-west-2 = "region2"
  }
}

variable "alb_accountid" {
  type = "map"
    default = {
    ap-southeast-2 = "783225319266"
    us-west-2 = "797873946194"
  }
}
