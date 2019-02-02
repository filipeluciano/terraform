#!groovy

node {

  env.TERRAFORM_CMD = "docker run -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY --rm --network host -w /app -v .:/app hashicorp/terraform:light"

  withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Deploy Credentials']]) {

  stage ('Checkout') {
    checkout scm
  }

  stage ('Terraform init') {
    ansiColor('xterm') {
    sh '${TERRAFORM_CMD} init'
  }


  stage ('Terraform Plan') {
    ansiColor('xterm') {
    sh "${TERRAFORM_CMD} plan -out=create.tfplan  -var-file=${env.ENVIRONMENT}_secrets.tfvars"
  }



  input 'Deploy stack?'

  input 'Are you sure?'

  stage ('Terraform Apply') {
    ansiColor('xterm') {
    sh '${TERRAFORM_CMD} apply create.tfplan'
  }

  cleanWs()


}