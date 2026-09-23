# =====================================================
# Geo-SAA 前端镜像
# 说明：当前网络环境无法拉取 node 容器镜像，前端 dist 由宿主机 Node 22
#       （npm run build）构建后 COPY 进镜像，由 nginx 直接 serve。
#       跨机器 / 网络可拉取 node 镜像后，可改回下方注释中的「node 容器多阶段构建」。
#
# —— 恢复 node 容器多阶段构建时使用 ——
# FROM node:22-alpine AS build
# WORKDIR /app
# COPY package*.json ./
# RUN npm ci
# COPY . .
# RUN npm run build
# FROM nginx:alpine
# COPY --from=build /app/dist /usr/share/nginx/html
# =====================================================
FROM nginx:alpine
COPY dist /usr/share/nginx/html
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
