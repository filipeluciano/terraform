pipeline {
    agent any

    env.TERRAFORM_CMD = "docker run -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY --rm --network host -w /app -v .:/app hashicorp/terraform:light"

    stages {
        stage('Checkout'') {
            steps {
                checkout scm
            }
        }
    }
}