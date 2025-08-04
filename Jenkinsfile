pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = 'quangtb7'
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-credentials'
        DB_PASSWORD_CREDENTIALS_ID = 'mysql-root-password'
        APP_NAME = 'art-gallery-app'
        // *** THAY ĐỔI QUAN TRỌNG: Thêm thư mục bin của Docker vào biến PATH ***
        PATH = "C:\\Program Files\\Docker\\Docker\\resources\\bin;${env.PATH}"
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
                bat 'mvnw.cmd clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Bắt đầu build Docker image...'
                // Giờ đây có thể gọi lệnh trực tiếp
                bat "docker build -t ${DOCKERHUB_USERNAME}/${APP_NAME}:${env.BUILD_NUMBER} ."
                bat "docker tag ${DOCKERHUB_USERNAME}/${APP_NAME}:${env.BUILD_NUMBER} ${DOCKERHUB_USERNAME}/${APP_NAME}:latest"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Đẩy image lên Docker Hub...'
                withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat "docker logout"
                    bat "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                    bat "docker push ${DOCKERHUB_USERNAME}/${APP_NAME}:${env.BUILD_NUMBER}"
                    bat "docker push ${DOCKERHUB_USERNAME}/${APP_NAME}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Triển khai ứng dụng bằng Docker Compose...'
                withCredentials([string(credentialsId: DB_PASSWORD_CREDENTIALS_ID, variable: 'DB_PASSWORD')]) {
                    // Thay thế "|| true" bằng một lệnh bat hợp lệ hơn để bỏ qua lỗi
                    bat "docker-compose down || echo No containers to stop, continuing..."
                    bat "docker-compose up -d"
                }
            }
        }
    }

    post {
        always {
            echo 'Quy trình hoàn tất.'
            bat "docker logout"
        }
    }
}