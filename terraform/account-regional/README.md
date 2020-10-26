
Steps to put terraform:light docker image into local ECR Repo

aws ecr get-login --region "ap-southeast-2" --no-include-email --registry-ids "111111111111"
aws ecr create-repository --region "ap-southeast-2" --profile "dev-privprot" --repository-name "terraform:light"
docker tag "terraform:light" "111111111111.dkr.ecr.ap-southeast-2.amazonaws.com/terraform:light"
docker push "111111111111.dkr.ecr.ap-southeast-2.amazonaws.com/terraform:light"
