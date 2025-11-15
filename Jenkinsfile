pipeline {
    agent any
    triggers {
        githubPush()    // 🔥 Trigger Jenkins on every push to repo
    }

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
            }
        }
        stage('terraform test'){
            when { branch 'dev' }
            steps {
                echo "hello world new"
                git url: 'https://github.com/redashu/terraform_BOA_test.git', branch: 'master'
                sh 'ls -a'
            }
        }
    }
}

