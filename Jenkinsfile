pipeline {
    agent any

    environment {
        // Cập nhật username Docker Hub của bạn
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
                // Sử dụng 'bat' và cú pháp của Windowss
                // Thay thế `docker run` bằng `mvn` trực tiếp nếu Maven được cài đặt trên máy Jenkins
                // Hoặc đảm bảo Docker Desktop đang chạy và có thể thực thi lệnh docker
                bat 'mvnw.cmd clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Bắt đầu build Docker image...'
                // Sử dụng 'bat' cho các lệnh docker
                bat "docker build -t ${DOCKERHUB_USERNAME}/${APP_NAME}:${env.BUILD_NUMBER} ."
                bat "docker tag ${DOCKERHUB_USERNAME}/${APP_NAME}:${env.BUILD_NUMBER} ${DOCKERHUB_USERNAME}/${APP_NAME}:latest"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Đẩy image lên Docker Hub...'
                // Khối withCredentials vẫn giữ nguyên
                withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    // Sử dụng 'bat' và `set /p` để truyền password một cách an toàn
                    bat "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                    bat "docker push ${DOCKERHUB_USERNAME}/${APP_NAME}:${env.BUILD_NUMBER}"
                    bat "docker push ${DOCKERHUB_USERNAME}/${APP_NAME}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Triển khai ứng dụng bằng Docker Compose...'
                withCredentials([string(credentialsId: DB_PASSWORD_CREDENTIALS_ID, variable: 'DB_PASSWORD')]) {
                    // Sử dụng `set` để thiết lập biến môi trường cho Docker Compose
                    bat 'docker-compose down || true'
                    bat 'docker-compose up -d'
                }
            }
        }
    }

    post {
        always {
            echo 'Quy trình hoàn tất.'
            bat 'docker logout'
        }
    }
}