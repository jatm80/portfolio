#!/bin/bash
echo ECS_CLUSTER=${ecs_cluster} >> /etc/ecs/ecs.config

# Usual ECS User data information
echo ECS_IMAGE_PULL_BEHAVIOR=prefer-cached >> /etc/ecs/ecs.config
# Set localtime
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/${time_zone} /etc/localtime
# Add Docker Repo Certificates
mkdir -p /etc/docker/certs.d/nexus.prod.com:9082
mkdir -p /etc/docker/certs.d/nexus.aws.prod.com:9083
echo "-----BEGIN CERTIFICATE-----
some cert
-----END CERTIFICATE-----" > /etc/docker/certs.d/nexus.prod.com:9082/ca.crt
cp /etc/docker/certs.d/nexus.prod.com:9082/ca.crt /etc/docker/certs.d/nexus.aws.prod.com:9083/ca.crt
echo ECS_ENGINE_region1TH_TYPE=dockercfg >> /etc/ecs/ecs.config
echo ECS_ENGINE_region1TH_DATA='{"nexus.prod.com:9082":{"auth":"Zdasldjalksdjalks==","email":"dockerman@null.com.au"},"nexus.aws.prod.com:9083":{"auth":"ZG9ja2VybWFuOmRvY2tlcm1hbg==","email":"dockerman@null.com.au"}}' >> /etc/ecs/ecs.config
yum -y install aws-cli jq
export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
# Update crontab
crontab -l > rootcron
echo "10 */1 * * * docker system prune -af > /tmp/dockerclean.log 2>&1" >> rootcron
crontab rootcron
rm -f rootcron