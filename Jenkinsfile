pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Deploy to S3') {
            environment {
                AWS_S3_BUCKET = 'learn-jenkins-202408112001'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws-php', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        aws s3 sync . s3://$AWS_S3_BUCKET --exclude ".git/*"
                    '''
                }
            }
        }
    }
}
