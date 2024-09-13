pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        GIT_REPO_URL = 'https://github.com/mhadv/Develpoer.git'
        APPLICATION_NAME = 'NewApplicationCodeDeploy'
        DEPLOYMENT_GROUP_NAME = 'Deployment-group'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Clone the repository
                    checkout([$class: 'GitSCM',
                        branches: [[name: '*/main']],
                        userRemoteConfigs: [[url: "${GIT_REPO_URL}"]],
                        credentialsId: 'github-credentials-id'
                    ])
                }
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Deploy') {
            steps {
                script {
                    def commitId = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
                    withCredentials([aws(credentialsId: 'aws-credentials-id', region: "${AWS_REGION}")]) {
                        // Create a deployment using AWS CLI
                        sh """
                            aws deploy create-deployment \
                                --application-name ${APPLICATION_NAME} \
                                --deployment-group-name ${DEPLOYMENT_GROUP_NAME} \
                                --revision revisionType=GitHub,gitHubLocation={repository=PrashantShukla001/CodeDeployRepo,commitId=${commitId}} \
                                --region ${AWS_REGION}
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        failure {
            echo 'Build failed'
        }
        success {
            echo 'Build succeeded'
        }
    }
}

