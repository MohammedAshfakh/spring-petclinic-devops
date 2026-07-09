pipeline {
    agent any

    tools {
        maven 'Maven-3.9'
    }

    environment {
        AWS_REGION = "us-east-1"
        ECR_URI = "799517508141.dkr.ecr.us-east-1.amazonaws.com/gitops-app"
        SONAR_HOST_URL = "http://34.230.8.62:9000"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

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
                    sh '''
                        mvn sonar:sonar \
                          -Dsonar.projectKey=petclinic \
                          -Dsonar.host.url=$SONAR_HOST_URL \
                          -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build -t petclinic:${IMAGE_TAG} .
                    docker tag petclinic:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}
                    docker tag petclinic:${IMAGE_TAG} ${ECR_URI}:latest
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds']
                ]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin \
                        799517508141.dkr.ecr.us-east-1.amazonaws.com

                        docker push ${ECR_URI}:${IMAGE_TAG}
                        docker push ${ECR_URI}:latest
                    '''
                }
            }
        }

        stage('Clone GitOps Repository') {
            steps {
                dir('petclinic-CD') {
                    git(
                        branch: 'main',
                        credentialsId: 'github-creds',
                        url: 'https://github.com/MohammedAshfakh/petclinic-CD.git'
                    )
                }
            }
        }

        stage('Update Helm values.yaml') {
            steps {
                dir('petclinic-CD') {
                    sh '''
                        sed -i "s/tag:.*/tag: ${IMAGE_TAG}/" helm/petclinic/values.yaml
                        cat helm/petclinic/values.yaml
                    '''
                }
            }
        }

        stage('Commit & Push GitOps Changes') {
            steps {
                dir('petclinic-CD') {

                    withCredentials([
                        gitUsernamePassword(
                            credentialsId: 'github-creds',
                            gitToolName: 'git'
                        )
                    ]) {

                        sh '''
                            git config user.email "mohammedashfakhshaik@gmail.com"
                            git config user.name "MohammedAshfakh"

                            git add .

                            git commit -m "Update image tag to ${IMAGE_TAG}" || true

                            git push origin HEAD:main
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build, Sonar, Docker, ECR Push & GitOps Update Successful"
        }

        failure {
            echo "❌ Pipeline Failed"
        }
    }
}
