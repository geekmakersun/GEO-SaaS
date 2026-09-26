# =====================================================
# Geo-SaaS 前端镜像（多阶段构建 · 纯 Docker Linux 部署）
# 说明：node 24 LTS 阶段走 npmmirror 镜像加速 npm ci，无需宿主机 Node。
#      运行阶段复用系统已有 1panel/openresty 镜像（复用；仅当无任何
#      nginx 相关镜像时才改用 nginx）。OpenResty 托管 dist 并将 /api 反代
#      到内部 backend:8080。
# =====================================================
FROM node:24-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm config set registry https://registry.npmmirror.com && npm ci
COPY . .
RUN npm run build

# 运行阶段：复用 1panel/openresty（1Panel 统一 openresty 入口体系）
FROM 1panel/openresty:1.31.1.1-2-4-noble
COPY --from=build /app/dist /usr/local/openresty/nginx/html
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
