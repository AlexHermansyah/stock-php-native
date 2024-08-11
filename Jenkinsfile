pipeline {
    agent any

    stages {

        stage('Build') {
            steps {
                sh '''
                    ls -la
                    php --version
                    # Tidak ada build steps karena ini adalah proyek PHP native sederhana
                '''
            }
        }

        stage('Tests') {
            parallel {
                stage('Syntax Check') {
                    steps {
                        sh '''
                            # Mengecek semua file PHP untuk memastikan tidak ada syntax error
                            find . -name "*.php" -exec php -l {} \\;
                        '''
                    }
                }
            }
        }

        stage('AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    reuseNode true
                    args "--entrypoint=''"
                }
            }
            environment {
                AWS_S3_BUCKET = 'php-bucket-202408112001'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        aws s3 sync . s3://$AWS_S3_BUCKET --exclude ".git/*" --exclude "*.sql"
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    echo "Deploying application"
                    # Langkah-langkah untuk deploy aplikasi PHP native dapat ditambahkan di sini
                '''
            }
        }
    }
}
