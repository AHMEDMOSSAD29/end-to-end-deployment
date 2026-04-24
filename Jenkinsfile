pipeline {
    agent any
    
    environment {
        // Docker Hub repository details
        DOCKERHUB_REPO = 'ahmedmosaad594/ahmed-mosaad-resume' 
        // Credential IDs stored in Jenkins Global Credentials
        DOCKERHUB_CRED_ID = 'dockerhub-credentials'
        GIT_CREDENTIALS_ID = 'github-token'
        // Dynamic image tag based on Jenkins build number
        IMAGE_TAG = "v1.${BUILD_NUMBER}"
    }

    stages {
        stage('Security Scan') {
            steps {
                script {
                    echo "Starting Security Scan with Semgrep..."
                    // Pull the image manually to ensure the latest version is available
                    sh 'docker pull returntocorp/semgrep:latest'
                    
                    // Explicitly mount the Jenkins workspace to /src inside the container.
                    // This fixes the 'StopIteration' and volume mapping errors.
                    sh 'docker run --rm -v ${WORKSPACE}:/src returntocorp/semgrep semgrep scan --config auto --error'
                }
            }
        }

        stage('Build and Push to Docker Hub') {
            steps {
                script {
                    echo "Building Docker Image: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
                    
                    withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CRED_ID}", 
                                     passwordVariable: 'DOCKERHUB_PASSWORD', 
                                     usernameVariable: 'DOCKERHUB_USERNAME')]) {
                        
                        // Login to Docker Hub
                        sh "echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin"
                        
                        // Build image with both versioned and 'latest' tags
                        sh "docker build -t ${DOCKERHUB_REPO}:latest -t ${DOCKERHUB_REPO}:${IMAGE_TAG} ."
                        
                        // Push both tags to Docker Hub
                        sh "docker push ${DOCKERHUB_REPO}:latest"
                        sh "docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Update Kubernetes Manifest') {
            steps {
                script {
                    echo "Updating Kubernetes Manifest with new image tag..."
                    // Update the image field in the deployment manifest
                    sh "sed -i 's|image:.*|image: ${DOCKERHUB_REPO}:${IMAGE_TAG}|g' k8s/dev/deployment.yaml"
                    
                    // Push the manifest change back to GitHub to trigger GitOps (ArgoCD)
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
            echo "Cleaning up workspace..."
            // Remove local images to save disk space on the Jenkins server
            sh "docker rmi ${DOCKERHUB_REPO}:latest ${DOCKERHUB_REPO}:${IMAGE_TAG} || true"
            // Ensure we logout of Docker Hub
            sh "docker logout"
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check console logs for details."
        }
    }
}
