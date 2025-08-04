# Giai đoạn 1: Build ứng dụng bằng Maven
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# Giai đoạn 2: Tạo image cuối cùng để chạy ứng dụng
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8085
ENTRYPOINT ["java","-jar","app.jar"]