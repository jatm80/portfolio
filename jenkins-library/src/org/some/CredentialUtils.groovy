package org.some

class CredentialUtils
{
    static assumeRole(def script, String stage)
    {
        script.env.SESSION = "${script._accountName}-${script._appName}"
        script.env.ROLE_ARN = CredentialUtils.getRoleArn(script._accountName, stage)
        script.env.AWS_ACCESS_KEY_ID = ""
        script.env.AWS_SECRET_ACCESS_KEY = ""
        script.env.AWS_SESSION_TOKEN = ""
        script.env.ROLE = "${script.sh(returnStdout: true,script: 'aws sts assume-role --role-arn "${ROLE_ARN}" --role-session-name "${SESSION}"')}"
        script.env.AWS_ACCESS_KEY_ID = "${script.sh(returnStdout: true,script: 'echo ${ROLE} | jq .Credentials.AccessKeyId | xargs ')}".trim()
        script.env.AWS_SECRET_ACCESS_KEY = "${script.sh(returnStdout: true,script: 'echo ${ROLE} | jq .Credentials.SecretAccessKey | xargs')}".trim()
        script.env.AWS_SESSION_TOKEN = "${script.sh(returnStdout: true,script: 'echo ${ROLE} | jq .Credentials.SessionToken | xargs')}".trim()
    }

    static String getRoleArn(String accountName, String stage)
    {
        return "arn:aws:iam::${CredentialUtils.getAccountId(accountName, stage)}:role/jenkins.role";
    }

    static String getAccountId(String accountName, String stage)
    {
        if(accountName == 'group1')
        {
            return stage == 'prod' ? '4444444444444' : 5555555555555';
        }
        else
        {
            return stage == 'prod' ? '111111111111' : '333333333333';
        }
    }
}