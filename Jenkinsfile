pipeline {
    agent any
    tools {
        maven 'Maven-3.9'
    }
    environment {
        AWS_REGION = "us-east-1"
        ECR_URI = "799517508141.dkr.ecr.us-east-1.amazonaws.com/petclinic"
        SONAR_HOST_URL = "http://54.167.64.99:9000"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                
                withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                    sh """
                    mvn sonar:sonar \
                        -Dsonar.projectKey=employee-api \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_TOKEN
                    """
                }
                
            }
        }
        stage('Quality Gate') {
          steps {
            timeout(time: 2, unit: 'MINUTES') {
              waitForQualityGate abortPipeline: true
            }
          }
        }

        stage('Docker Build') {
            steps {
                sh """
                docker build -t employee-api:${IMAGE_TAG} .
                docker tag employee-api:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}
                docker tag employee-api:${IMAGE_TAG} ${ECR_URI}:latest
                """
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh """
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY

                    aws ecr get-login-password --region $AWS_REGION \
                    | docker login --username AWS --password-stdin 799517508141.dkr.ecr.us-east-1.amazonaws.com

                    docker push ${ECR_URI}:${IMAGE_TAG}
                    docker push ${ECR_URI}:latest
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build, Test, Sonar, Docker, Push SUCCESS"
        }

        failure {
            echo "❌ Pipeline Failed"
        }
    }
}
