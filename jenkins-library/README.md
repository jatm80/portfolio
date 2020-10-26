## To use this library:
*1) Create a Multibranch-pipeline to disovery for the following branches:  ^(master|develop|staging|qa|uat)$

*2) Create a Jenkinsfile in the root of your project and invoke the pipeline as follow: 

echo_multibranch {
    _appName = "test-api";
    _project = "acc3";
    _accountName = "acc3";
}; 

*acc3 project will deploy in Acc2 clusters (acc2-au / acc2-cluster)

*group1 and group2 projects will deploy to ecs cluster in Group1 (stg-xyz-group1-cluster and stg-xyz-group2-cluster)



