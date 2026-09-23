#!/bin/bash
# =====================================================
# GEO-SaaS 全域AI搜索优化平台 - Docker 部署脚本 (Linux/macOS)
# =====================================================
# 用法:  ./deploy.sh
# 依赖:  Docker Engine 24+ + Docker Compose 2+
# 说明:  统一以 Docker Compose 拉起全套服务，无需宿主机 JDK/Node/MySQL/Redis
# =====================================================
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAR="$ROOT/geo-saa-backend/target/geo-saa-backend.jar"

echo "========================================="
echo -e "${CYAN}  GEO-SaaS 全域AI搜索优化平台 部署脚本 (Docker)${NC}"
echo "========================================="

# ---------- 1. 检查 Docker ----------
echo -e "\n${GREEN}[1/5] 检查 Docker${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: 未检测到 docker 命令，请先安装 Docker。${NC}"
    exit 1
fi
echo "Docker: $(docker --version)"
echo "Compose: $(docker compose version)"
if ! docker info &> /dev/null; then
    echo -e "${RED}错误: Docker daemon 未运行，请启动 Docker 后重试。${NC}"
    exit 1
fi

# ---------- 2. 准备 .env ----------
echo -e "\n${GREEN}[2/5] 检查 .env${NC}"
if [ ! -f "$ROOT/.env" ]; then
    if [ -f "$ROOT/.env.example" ]; then
        cp "$ROOT/.env.example" "$ROOT/.env"
        echo -e "${YELLOW}已从 .env.example 创建 .env，请检查 JWT_SECRET、MYSQL_PASSWORD 等配置。${NC}"
    else
        echo -e "${RED}错误: 既无 .env 也无 .env.example，请先创建 .env。${NC}"
        exit 1
    fi
else
    echo ".env 已存在"
fi

# ---------- 3. 构建后端 JAR（当前 Dockerfile 为 COPY jar 方式） ----------
echo -e "\n${GREEN}[3/5] 检查后端 JAR${NC}"
if [ ! -f "$JAR" ]; then
    if command -v mvn &> /dev/null; then
        echo "后端 JAR 缺失，使用宿主 Maven 构建（依赖 ~/.m2/settings.xml 镜像配置）..."
        (cd "$ROOT/geo-saa-backend" && mvn clean package -DskipTests)
    else
        echo -e "${YELLOW}后端 JAR 缺失且未安装 Maven。${NC}"
        echo -e "${YELLOW}  方案A: 安装 Maven 后构建（cd geo-saa-backend && mvn clean package -DskipTests）${NC}"
        echo -e "${YELLOW}  方案B: 在后端 Dockerfile 启用注释内的多阶段构建，以纯 Docker 方式构建${NC}"
        echo -e "${YELLOW}继续尝试 docker compose 构建（COPY 缺失 jar 时镜像构建会失败）。${NC}"
    fi
else
    echo "后端 JAR 已存在，跳过构建"
fi

# ---------- 4. 构建并启动 ----------
echo -e "\n${GREEN}[4/5] 构建并启动所有服务${NC}"
(cd "$ROOT" && docker compose up -d --build)

# ---------- 5. 等待并输出 ----------
echo -e "\n${GREEN}[5/5] 等待服务启动${NC}"
echo "等待数据库初始化..."
sleep 15

(cd "$ROOT" && docker compose ps)

echo "========================================="
echo -e "${GREEN}  部署完成${NC}"
echo -e "  前端地址: ${GREEN}http://localhost${NC}"
echo -e "  后端地址: ${GREEN}http://localhost:8080${NC}"
echo -e "  RabbitMQ管理: ${GREEN}http://localhost:15672${NC} (guest/guest)"
echo ""
echo "  默认管理员账号: admin"
echo "  默认管理员密码: admin123"
echo -e "  停止服务: ${YELLOW}docker compose down${NC}"
echo "========================================="
