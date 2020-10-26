provider "aws" {
  region = "${var.Region}"
  assume_role{    
    role_arn= "arn:aws:iam::${lookup("${var.aws_account["${var.Environment}"]}", "${var.Project}")}:role/jenkins.role"  
   }
  version = "= 2.35"
}

variable "vpc_id" {
  type="map"
  default = {
    stg = {
         xyz-group1-ap-southeast-2 = "vpc-xyz"
         xyz-group1-us-west-2 = "vpc-xyz"
         xyz-nc-ap-southeast-2 = "vpc-xyz"
         xyz-nc-us-west-2 = "vpc-is-not-created"
         xyz-acc3-ap-southeast-2 = "vpc-xyz"
         xyz-acc3-us-west-2 =  "vpc-xyz"
    }
    uat = {
         xyz-group1-ap-southeast-2 = "vpc-xyz"
         xyz-group1-us-west-2 = "vpc-xyz"
         xyz-nc-ap-southeast-2 = "vpc-xyz"
         xyz-nc-us-west-2 = "vpc-is-not-created"
         xyz-acc3-ap-southeast-2 = "vpc-xyz"
         xyz-acc3-us-west-2 =  "vpc-xyz"
    }
    prod = {
         xyz-group1-ap-southeast-2 = "vpc-xyz"
         xyz-group1-us-west-2 = "vpc-xyz"
         xyz-nc-ap-southeast-2 = "vpc-xyz"
         xyz-nc-us-west-2 = "vpc-is-not-created"
         xyz-acc3-ap-southeast-2 = "vpc-xyz"
         xyz-acc3-us-west-2 =  "vpc-xyz"
    }
  }
}

variable "aws_account" {
  type="map"
  default = {
    stg = {
      xyz-group1 = "5555555555555"
      xyz-group2 = "5555555555555"
      xyz-acc3 = "333333333333"
    }
    uat = {
      xyz-group1 = "5555555555555"
      xyz-group2 = "5555555555555"
      xyz-acc3 = "333333333333"
    }  
    prod = {
      xyz-group1 = "4444444444444"
      xyz-group2 = "4444444444444"
      xyz-acc3 = "111111111111"
    
    }
  }
}

variable "ecs_desired_count" {
  default = "1"
}
variable "ecs_drain_seconds" {
  type="map"
  default = {
    prod=70
    stg=5
    uat=5
  }
}

variable "ecs_environment_variables" {
  type = "list"
  default = []
}
variable "nexus_url"  { 
  default = "nexus.aws.artifacts.com.au:9083" 
}
variable "docker_image" { }
variable "docker_tag" { }

variable "ecs_cpu_defaults" {
  type="map"
  default = {
    stg="0"
    uat="256"
    prod="256"
  }
}
variable "ecs_memory_defaults" {
  type="map"
  default = {
    stg="256"
    uat="256"
    prod="256"
  }
}

variable "ecs_memory_resevation_defaults" {
  type="map"
  default = {
    stg="128"
    uat="128"
    prod="128"
  }
}

variable "ecs_cpu" {
  default=""
}
variable "ecs_memory" {
  default=""
}

variable "ecs_memory_resevation" {
  default=""
}

variable "Service_name" { }
variable "Service_domain" { }


variable "ecs_cluster_name" { 
  type = "map"
  default = {
    ap-southeast-2 = { xyz-acc3 = "acc2-au" }
    us-west-2      = { xyz-acc3 = "acc2-cluster" }
  }
}

variable "build_number" { 
  default = ""
}

#####################################
# TAGs

variable "Role" {
     type = "list" 
     default = ["asg","sg","lb","kn","lc","s3","db"]
     }
variable "Tribe" { default = "echo" }
variable "Environment" { default = "stg" }
variable "Tool_Task" {  }
variable "Application" {  }
variable "ApplicationShortName" { }
variable "Project" {default = "xyz-acc3"}
variable "Client_Vertical" { default = "some" }
variable "Region" { default = "ap-southeast-2" }
variable "Tier" { default = "api" }
variable "Owner" { default = "My Team" }
variable "Tool_Name" { default = "Terraform+Jenkins"}
