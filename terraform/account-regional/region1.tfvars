load_balancer_subnets = [
  "privateA",
  "privateB",
]

public_load_balancer_subnets = [
  "publicA",
  "publicB",
]

subnet_ids = [
  "privateA",
  "privateB",
  "privateC"
]

time_zone = "Region1/Melbourne"

s3_bucket_prefix = ""

api3_api_rabbitmq_api3_topics = {
  stg  = "This.Project.Number"
  uat  = "This.Project.Number.Uat"
  prod = "This.Project.Number"
}

api3_api_rabbit_configuration_uris = {
  stg  = "amqp://stg-aws-rmq-01.internal.local/"
  uat  = "amqp://stg-aws-rmq-01.internal.local/"
  prod = "amqp://prod-aws-rmq-01.internal.local/"
}

api3_api_rabbit_configuration_hostnames = {
  stg  = "stg-aws-rmq-01.internal.local"
  uat  = "stg-aws-rmq-01.internal.local"
  prod = "prod-aws-rmq-01.internal.local,prod-aws-rmq-02.internal.local,prod-aws-rmq-03.internal.local"
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
  stg  = "amqp://stg-aws-rmq-01.internal.local/"
  uat  = "amqp://stg-aws-rmq-01.internal.local/"
  prod = "amqp://prod-aws-rmq-01.internal.local/"
}

api2_subscriber_rabbitconfiguration_hostnames = {
  stg  = "stg-aws-rmq-01.internal.local"
  uat  = "stg-aws-rmq-01.internal.local"
  prod = "prod-aws-rmq-01.internal.local,prod-aws-rmq-02.internal.local,prod-aws-rmq-03.internal.local"
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
  stg  = "amqp://stg-aws-rmq-01.internal.local/"
  uat  = "amqp://stg-aws-rmq-01.internal.local/"
  prod = "amqp://prod-aws-rmq-04.internal.local/"
}

ari_rabbitconfiguration_hostnames = {
  stg  = "stg-aws-rmq-01.internal.local"
  uat  = "stg-aws-rmq-01.internal.local"
  prod = "prod-aws-rmq-04.internal.local,prod-aws-rmq-05.internal.local,prod-aws-rmq-06.internal.local"
}
