region = "us-west-2"

vpc_id = {
  stg  = "vpc-0e9bade8a423fe012"
  uat  = "vpc-0e9bade8a423fe012"
  prod = "vpc-0444ea613a8df146e"
}

aws_account = {
  stg  = "014230799916"
  uat  = "014230799916"
  prod = "479808380445"
}

vpc_network = {
  stg = {
    cidr     = "10.221.160.0/21"
    publicA  = "subnet-06e826bb1a2c95a83"
    publicB  = "subnet-029f7e36a22e3c91b"
    publicC  = "subnet-092db931840b08f5e"
    privateA = "subnet-06bb9fb45cfed98cb"
    privateB = "subnet-0a3e63cae30940dbc"
    privateC = "subnet-058c18290a3ba4891"
  }

  uat = {
    cidr     = "10.221.160.0/21"
    publicA  = "subnet-06e826bb1a2c95a83"
    publicB  = "subnet-029f7e36a22e3c91b"
    publicC  = "subnet-092db931840b08f5e"
    privateA = "subnet-06bb9fb45cfed98cb"
    privateB = "subnet-0a3e63cae30940dbc"
    privateC = "subnet-058c18290a3ba4891"
  }

  prod = {
    cidr     = "10.223.160.0/21"
    publicA  = "subnet-0e1259256b6f8b422"
    publicB  = "subnet-0b4b09746020df211"
    publicC  = "subnet-0df5b1830f37745ca"
    privateA = "subnet-0d1405b8dd4c768cd"
    privateB = "subnet-0fbbc282397dc7f91"
    privateC = "subnet-0387e6edb7b760154"
  }
}

Owner = "Felipe Oliva:felipe.oliva+null.com.au"

Tool_Task = "this-project1.-"

image = {
  docker_container = "ami-0f7bc74af1927e7c8" # us-west-2 #amzn-ami-2018.03.y-amazon-ecs-optimized
}

enable_cloudwatch = {
  stg  = 0
  uat  = 0
  prod = 0
}

https_listener_cert = {
  stg  = "arn:aws:acm:us-west-2:014230799916:certificate/70f3b99c-a541-4499-81d9-2bff513c4c35"
  uat  = "arn:aws:acm:us-west-2:014230799916:certificate/70f3b99c-a541-4499-81d9-2bff513c4c35"
  prod = "arn:aws:acm:us-west-2:479808380445:certificate/832c7857-870e-40d9-bdcc-10f9164e6c4d"
}

additional_listener_cert = {
  stg  = "arn:aws:acm:us-west-2:014230799916:certificate/10322c61-fc30-45b9-aabd-1fcb904679b8"
  uat  = "arn:aws:acm:us-west-2:014230799916:certificate/10322c61-fc30-45b9-aabd-1fcb904679b8"
  prod = "arn:aws:acm:us-west-2:479808380445:certificate/9b028813-bedc-4c9d-aa29-b2c5a4f02988"
}

load_balancer_subnets = [
  "privateA",
  "privateB",
  "privateC"
]

public_load_balancer_subnets = [
  "publicA",
  "publicB",
  "publicC"
]

subnet_ids = [
  "privateA",
  "privateB",
  "privateC"
]

s3_bucket_prefix = "region2-"

time_zone = "UTC"

api3_api_rabbitmq_api3_topics = {
  stg  = "This.Project.Number"
  uat  = "This.Project.Number.Uat"
  prod = "This.Project.Number"
}

api3_api_rabbit_configuration_uris = {
  stg  = "amqp://rmq.dev.localdomain/"
  uat  = "amqp://rmq.dev.localdomain/"
  prod = "amqp://prod-aws-rmq-13.internal.local/"
}

api3_api_rabbit_configuration_hostnames = {
  stg  = "rmq.dev.localdomain"
  uat  = "rmq.dev.localdomain"
  prod = "prod-aws-rmq-13.internal.local,prod-aws-rmq-14.internal.local,prod-aws-rmq-15.internal.local"
}

template_api_endpoints = {
  stg  = "https://template-api.stg.gps.localdomain/api"
  uat  = "https://template-api.stg.gps.localdomain/api"
  prod = "https://template-api.prod.gps.localdomain/api"
}

api1_api_rabbitmq_api2_topics = {
  stg  = "This.Project.VirtualNumber"
  uat  = "This.Project.VirtualNumberUat"
  prod = "This.Project.VirtualNumber"
}

api1_api_rabbitmq_api1_topics = {
  stg  = "This.Project.api1s"
  uat  = "This.Project.api1sUat"
  prod = "This.Project.api1s"
}

api2_subscriber_rabbitconfiguration_uris = {
  stg  = "amqp://rmq.dev.localdomain/"
  uat  = "amqp://rmq.dev.localdomain/"
  prod = "amqp://prod-aws-rmq-13.internal.local/"
}

api2_subscriber_rabbitconfiguration_hostnames = {
  stg  = "rmq.dev.localdomain"
  uat  = "rmq.dev.localdomain"
  prod = "prod-aws-rmq-13.internal.local,prod-aws-rmq-14.internal.local,prod-aws-rmq-15.internal.local"
}

api2_subscriber_subscribers_queue_name = {
  stg  = "This.Project.api2"
  uat  = "This.Project.api2Uat"
  prod = "This.Project.api2"
}

api2_subscriber_subscribers_exchange_name = {
  stg  = "This.Project.VirtualNumber"
  uat  = "This.Project.VirtualNumberUat"
  prod = "This.Project.VirtualNumber"
}

ari_rabbitconfiguration_uris = {
  stg  = "amqp://rmq.dev.localdomain/"
  uat  = "amqp://rmq.dev.localdomain/"
  prod = "amqp://prod-aws-rmq-13.internal.local/"
}

ari_rabbitconfiguration_hostnames = {
  stg  = "rmq.dev.localdomain"
  uat  = "rmq.dev.localdomain"
  prod = "prod-aws-rmq-13.internal.local,prod-aws-rmq-14.internal.local,prod-aws-rmq-15.internal.local"
}

domain_suffix = ".region2"
