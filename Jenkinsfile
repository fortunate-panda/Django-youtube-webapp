pipeline {
    agent any

    // Define global variables for your pipeline
    environment {
        // Replace with your actual Docker Hub or AWS ECR repository name
        DOCKER_IMAGE = 'rolandobiora/pytube'
        
        // This ID must match the credentials ID you configure in Jenkins
        DOCKER_CREDS_ID = 'dockerhub-credentials'
        
        // Tag the image with the Jenkins build number for version control
        IMAGE_TAG = "v${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                // Pulls the latest code from your Git repository
                checkout scm
                echo 'Source code checked out successfully.'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building the hardened PyTube Docker image: ${DOCKER_IMAGE}:${IMAGE_TAG}..."
                // Builds the image using your Dockerfile and tags it twice (with the version and as 'latest')
                sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} -t ${DOCKER_IMAGE}:latest ."
            }
        }

        stage('DevSecOps: Image Vulnerability Scan') {
            steps {
                echo 'Scanning the newly built container for security vulnerabilities...'
                // Using Trivy (a popular open-source security scanner) to check the image.
                // It will fail the build if CRITICAL vulnerabilities are found.
                // Note: Trivy must be installed on your Jenkins server for this to work.
                sh "trivy image --exit-code 1 --severity CRITICAL ${DOCKER_IMAGE}:${IMAGE_TAG}"
            }
        }

        stage('Push to Container Registry') {
            steps {
                echo 'Pushing the secure image to the Docker registry...'
                // Securely injects your Docker credentials without exposing them in the logs
                withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}:${IMAGE_TAG}"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }
    }

    // The post section runs after all stages complete, regardless of success or failure
    post {
        always {
            echo 'Cleaning up the Jenkins workspace and local Docker images to free up server space...'
            // Remove the locally built images to prevent the Jenkins server from running out of disk space
            sh "docker rmi ${DOCKER_IMAGE}:${IMAGE_TAG} || true"
            sh "docker rmi ${DOCKER_IMAGE}:latest || true"
            // Clean the workspace files
            cleanWs()
        }
        success {
            echo "✅ Pipeline completed successfully! Image ${IMAGE_TAG} is ready for deployment."
        }
        failure {
            echo "❌ Pipeline failed. Please check the stage logs to investigate the issue."
        }
    }
}