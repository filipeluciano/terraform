#!groovy

node {

  env.TERRAFORM_CMD = "docker run -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY --rm --network host -w /app -v ${WORKSPACE}/${env.ENVIRONMENT}:/app hashicorp/terraform:light"

  withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Deploy Credentials']]) {

  stage ('Checkout') {
    checkout scm
  }

    if (env.STATE == 'REBUILD') {

      stage ('Create a snapshot of the source RDS instance') {
        ansiColor('xterm') {
          sh "aws rds create-db-snapshot --db-snapshot-identifier ${env.SERVICE}-jenkins-rebuild-pipeline-unencrypted --db-instance-identifier ${env.SERVICE} --region ap-southeast-2"
        }
      }

      stage ('Wait for the snapshot to complete') {
        ansiColor('xterm') {
          sh "aws rds wait db-snapshot-completed --db-snapshot-identifier ${env.SERVICE}-jenkins-rebuild-pipeline-unencrypted --db-instance-identifier ${env.SERVICE} --region ap-southeast-2"
        }
      }

      stage ('Create an encrypted copy of the above snapshot') {
        ansiColor('xterm') {
          sh "aws rds copy-db-snapshot --source-db-snapshot-identifier ${env.SERVICE}-jenkins-rebuild-pipeline-unencrypted --target-db-snapshot-identifier ${env.SERVICE}-jenkins-rebuild-pipeline-encrypted --kms-key-id alias/aws/rds --copy-tags --region ap-southeast-2"
        }
      }

      stage ('Wait for the encrypted copy to complete') {
        ansiColor('xterm') {
          sh "aws rds wait db-snapshot-completed --db-snapshot-identifier ${env.SERVICE}-jenkins-rebuild-pipeline-encrypted --db-instance-identifier ${env.SERVICE} --region ap-southeast-2"
        }
      }

      stage ("Rename ${env.SERVICE} RDS instance to ${env.SERVICE}-old-to-be-removed") {
        ansiColor('xterm') {
          sh "aws rds modify-db-instance --db-instance-identifier ${env.SERVICE} --new-db-instance-identifier ${env.SERVICE}-old-to-be-removed --apply-immediately --region ap-southeast-2"
        }
      }

      stage ("Wait for ${env.SERVICE} RDS instance to be renamed to ${env.SERVICE}-old-to-be-removed") {
        ansiColor('xterm') {
          // sh "aws rds wait db-instance-available --db-instance-identifier ${env.SERVICE}-old-to-be-removed --region ap-southeast-2"
          echo "Sleep for 90 seconds to allow the rds instance name to change before running terraform"
          sleep 90
        }
      }

      stage ('Decrypt rds_password') {
        ansiColor('xterm') {
          sh "ansible-vault decrypt secrets/${env.SERVICE}_secret.tfvars.vault --vault-password-file ~/vault_pass.txt --output ${env.SERVICE}_secrets.tfvars"
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
          sh "${TERRAFORM_CMD} plan -out=create.tfplan -var-file=tfvars/${env.SERVICE}.tfvars -var-file=${env.SERVICE}_secrets.tfvars -var 'snapshot_identifier=${env.SERVICE}-jenkins-rebuild-pipeline-encrypted'"
        }
      }

      stage ("Terraform show current workspace") {
        ansiColor('xterm') {
          sh "${TERRAFORM_CMD} workspace list"
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

      // Disabled, could take up to 24 hours
      //
      // stage ('Wait for RDS instance to become available') {
      //   ansiColor('xterm') {
      //     sh "aws rds wait db-instance-available --db-instance-identifier ${env.SERVICE} --region ap-southeast-2"
      //   }
      // }

      // stage ('Reboot RDS instance to apply parameter group') {
      //   ansiColor('xterm') {
      //     sh "aws rds reboot-db-instance --db-instance-identifier ${env.SERVICE} --region ap-southeast-2"
      //   }
      // }

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

      // Disabled, could take up to 24 hours
      //
      // stage ('Wait for RDS instance to become available') {
      //   ansiColor('xterm') {
      //     sh "aws rds wait db-instance-available --db-instance-identifier ${env.SERVICE} --region ap-southeast-2"
      //   }
      // }

      // stage ('Reboot RDS instance to apply parameter group') {
      //   ansiColor('xterm') {
      //     sh "aws rds reboot-db-instance --db-instance-identifier ${env.SERVICE} --region ap-southeast-2"
      //   }
      // }
    }

    // if (env.STATE == 'DESTROY') {

    //   stage ('pull latest light terraform image') {
    //     ansiColor('xterm') {
    //       sh 'docker pull hashicorp/terraform:light'
    //     }
    //   }

    //   stage ('Terraform init') {
    //     ansiColor('xterm') {
    //       sh '${TERRAFORM_CMD} init'
    //     }
    //   }

    //   stage ("Terraform switch workspace to ${env.ENVIRONMENT}") {
    //     ansiColor('xterm') {
    //       sh "${TERRAFORM_CMD} workspace select ${env.ENVIRONMENT}"
    //     }
    //   }

    //   stage ('Terraform destroy out') {
    //     ansiColor('xterm') {
    //       sh "${TERRAFORM_CMD} plan -destroy -out=destroy.tfplan -var-file=tfvars/${env.SERVICE}.tfvars -var 'rds_password=placeholder_for_destroy' -var 'snapshot_identifier=placeholder_for_destroy'"
    //     }
    //   }

    //   // Optional wait for approval
    //   input 'Destroy stack?'

    //   stage ('Terraform Apply') {
    //     ansiColor('xterm') {
    //       sh '${TERRAFORM_CMD} apply destroy.tfplan'
    //     }
    //   }
    // }

  cleanWs()

  }
}