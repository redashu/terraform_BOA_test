pipeline {
    agent any

    triggers {
        githubPush()
    }

    stages {

        /* ------------------------------------------------------
           1) Checkout code
        ------------------------------------------------------- */
        stage('Checkout') {
            steps {
                checkout scm
                echo "Branch: ${env.BRANCH_NAME}"
                sh 'ls -al'
            }
        }

        /* ------------------------------------------------------
           2) Select/Create Terraform Workspace based on branch
        ------------------------------------------------------- */
        stage('Select Terraform Workspace') {
            steps {
                script {
                    env.TF_WS = env.BRANCH_NAME   // workspace = branch name
                    sh """
                        terraform workspace new ${TF_WS} 2>/dev/null || terraform workspace select ${TF_WS}
                    """
                }
            }
        }

        /* ------------------------------------------------------
           3) Terraform Init
        ------------------------------------------------------- */
        stage('Terraform Init') {
            steps {
                sh "terraform init"
            }
        }

        /* ------------------------------------------------------
           4) Select tfvars file based on branch
        ------------------------------------------------------- */
        stage('Select tfvars file') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        env.TFVARS = "dev.tfvars"
                    } else if (env.BRANCH_NAME == 'stage') {
                        env.TFVARS = "stage.tfvars"
                    } else if (env.BRANCH_NAME == 'main') {
                        env.TFVARS = "prod.tfvars"
                    } else {
                        error("No tfvars file defined for branch: ${env.BRANCH_NAME}")
                    }

                    echo "Using tfvars file: ${env.TFVARS}"
                }
            }
        }

        /* ------------------------------------------------------
           5) Terraform Plan (always runs)
        ------------------------------------------------------- */
        stage('Terraform Plan') {
            steps {
                sh """
                    terraform plan -var-file=${TFVARS} -out=tfplan
                """
            }
        }

        /* ------------------------------------------------------
           6) Manual Approval (required before apply, for ALL envs)
        ------------------------------------------------------- */
        stage('Manual Approval Before Apply') {
            steps {
                script {
                    timeout(time: 20, unit: 'MINUTES') {
                        input message: "Approve Terraform APPLY for workspace: ${env.TF_WS} using ${env.TFVARS} ?"
                    }
                }
            }
        }

        /* ------------------------------------------------------
           7) Terraform Apply (after approval)
        ------------------------------------------------------- */
        stage('Terraform Apply') {
            steps {
                sh """
                    terraform apply -var-file=${TFVARS} -auto-approve tfplan
                """
            }
        }
    }

    post {
        always {
            echo "Cleaning workspace..."
            cleanWs()
        }
    }
}
