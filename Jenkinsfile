pipeline {
    agent any
    environment {
        IMAGE_NAME = 'custom-php-image'
        NETLIFY_SITE_ID = 'b3dc5ff7-ed0a-4f29-8d38-01f491fbf2d3'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }
    stages {
        stage('Build Image') {
            steps {
                script {
                    // Build the Docker image
                    sh '''
                        docker build -t $IMAGE_NAME:latest .
                    '''
                }
            }
        }
        stage('Build Application') {
            agent {
                docker {
                    image "${env.IMAGE_NAME}:latest"
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    php --version
                    composer install
                    ls -la
                '''
            }
        }
        stage('Run Tests') {
            parallel {
                stage('Unit Tests') {
                    agent {
                        docker {
                            image "${env.IMAGE_NAME}:latest"
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            php vendor/bin/phpunit --testsuite Unit
                        '''
                    }
                    post {
                        always {
                            junit 'tests/unit-results.xml'
                        }
                    }
                }
                stage('E2E Tests') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            php -S localhost:8000 -t public & 
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            junit 'tests/e2e-results.xml'
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }
        stage('Deploy') {
            agent {
                docker {
                    image "${env.IMAGE_NAME}:latest"
                    reuseNode true
                }
            }
            steps {
                sh '''
                    composer require netlify/netlify-php
                    vendor/bin/netlify --version
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    vendor/bin/netlify status
                    vendor/bin/netlify deploy --dir=public --prod
                '''
            }
        }
    }
}
