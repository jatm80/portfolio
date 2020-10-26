import org.some.CredentialUtils
import org.some.TerraformUtilsV12
import org.some.IntegrationTests
import org.some.NotificationsUtils
import org.some.PrebuildUtils

def call(Closure init = null) {
    // Declare and set default value for variables here.
    _useHttps = false;
    _useHttp = true;
    _useLoadBalancer = true;
    _publicALB = false;
    _appName = "";
    _accountName = "group1";  //group1 account or acc3 account (acc2)
    _dockerContext = "src";
    _appRegion = "ap-southeast-2";
    _automatedTestRepository = '';
    _automatedTestBranchName = '*/master';
    _automatedTestCredentialId = '';
    _automatedTestDockerfileName = 'Dockerfile';
    _automatedTestGitSSHCommand = 'ssh -v';  // ssh -v -i ~/.ssh/id_rsa_github for github repo 
    _project = 'group1'; //if group1 it deploys to group1 cluster, if group2 it deploys to group2 cluster
    _tfvarsFolder='tf';
    _albPrefix = "";
    // Run the init script, so derived jobs can set the variables.
    if(init != null)
    {
        init.resolveStrategy = Closure.DELEGATE_FIRST;
        init.delegate = this;
        init(this);
        _appName=_appName.toLowerCase();
    }
    if(_publicALB){
        _albprefix = "_pub"
    } else {
        _albprefix = ""
    }
    if (_accountName.toLowerCase() == "echo")
    {
        _accountName = "group1"
    }
    else if (_accountName.toLowerCase() == "acc2")
    {
        _accountName = "acc3"
    }
    // Execute the pipeline
    pipeline {
        agent {
            node {
                label 'group1-linux-slave'
            }
        }
        triggers {
            pollSCM(env.BRANCH_NAME == 'master' ? '' : '*/5 * * * *')
        }
        environment {
            AWS_REGION="${_appRegion}"
            DOCKER_PUSH_REPO='nexus.artifacts.com.au:9082'
            DOCKER_TAG='1.0'
            DOCKER_IMAGE="echo/${_appName}-${BRANCH_NAME}-${_appRegion}"
        }
        stages {
            stage('Clean') {
                steps {
                    sh """
                        docker run \
                            -v "${WORKSPACE}":/workspace \
                            -w //workspace \
                            bashell/alpine-bash /bin/bash -c "rm -rf /workspace/*";
                    """
                    checkout scm
                }
            }
            stage('Prebuild Checks') {
                steps {
                    script{
                        PrebuildUtils.check(this);
                    }
                }
            }
            stage('Pull library resources') {
                steps {
                    writeFile(file: "${_tfvarsFolder}/backend.tf", text: libraryResource("tf-templates/backend.tf"))
                    writeFile(file: "${_tfvarsFolder}/ecs_task.tf", text: libraryResource("tf-templates/ecs_task.tf"))
                    writeFile(file: "${_tfvarsFolder}/iam_roles.tf", text: libraryResource("tf-templates/iam_roles.tf"))
                    writeFile(file: "${_tfvarsFolder}/variables.tf", text: libraryResource("tf-templates/variables.tf"))

                    script {
                        milestone 1
                        // For web api projects, bring in the service file with load balancer,
                        // and the load balancer.
                        if (_useLoadBalancer)
                        {
                            writeFile(file: "${_tfvarsFolder}/load_balancer.tf", text: libraryResource("tf-templates/load_balancer${_albprefix}.tf"))
                            writeFile(file: "${_tfvarsFolder}/route53.tf", text: libraryResource("tf-templates/route53${_albprefix}.tf"))
                            writeFile(file: "${_tfvarsFolder}/ecs_service_lb.tf", text: libraryResource("tf-templates/ecs_service_lb.tf"))

                            if(_useHttps && _useHttp)
                            {
                                writeFile(file: "${_tfvarsFolder}/load_balancer_listener_https.tf", text: libraryResource("tf-templates/load_balancer_listener_https${_albprefix}.tf"))
                                writeFile(file: "${_tfvarsFolder}/load_balancer_listener_http.tf", text: libraryResource("tf-templates/load_balancer_listener_http${_albprefix}.tf"))

                            }
                            else if(_useHttp)
                            {
                                writeFile(file: "${_tfvarsFolder}/load_balancer_listener_http.tf", text: libraryResource("tf-templates/load_balancer_listener_http${_albprefix}.tf"))
                            }
                            else if(_useHttps)
                            {
                                writeFile(file: "${_tfvarsFolder}/load_balancer_listener_https.tf", text: libraryResource("tf-templates/load_balancer_listener_https${_albprefix}.tf"))
                                
                            }
                        }
                        else
                        {
                            writeFile(file: "${_tfvarsFolder}/ecs_service_no_lb.tf", text: libraryResource("tf-templates/ecs_service_no_lb.tf"))
                        }
                    }
                }
            }
            stage('Prepare') {
                steps {
                    script {
                        TerraformUtilsV12.prepare(this);
                        CredentialUtils.assumeRole(this, 'stg');
                        
                    }
                }
            }
            stage('Build') {
                steps {
                    sh """
                        cd ${WORKSPACE}
                        docker build -t $DOCKER_IMAGE:$DOCKER_TAG.$BUILD_NUMBER --build-arg VUE_BUILD_MODE=${PrebuildUtils.getEnvironmentName(this)} -f Dockerfile ${_dockerContext};
                        docker tag "$DOCKER_IMAGE:$DOCKER_TAG.$BUILD_NUMBER" "$DOCKER_PUSH_REPO/$DOCKER_IMAGE:$DOCKER_TAG.$BUILD_NUMBER"
                        docker push "$DOCKER_PUSH_REPO/$DOCKER_IMAGE:$DOCKER_TAG.$BUILD_NUMBER"
                    """
                }
            }
            stage('Mental Check') {
			    // when {
                //     branch 'master'
                // }
                steps {
                    script {
						Calendar cal = Calendar.getInstance();
						int day = cal.get(Calendar.DAY_OF_WEEK);
						if (day == Calendar.FRIDAY){
                            echo "You shouldnt deploy too many things on Friday.."
                            NotificationsUtils.Send(this,'IS_FRIDAY',' :alert: Hold your horses cowboy! :alert:')
						}
                    }
                }
            }
            stage('Promote STAGING') {
                when {
                    branch 'staging';
                }
                steps {
                    script{
                      TerraformUtilsV12.promoteTF(this,'stg')
                      addBadge(icon: 'green.gif', text:'Promoted to STG')
                      NotificationsUtils.Send(this,'PROMOTE','STG')
                    }
                }
            }
            stage('Promote UAT') {
                when {
                    branch 'uat';
                }
                steps {
                    script {
                        TerraformUtilsV12.promoteTF(this,'uat')
                        addBadge(icon: 'green.gif', text:'Promoted to UAT')
                        NotificationsUtils.Send(this,'PROMOTE','UAT')
                    }
                }
            }
            stage('Promote PROD') {
                when {
                    branch 'master'
                }
                steps {
                    script {
                        timeout(time: 300, unit: 'SECONDS') {
                            def userInput = input(id: 'Param1', message: 'Do you want to promote to production?', parameters:  [[$class: 'ChoiceParameterDefinition', choices: 'Deploy to Production? \nYes\nNo', name: 'choice']])
                            if(userInput == 'Yes') {
                                CredentialUtils.assumeRole(this, 'prod');
                                TerraformUtilsV12.promoteTF(this,'prod')
                                addBadge(icon: 'green.gif', text:'Promoted to PROD')
                                NotificationsUtils.Send(this,'PROMOTE','PROD')

                            }
                            else
                            {
                                echo "Promotion to PROD was aborted."
                            }
                        }
                    }
                }
            }
            stage('Verify') {
                steps {
                    script {
                        // Wait for the ECS service to
                        // become stable so we can start the test.
                         sh """
                               aws ecs wait services-stable \
                              --services ${env.STAGE}-xyz-${_project}-${_appName}-service \
                              --cluster ${TerraformUtilsV12.getEcsCluster(_accountName, _project, _appRegion, env.STAGE)} \
                              --region ${_appRegion}
                        """
                        NotificationsUtils.Send(this,'VERIFY',env.STAGE)
                    }
                }
            }
            stage('Automated Tests') {
                when {
                    allOf {
                        not { equals expected: '', actual: _automatedTestRepository }
                        // Notes.
                        // Don't run automated test on prod.
                        //  Automated tests on prod run as a seperated job (report to pager duty)
                        anyOf {
                            branch 'uat'
                            branch 'staging'
                        }
                        
                    }
                }
                steps {
                    script {
                        IntegrationTests.execute(this);   
                    }
                }
            } 
        }
        post {
            always {
                script {
                    NotificationsUtils.Send(this,currentBuild.result,env.STAGE)
                }
            }
        }
    }
}