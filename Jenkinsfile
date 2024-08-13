pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '4cc8e3f6-6dc6-4eb8-b483-e6d1252210a0'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token-php')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }

    stages {
stage('Build') {
    agent {
        docker {
            image 'php:latest'
            reuseNode true
        }
    }
    steps {
        sh '''
            # Contoh build
            mkdir -p build
            # Tambahkan perintah build yang sesuai
            echo "File index.html" > build/index.html
        '''
    }
}

        // stage('Build') {
        //     agent {
        //         docker {
        //             image 'php:latest'
        //             reuseNode true
        //         }
        //     }
        //     steps {
        //         sh '''
        //             # Periksa apakah file build/index.html ada
        //             ls -la
        //         '''
        //     }
        // }
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
        withCredentials([usernamePassword(credentialsId: 'my-aws-php', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
            sh '''
                ls -la build
                aws s3 sync build s3://$AWS_S3_BUCKET
            '''
        }
    }
}

        // stage('AWS') {
        //     agent {
        //         docker {
        //             image 'amazon/aws-cli'
        //             reuseNode true
        //             args "--entrypoint=''"
        //         }
        //     }
        //     environment {
        //         AWS_S3_BUCKET = 'learn-jenkins-202408112001'
        //     }
        //     steps {
        //         withCredentials([usernamePassword(credentialsId: 'my-aws-php', passwordVariable: 'AWS_SECRET_ACCESS_KEY_PHP', usernameVariable: 'AWS_ACCESS_KEY_ID_PHP')]) {
        //             sh '''
        //                 aws --version
        //                 aws s3 sync build s3://$AWS_S3_BUCKET
        //             '''
        //         }
        //     }
        // }

        stage('Tests') {
            parallel {
                stage('Unit tests') {
                    agent {
                        docker {
                            image 'php:latest'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            # Tes unit di sini, sesuaikan dengan kebutuhan Anda
                            # Contoh tes
                            # test -f build/index.html
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            workspace/App-php-native -s build &
                            sleep 10
                        '''
                    }

                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Local E2E', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }

        stage('Deploy staging') {
            agent {
                docker {
                    image 'php:8.0-cli'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = 'STAGING_URL_TO_BE_SET'
            }

            steps {
                sh '''
                    npm install netlify-cli node-jq
                    node_modules/.bin/netlify --version
                    echo "Deploying to staging. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --json > deploy-output.json
                    CI_ENVIRONMENT_URL=$(node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json)
                    npx playwright test  --reporter=html
                '''
            }

            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Staging E2E', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }

        stage('Deploy prod') {
            agent {
                docker {
                    image 'php:8.0-cli'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = 'chipper-marigold-9d956f.netlify.app'
            }

            steps {
                sh '''
                    node --version
                    npm install netlify-cli
                    node_modules/.bin/netlify --version
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --prod
                    npx playwright test --reporter=html
                '''
            }

            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Prod E2E', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }
    }
}
