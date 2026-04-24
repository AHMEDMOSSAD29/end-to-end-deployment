pipeline {
    agent any
    
    environment {
        // Replace with your Docker Hub details
        DOCKERHUB_REPO = 'ahmedmosaad594/ahmed-mosaad-resume' 
        DOCKERHUB_CRED_ID = 'dockerhub-credentials' // The ID of credentials stored in Jenkins
        GIT_CREDENTIALS_ID = 'github-token'
        IMAGE_TAG = "v1.${BUILD_NUMBER}"
    }

    stages {
        stage('Security Scan') {
            steps {
              
                script {
                    docker.image('returntocorp/semgrep').inside {
                        sh 'semgrep scan --config auto --error'
                    }
                }
            }
        }

        stage('Build and Push to Docker Hub') {
            steps {
                script {
                    // Login to Docker Hub using Jenkins credentials
                    withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CRED_ID}", 
                                     passwordVariable: 'DOCKERHUB_PASSWORD', 
                                     usernameVariable: 'DOCKERHUB_USERNAME')]) {
                        
                        sh "echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin"
                        
                        // Building and tagging as 'latest' and versioned tag
                        sh "docker build -t ${DOCKERHUB_REPO}:latest -t ${DOCKERHUB_REPO}:${IMAGE_TAG} ."
                        
                        sh "docker push ${DOCKERHUB_REPO}:latest"
                        sh "docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Update Kubernetes Manifest') {
            steps {
                script {
                    // Update the image path in the dev deployment manifest
                    sh "sed -i 's|image:.*|image: ${DOCKERHUB_REPO}:${IMAGE_TAG}|g' k8s/dev/deployment.yaml"
                    
                    withCredentials([usernamePassword(credentialsId: "${GIT_CREDENTIALS_ID}", 
                                     passwordVariable: 'GIT_PASSWORD', 
                                     usernameVariable: 'GIT_USERNAME')]) {
                        sh """
                            git config user.name "jenkins-bot"
                            git config user.email "jenkins@example.com"
                            git add k8s/dev/deployment.yaml
                            git commit -m "Update image to ${IMAGE_TAG} (Docker Hub) [skip ci]"
                            git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/ahmedmossad29/end-to-end-deployment.git HEAD:main
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Cleanup local images to save disk space
            sh "docker rmi ${DOCKERHUB_REPO}:latest ${DOCKERHUB_REPO}:${IMAGE_TAG} || true"
            sh "docker logout"
        }
    }
}
