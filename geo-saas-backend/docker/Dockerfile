# =====================================================
# Geo-SaaS 后端镜像（多阶段构建 · 纯 Docker Linux 部署）
# 说明：maven 阶段走腾讯云镜像源（docker/maven-settings.xml），
#      无需宿主机 JDK/Maven，docker compose up -d --build 一键构建。
# =====================================================
FROM maven:3.9-eclipse-temurin-25 AS build
WORKDIR /app
COPY docker/maven-settings.xml /root/.m2/settings.xml
COPY pom.xml .
RUN unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy NO_PROXY; mvn -B dependency:go-offline
COPY src ./src
RUN unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy NO_PROXY; mvn -B clean package -DskipTests

# 运行阶段
FROM eclipse-temurin:25-jdk-jammy
WORKDIR /app
COPY --from=build /app/target/geo-saas-backend.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=prod"]
