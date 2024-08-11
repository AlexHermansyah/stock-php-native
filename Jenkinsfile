pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '4cc8e3f6-6dc6-4eb8-b483-e6d1252210a0'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token-php')
        BUILD_VERSION = "1.0.$BUILD_ID"
    }

    stages {

        stage('Build') {
            agent {
                docker {
                    image 'php:8.1-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    php --version
                    composer --version
                    composer install --no-interaction --prefer-dist
                    ls -la
                '''
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
                        aws s3 sync . s3://$AWS_S3_BUCKET --exclude ".git/*" --exclude "vendor/*" --exclude "node_modules/*"
                    '''
                }
            }
        }

        stage('Tests') {
            parallel {
                stage('Unit tests') {
                    agent {
                        docker {
                            image 'php:8.1-alpine'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            php vendor/bin/phpunit --configuration phpunit.xml
                        '''
                    }
                    post {
                        always {
                            junit 'tests/_output/junit.xml'
                        }
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'php:8.1-alpine'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            # Configure E2E testing environment
                            # Run E2E tests (assuming you have a setup for it)
                        '''
                    }

                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'e2e-reports', reportFiles: 'index.html', reportName: 'Local E2E', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }

        stage('Deploy staging') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = 'STAGING_URL_TO_BE_SET'
            }

            steps {
                sh '''
                    composer global require netlify-cli
                    ~/.composer/vendor/bin/netlify --version
                    echo "Deploying to staging. Site ID: $NETLIFY_SITE_ID"
                    ~/.composer/vendor/bin/netlify status
                    ~/.composer/vendor/bin/netlify deploy --dir=. --json > deploy-output.json
                    CI_ENVIRONMENT_URL=$(~/.composer/vendor/bin/netlify deploy --dir=. --json | jq -r '.deploy_url')
                '''
            }

            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'e2e-reports', reportFiles: 'index.html', reportName: 'Staging E2E', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }

        stage('Deploy prod') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = 'https://chipper-marigold-9d956f.netlify.app'
            }

            steps {
                sh '''
                    composer global require netlify-cli
                    ~/.composer/vendor/bin/netlify --version
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    ~/.composer/vendor/bin/netlify status
                    ~/.composer/vendor/bin/netlify deploy --dir=. --prod
                '''
            }

            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'e2e-reports', reportFiles: 'index.html', reportName: 'Prod E2E', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }
    }
}
