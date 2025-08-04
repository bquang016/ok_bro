pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = 'quangtb7'
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-credentials'
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
                bat 'mvnw.cmd clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Bắt đầu build Docker image...'
                bat "docker build -t ${DOCKERHUB_USERNAME}/${APP_NAME}:${env.BUILD_NUMBER} ."
                bat "docker tag ${DOCKERHUB_USERNAME}/${APP_NAME}:${env.BUILD_NUMBER} ${DOCKERHUB_USERNAME}/${APP_NAME}:latest"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Đẩy image lên Docker Hub...'
                // *** BẮT ĐẦU THAY ĐỔI TỪ ĐÂY ***
                withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    // Đăng xuất trước để đảm bảo phiên làm việc sạch
                    bat 'docker logout'
                    // Đăng nhập trực tiếp, không qua pipe echo
                    bat "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                    
                    // Push image
                    bat "docker push ${DOCKERHUB_USERNAME}/${APP_NAME}:${env.BUILD_NUMBER}"
                    bat "docker push ${DOCKERHUB_USERNAME}/${APP_NAME}:latest"
                }
                // *** KẾT THÚC THAY ĐỔI ***
            }
        }

        stage('Deploy') {
            steps {
                echo 'Triển khai ứng dụng bằng Docker Compose...'
                withCredentials([string(credentialsId: DB_PASSWORD_CREDENTIALS_ID, variable: 'DB_PASSWORD')]) {
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