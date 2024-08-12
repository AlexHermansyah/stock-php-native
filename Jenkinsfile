pipeline {
    agent any
    environment {
        NETLIFY_SITE_ID = 'b3dc5ff7-ed0a-4f29-8d38-01f491fbf2d3'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }

    stages {

        stage('Build') {
            agent {
                docker {
                    image 'php:8.1-cli'
                    reuseNode true
                }
            }
            steps {
                sh '''
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
                     '''
                }
            }
        }

        stage('Tests') {
            parallel {
                stage('Unit tests') {
                    agent {
                        docker {
                            image 'php:8.1-cli'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            #test -f build/index.html
                        '''
                    }
                }
            }
        }

 
        stage('Deploy') {
            agent {
                docker {
                    image 'php:8.1-cli'
                    reuseNode true
                }
            }    
            steps {
                sh '''
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                '''
            }
        }

        // stage('Deploy prod') {
        //     agent {
        //         docker {
        //             image 'php:8.1-cli'
        //             reuseNode true
        //         }
        //     }

        //     environment {
        //         CI_ENVIRONMENT_URL = 'https://chipper-marigold-9d956f.netlify.app'
        //     }

        //     steps {
        //         sh '''
        //             netlify --version
        //             echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
        //             netlify status
        //             netlify deploy --dir=build --prod
        //         '''
        //     }

        //     post {
        //         always {
        //             publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.php', reportName: 'Prod E2E', reportTitles: '', useWrapperFileDirectly: true])
        //         }
        //     }
        // }
    }
}
