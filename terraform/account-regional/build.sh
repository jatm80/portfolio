#!/bin/bash

set -e

#############################
#    Select region2 vs. region1    #
#############################

echo ==========================
echo Hello, where to deploy to?
echo ==========================
echo 
echo 1. Region1
echo 2. region2
echo
echo Press 1 or Enter to deploy to Region1.
read region1_vs_region2_menu_choice

#############################
# Set Environment Variables #
#############################

export AWS_PROFILE="default"
export AWS_CREDENTIALS_FILE=$(echo $HOME/.aws/credentials)	
BRANCH=$(git symbolic-ref --short HEAD)

if [ "$BRANCH" != "master" ]
then
   echo -e "\033[1;33mWARNING: YOU ARE NOT WORKING IN MASTER BRANCH...\e[0m";
   echo -e "\033[1;33mWARNING: CREATE A PR AND MERGE THIS CODE TO MASTER AS SOON AS TESTED...\e[0m";
   echo -e "\033[1;33mWARNING: I AM NOT JOKING, THE WRATH OF THE EGYPTIAN GODS WILL FALL ON YOU....\e[0m";
   sleep 5;
fi

if [ "$region1_vs_region2_menu_choice" = "2" ]
then
    echo -e "\033[1;33mDEPLOYING TO region2..\e[0m";
    export VAR_FILE='region2.tfvars'
    export REGION="us-west-2"
    if [ "$ENVIRONMENT" = "prod" ]
    then
        export BUCKET="region2-tfstate-jenkins-slave-prod"
        export APP_NAME="region2-this-project1-global-prod"
    fi
    if [ "$ENVIRONMENT" = "stg" ]
    then
        export BUCKET="region2-tfstate-jenkins-slave"
        export APP_NAME="region2-this-project1-global-stg"
    fi
    if [ "$ENVIRONMENT" = "uat" ]
    then
        export BUCKET="region2-tfstate-jenkins-slave"
        export APP_NAME="region2-this-project1-global-uat"
    fi
else
    echo -e "\033[1;32mDEPLOYING TO region1STRALIA..\e[0m";
    export VAR_FILE='region1.tfvars'
    export REGION="ap-southeast-2"

    if [ "$ENVIRONMENT" = "uat" ]
    then
        export APP_NAME="this-project1-global-uat"
    else
        export APP_NAME="this-project1-global"
    fi

    if [ "$ENVIRONMENT" = "prod" ]
    then
        export BUCKET="tfstate-jenkins-slave-prod"
    else
        export BUCKET="tfstate-jenkins-slave"
    fi
fi

#############################
#     Execute Terraform     #
#############################

cd $(dirname "$0")

rm -rf .terraform/
rm -rf tfplan
terraform init -backend=true -input=false  \
        -backend-config="bucket=$BUCKET" \
        -backend-config="key=$APP_NAME.tfstate" \
        -backend-config="region=$REGION" \
        -backend-config="profile=$AWS_PROFILE" \
        -backend-config="shared_credentials_file=$AWS_CREDENTIALS_FILE" \
        -var-file="$VAR_FILE" .

terraform validate .

terraform plan \
        -var-file="$VAR_FILE" \
        -out=tfplan \
        -input=false \
        -var="Environment=$ENVIRONMENT" .
