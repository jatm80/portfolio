#!/bin/bash
AWS_PROFILE="default"
AWS_CREDENTIALS_FILE=$(echo $HOME/.aws/credentials)	
APP_NAME="this-project1-global-iam"
REGION="ap-southeast-2"
BUCKET="tfstate-jenkins-slave-prod"

rm -rf .terraform/
rm -rf tfplan
terraform init -backend=true -input=false  \
        -backend-config="bucket=$BUCKET" \
        -backend-config="key=$APP_NAME.tfstate" \
        -backend-config="region=$REGION" \
        -backend-config="profile=$AWS_PROFILE" \
        -backend-config="shared_credentials_file=$AWS_CREDENTIALS_FILE" 

terraform validate .


terraform plan -out=tfplan -input=false\
                        -var='Environment=prod' .
