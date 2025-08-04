pipeline {
    agent any

    environment {
        // Cập nhật username Docker Hub của bạnnn
        DOCKERHUB_USERNAME = 'quangtb7'
        // ID của credential cho Docker Hub trong Jenkins
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-credentials'
        // ID của credential cho mật khẩu DB trong Jenkins
        DB_PASSWORD_CREDENTIALS_ID = 'mysql-root-password'
        APP_NAME = 'art-gallery-app'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Bắt đầu lấy mã nguồn từ GitHub...'
                checkout scm
            }
        }

        stage('Build Application') {
            steps {
                echo 'Bắt đầu build ứng dụng Spring Boot...'
                sh 'docker run -v $WORKSPACE:/app -w /app --rm maven:3.9.6-eclipse-temurin-21 mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Bắt đầu build Docker image...'
                sh "docker build -t ${DOCKERHUB_USERNAME}/${APP_NAME}:${env.BUILD_NUMBER} ."
                sh "docker tag ${DOCKERHUB_USERNAME}/${APP_NAME}:${env.BUILD_NUMBER} ${DOCKERHUB_USERNAME}/${APP_NAME}:latest"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Đẩy image lên Docker Hub...'
                withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                    sh "docker push ${DOCKERHUB_USERNAME}/${APP_NAME}:${env.BUILD_NUMBER}"
                    sh "docker push ${DOCKERHUB_USERNAME}/${APP_NAME}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Triển khai ứng dụng bằng Docker Compose...'
                // Lấy mật khẩu DB từ Jenkins Credentials và truyền vào docker-compose
                withCredentials([string(credentialsId: DB_PASSWORD_CREDENTIALS_ID, variable: 'DB_PASSWORD')]) {
                    sh 'docker-compose down || true'
                    // Biến DB_PASSWORD sẽ được docker-compose sử dụng
                    sh 'docker-compose up -d'
                }
            }
        }
    }

    post {
        always {
            echo 'Quy trình hoàn tất.'
            sh 'docker logout'
        }
    }
}