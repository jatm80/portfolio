package org.some

import org.some.CredentialUtils

class TerraformUtilsV12
{
    static prepare(def script)
    {
        script.env.TERRAFORM_ECR = "${CredentialUtils.getAccountId('group1', 'stg')}.dkr.ecr.ap-southeast-2.amazonaws.com/terraform:0.12.13"
        script.env.TERRAFORM_CMD = 'docker run --user 1001:1001 --network host -w /app -v ${HOME}/.ssh:/home/jenkins/.ssh -v "$(pwd)":/app --env TF_LOG=INFO -v ${HOME}/.aws:/home/jenkins/.aws ${TERRAFORM_ECR}'
        script.sh """
        eval \$(aws ecr get-login --region ap-southeast-2 --no-include-email)
        docker pull ${script.env.TERRAFORM_ECR}
        """
    }

    static private _variables = [:];

    static addVariable(String name, String value)
    {
        _variables[name] = value;
    }

    static promoteTF(def script, String stage)
    {
       script.env.ROLE_ARN = "${CredentialUtils.getRoleArn(script._accountName, stage)}"
       script.env.BUCKET = "${TerraformUtilsV12.getBucket(script._accountName, script._appRegion, stage)}"
       script.env.REGION="${script.env.AWS_REGION}"
       script.env.STAGE = stage;
       String suffix = ""

       if (script._project == 'nc'){
            script.env.DOMAIN = 'notif';
        }
       else
       {
            script.env.DOMAIN = "${script._project}";   
       }
       if (script.env.REGION == "us-west-2"){
           suffix =".latam"
           
       } 

        String customVariables = "";
       _variables.each{entry -> customVariables += "-var '$entry.key=$entry.value' \\" + '\n'}
       customVariables = customVariables == "" ? "\\" : "";

       script.sh script: """

       rm -rf .terraform
       rm -rf ${script._tfvarsFolder}/.terraform

        ${script.env.TERRAFORM_CMD} init -backend=true -input=false \
            -backend-config="bucket=${script.env.BUCKET}" \
            -backend-config="key=${stage}-xyz-${script._project}-${script._appName}.tfstate" \
            -backend-config="role_arn=${script.env.ROLE_ARN}" \
            -backend-config="region=${script.env.REGION}" \
            -backend-config="dynamodb_table=terraform-state-locking" \
            -var-file='${script._tfvarsFolder}/terraform.${stage}.tfvars' \
            ${script._tfvarsFolder}/

        ${script.env.TERRAFORM_CMD} plan -out=tfplan -input=false \
            -var 'docker_tag=${script.env.DOCKER_TAG}.${script.env.BUILD_NUMBER}' \
            -var 'docker_image=${script.env.DOCKER_IMAGE}' \
            -var 'Region=${script.env.REGION}' \
            -var 'build_number=${script.env.BUILD_NUMBER}' \
            -var 'Tool_Task=xyz.${script._accountName}.${script._appName}.${stage}' \
            -var 'Application=xyz-${script._project}-${script._appName}' \
            -var 'ApplicationShortName=${script._appName}' \
            -var 'Service_domain=${stage}.${script.env.DOMAIN}.xyzglobal.net' \
            -var 'Service_name=${script._appName}${suffix}' \
            -var 'Environment=${stage}' \
            -var 'Project=xyz-${script._project}' \
            ${customVariables}
            -var-file='${script._tfvarsFolder}/terraform.${stage}.tfvars' ${script._tfvarsFolder}/

        ${script.env.TERRAFORM_CMD} apply -lock=true -input=false tfplan

        cd ${script._tfvarsFolder}
        ${script.env.TERRAFORM_CMD} init -backend=true -input=false \
            -backend-config="bucket=${script.env.BUCKET}" \
            -backend-config="key=${stage}-xyz-${script._project}-${script._appName}.tfstate" \
            -backend-config="region=${script.env.REGION}" \
            -backend-config="role_arn=${script.env.ROLE_ARN}" \
            -backend-config="dynamodb_table=terraform-state-locking" \
            -var-file='terraform.${stage}.tfvars' \
            .
        ${script.env.TERRAFORM_CMD} state rm aws_ecs_task_definition.taskdef

        """, returnStdout: true
    }

    static String getBucket(String accountName, String appRegion, String stage)
    {
        if(accountName == 'group1')
        {
            if (appRegion == 'ap-southeast-2') {
                return stage == 'prod' ? 'tfstate-4444444444444-ap-southeast-2' : 'tfstate-5555555555555-ap-southeast-2';
            }
            else
            {
                return stage == 'prod' ? 'tfstate-4444444444444-us-west-2' : 'tfstate-5555555555555-us-west-2';
            }
        }
        else
        {
            if (appRegion == 'ap-southeast-2'){
                return stage == 'prod' ? 'tfstate-111111111111-ap-southeast-2' : 'tfstate-333333333333-ap-southeast-2';
            }
            else
            {
                return stage == 'prod' ? 'tfstate-111111111111-us-west-2' : 'tfstate-333333333333-us-west-2';   
            }
        }
    }

    static String getEcsCluster(String accountName, String projectName, String appRegion, String stage)
    {
        if(accountName == 'group1')
        {
            return "${stage}-xyz-${projectName}-cluster"
        }
        else
        {
            if (appRegion == 'ap-southeast-2'){
                return 'acc2-au';
            }
            else
            {
                return 'acc2-cluster';   
            }
        }
    }
}


// S3 Buckets

// Group1
// tfstate-jenkins-slave-prod --> tfstate-4444444444444-ap-southeast-2
// latam-tfstate-jenkins-slave-prod --> tfstate-4444444444444-us-west-2

// tfstate-jenkins-slave --> tfstate-5555555555555-ap-southeast-2
// latam-tfstate-jenkins-slave-stg --> tfstate-5555555555555-us-west-2


// Acc2
// tfstate-notificationcentre-prod --> tfstate-111111111111-ap-southeast-2
// latam-tfstate-notificationcentre-prod --> tfstate-111111111111-us-west-2

// tfstate-notificationcentre --> tfstate-333333333333-ap-southeast-2
// latam-tfstate-notificationcentre --> tfstate-333333333333-us-west-2



