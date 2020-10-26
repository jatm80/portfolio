package org.some;

class IntegrationTests
{
    static execute(def pipeline)
    {
        // Build the tests
        pipeline.sh """
        rm -rf ${pipeline.env.WORKSPACE}/src-tests
        mkdir ${pipeline.env.WORKSPACE}/src-tests
        cd ${pipeline.env.WORKSPACE}/src-tests
        GIT_SSH_COMMAND="${pipeline._automatedTestGitSSHCommand}" git clone --single-branch --branch ${pipeline._automatedTestBranchName} ${pipeline._automatedTestRepository} ${pipeline.env.WORKSPACE}/src-tests
        docker build -t ${pipeline._appName}-tests -f ${pipeline.env.WORKSPACE}/src-tests/${pipeline._automatedTestDockerfileName} ${pipeline.env.WORKSPACE}/src-tests
        """
        // Run the tests
        pipeline.sh """
            docker run  \
            --env AWS_ACCESS_KEY_ID=${pipeline.env.AWS_ACCESS_KEY_ID} \
            --env AWS_SECRET_ACCESS_KEY=${pipeline.env.AWS_SECRET_ACCESS_KEY} \
            --env AWS_SESSION_TOKEN=${pipeline.env.AWS_SESSION_TOKEN} \
             ${pipeline._appName}-tests
        """
    }
}