#!groovy

node {

  env.TERRAFORM_CMD = "docker run -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY --rm --network host -w /app -v ${WORKSPACE}/${env.ENVIRONMENT}:/app hashicorp/terraform:light"

  withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Deploy Credentials']]) {

  stage ('Checkout') {
    checkout scm
  }

    if (env.STATE == 'BUILD') {

      stage ('Decrypt rds_password') {
        ansiColor('xterm') {
          sh "cd ${env.ENVIRONMENT}; ansible-vault decrypt ${env.ENVIRONMENT}_secret.tfvars.vault --vault-password-file ~/vault_pass.txt --output ${env.ENVIRONMENT}_secrets.tfvars"
        }
      }

      stage ('Pull latest light terraform image') {
        ansiColor('xterm') {
          sh 'docker pull hashicorp/terraform:light'
        }
      }

      stage ('Terraform init') {
        ansiColor('xterm') {
          sh '${TERRAFORM_CMD} init'
        }
      }

      stage ("Terraform switch workspace to ${env.ENVIRONMENT}") {
        ansiColor('xterm') {
          sh "${TERRAFORM_CMD} workspace select ${env.ENVIRONMENT}"
        }
      }

      stage ('Terraform Plan') {
        ansiColor('xterm') {
          sh "${TERRAFORM_CMD} plan -out=create.tfplan  -var-file=${env.ENVIRONMENT}_secrets.tfvars"
        }
      }

      // Optional wait for approval
      input 'Deploy stack?'

      stage ('Terraform Apply') {
        ansiColor('xterm') {
          sh '${TERRAFORM_CMD} apply create.tfplan'
        }
      }

      stage ('Post Run Tests') {
        ansiColor('xterm') {
          sh '${TERRAFORM_CMD} show'
        }
      }

  cleanWs()

  }
}