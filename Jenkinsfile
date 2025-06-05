pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-central-1'                  // Change to your AWS region
        ECR_REGISTRY = '767397888348.dkr.ecr.eu-central-1.amazonaws.com'  // Your AWS Account ECR URI
        ECR_REPO = 'webserver-iac'               // Your ECR repo name
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/YaseminKarakas/webserver-with-jenkins.git', branch: 'main'
            }
        }
  

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}")
                }
            }
        }

        stage('Login to ECR') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'eu-central-1') {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
                    '''
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    dockerImage.push()
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'eu-central-1') {
                    sh '''
                    aws ecs update-service \
                        --cluster ecs-cluster-webserver-iac \
                        --service webserver-ecs-service \
                        --force-new-deployment \
                        --region eu-central-1
                    '''
                }
            }
        }

    }
}
