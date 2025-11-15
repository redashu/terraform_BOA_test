pipeline {
    agent any
    triggers {
        githubPush()
    }

    stages {

        stage('Hello') {
            steps {
                echo 'Hello World'
                sh 'ls -a'
            }
        }

        stage('branch test') {
            when { branch 'dev' }
            steps {
                echo "hello world new"
                sh 'ls -a'
            }
        }

        stage('terraform plan') {
            when {
                expression { env.BRANCH_NAME == 'dev' || env.GIT_BRANCH == 'origin/dev' }
            }
            steps {
                echo "Running Terraform PLAN on dev"
                sh 'terraform init'
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('manual approval before apply') {
            when {
                expression { env.BRANCH_NAME == 'dev' || env.GIT_BRANCH == 'origin/dev' }
            }
            steps {
                script {
                    timeout(time: 10, unit: 'MINUTES') {
                        input message: "Approve Terraform APPLY for DEV environment?"
                    }
                }
            }
        }

        stage('terraform apply') {
            when {
                expression { env.BRANCH_NAME == 'dev' || env.GIT_BRANCH == 'origin/dev' }
            }
            steps {
                echo "Applying Terraform changes on dev"
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}
