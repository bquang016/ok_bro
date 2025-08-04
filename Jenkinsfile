pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = 'quangtb7'
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-credentials'
        DB_PASSWORD_CREDENTIALS_ID = 'mysql-root-password'
        APP_NAME = 'art-gallery-app'
        // *** THÊM MỚI: Chỉ định đường dẫn đến thư mục bin của Docker ***
        // Lưu ý: Dùng dấu gạch chéo kép "\\" cho đường dẫn trong Windows
        DOCKER_PATH = 'C:\\Program Files\\Docker\\Docker\\resources\\bin'
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
                // *** THAY ĐỔI: Thêm đường dẫn đầy đủ vào lệnh docker ***
                bat "\"${env.DOCKER_PATH}\\docker\" build -t ${DOCKERHUB_USERNAME}/${APP_NAME}:${env.BUILD_NUMBER} ."
                bat "\"${env.DOCKER_PATH}\\docker\" tag ${DOCKERHUB_USERNAME}/${APP_NAME}:${env.BUILD_NUMBER} ${DOCKERHUB_USERNAME}/${APP_NAME}:latest"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Đẩy image lên Docker Hub...'
                withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    // *** THAY ĐỔI: Thêm đường dẫn đầy đủ vào lệnh docker ***
                    bat "\"${env.DOCKER_PATH}\\docker\" logout"
                    bat "\"${env.DOCKER_PATH}\\docker\" login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                    bat "\"${env.DOCKER_PATH}\\docker\" push ${DOCKERHUB_USERNAME}/${APP_NAME}:${env.BUILD_NUMBER}"
                    bat "\"${env.DOCKER_PATH}\\docker\" push ${DOCKERHUB_USERNAME}/${APP_NAME}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Triển khai ứng dụng bằng Docker Compose...'
                withCredentials([string(credentialsId: DB_PASSWORD_CREDENTIALS_ID, variable: 'DB_PASSWORD')]) {
                    // *** THAY ĐỔI: Thêm đường dẫn đầy đủ vào lệnh docker-compose ***
                    bat "\"${env.DOCKER_PATH}\\docker-compose\" down || true"
                    bat "\"${env.DOCKER_PATH}\\docker-compose\" up -d"
                }
            }
        }
    }

    post {
        always {
            echo 'Quy trình hoàn tất.'
            // *** THAY ĐỔI: Thêm đường dẫn đầy đủ vào lệnh docker ***
            bat "\"${env.DOCKER_PATH}\\docker\" logout"
        }
    }
}