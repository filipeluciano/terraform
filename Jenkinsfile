#!groovy

node {

  env.TERRAFORM_CMD = "docker run -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY --rm --network host -w /app -v ${WORKSPACE}:/app hashicorp/terraform:light"
  env.STATE = 'BUILD'

  withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'filipe-recursiva']]) {

  stage ('Checkout') {
    checkout scm
  }

    if (env.STATE == 'BUILD') {

      stage ('Pull latest light terraform image') {

          sh 'docker pull hashicorp/terraform:light'

      }

      stage ('Terraform init') {

          sh '${TERRAFORM_CMD} init'

      }

      stage ('Terraform Plan') {

          sh "${TERRAFORM_CMD} plan -out=create.tfplan"

      }

      // Optional wait for approval
      input 'Deploy stack?'

      stage ('Terraform Apply') {

          sh '${TERRAFORM_CMD} apply create.tfplan'

      }

      stage ('Post Run Tests') {

          sh '${TERRAFORM_CMD} show'

      }

  cleanWs()

  }
}
}