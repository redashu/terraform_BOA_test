pipeline {
    agent any

    triggers {
        githubPush()
    }

    stages {

        /* ------------------------------------------------------
           1) Checkout Code
        ------------------------------------------------------- */
        stage('Checkout') {
            steps {
                checkout scm
                sh 'ls -al'
            }
        }

        /* ------------------------------------------------------
           2) Detect Branch Name (Fix for classic pipeline jobs)
        ------------------------------------------------------- */
        stage('Detect Branch Name') {
            steps {
                script {
                    // If BRANCH_NAME is empty, fallback using GIT_BRANCH
                    if (!env.BRANCH_NAME || env.BRANCH_NAME == "null" || env.BRANCH_NAME.trim() == "") {
                        env.BRANCH_NAME = env.GIT_BRANCH.replace("origin/", "")
                    }
                    echo "Detected branch: ${env.BRANCH_NAME}"
                }
            }
        }

        /* ------------------------------------------------------
           3) Terraform Workspace = Branch Name
        ------------------------------------------------------- */
        stage('Select Terraform Workspace') {
            steps {
                script {
                    env.TF_WS = env.BRANCH_NAME
                    echo "Using Terraform workspace: ${TF_WS}"

                    sh """
                        terraform workspace new ${TF_WS} 2>/dev/null || terraform workspace select ${TF_WS}
                    """
                }
            }
        }

        /* ------------------------------------------------------
           4) Terraform Init
        ------------------------------------------------------- */
        stage('Terraform Init') {
            steps {
                sh "terraform init"
            }
        }

        /* ------------------------------------------------------
           5) Pick Correct tfvars Based on Branch
        ------------------------------------------------------- */
        stage('Select tfvars file') {
            steps {
                script {
                    switch (env.BRANCH_NAME) {
                        case "dev":
                            env.TFVARS = "dev.tfvars"
                            break
                        case "stage":
                            env.TFVARS = "stage.tfvars"
                            break
                        case "master":
                            env.TFVARS = "prod.tfvars"
                            break
                        default:
                            error("No tfvars defined for branch: ${env.BRANCH_NAME}")
                    }

                    echo "Using tfvars file: ${env.TFVARS}"
                }
            }
        }

        /* ------------------------------------------------------
           6) Terraform Plan (always runs)
        ------------------------------------------------------- */
        stage('Terraform Plan') {
            steps {
                sh """
                    terraform plan -var-file=${TFVARS} -out=tfplan
                """
            }
        }

        /* ------------------------------------------------------
           7) Manual Approval Before Apply
              (Apply should ALWAYS require approval)
        ------------------------------------------------------- */
        stage('Manual Approval Before Apply') {
            steps {
                script {
                    timeout(time: 20, unit: 'MINUTES') {
                        input message: "Approve Terraform APPLY for workspace '${TF_WS}' using ${TFVARS}?"
                    }
                }
            }
        }

        /* ------------------------------------------------------
           8) Terraform Apply
        ------------------------------------------------------- */
        stage('Terraform Apply') {
            steps {
                sh """
                    terraform apply -var-file=${TFVARS} -auto-approve tfplan
                """
            }
        }
    }

    /* ----------------------------------------------------------
       Cleanup
    ----------------------------------------------------------- */
    post {
        always {
            echo "Cleaning workspace..."
            cleanWs()
        }
    }
}
