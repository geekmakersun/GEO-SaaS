# =====================================================
# Geo-SAA 后端镜像
# 说明：当前环境容器无法出网（VPN TUN 干扰容器出站 HTTPS），
#       jar 由宿主机 Maven 构建（走阿里云官方源，见仓库内说明）后 COPY 进镜像。
#       网络正常 / 跨机器需要纯容器构建时，可改回下方注释的多阶段方案。
#
# —— 恢复容器内多阶段构建时使用 ——
# FROM maven:3.9-eclipse-temurin-17 AS build
# WORKDIR /app
# COPY docker/maven-settings.xml /root/.m2/settings.xml
# COPY pom.xml .
# RUN unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy NO_PROXY; mvn -B dependency:go-offline
# COPY src ./src
# RUN unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy NO_PROXY; mvn -B clean package -DskipTests
# FROM eclipse-temurin:17-jdk-jammy
# =====================================================
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app
COPY target/geo-saa-backend.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=prod"]
