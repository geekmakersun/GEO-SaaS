#!/bin/bash
# =====================================================
# GEO-SaaS 全域AI搜索优化平台 - Docker 部署脚本 (Linux/macOS)
# =====================================================
# 用法:  ./deploy.sh            # 复用已有镜像：存在即复用，缺失才拉取/构建
#        ./deploy.sh --rebuild  # 强制重新构建 geo-saas-backend / geo-saas-frontend
#        ./deploy.sh --pull     # 强制重新拉取外部基础镜像
# 依赖:  Docker Engine 24+ + Docker Compose 2+
# 说明:  纯 Docker 部署，无需宿主机 JDK/Maven/Node。内部服务端口收在容器内网，
#        唯一对外入口为前端 Nginx 的 80 端口。基础镜像走镜像站。
# =====================================================
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------- 镜像清单 ----------
# 外部拉取的基础镜像（运行服务）
RUNTIME_IMAGES=( "mysql:8.4" "redis:8-alpine" "rabbitmq:4-management-alpine" "phpmyadmin:5.2.3" )
# 本地多阶段构建的镜像
BUILT_IMAGES=( "geo-saas-backend" "geo-saas-frontend" )

has_image() { docker image inspect "$1" >/dev/null 2>&1; }

REBUILD=false
FORCE_PULL=false
for arg in "$@"; do
  case "$arg" in
    --rebuild) REBUILD=true ;;
    --pull)    FORCE_PULL=true ;;
    *) echo -e "${RED}未知参数: $arg（可用 --rebuild / --pull）${NC}"; exit 1 ;;
  esac
done

echo "========================================="
echo -e "${CYAN}  GEO-SaaS 全域AI搜索优化平台 部署脚本 (Docker)${NC}"
echo "========================================="

# ---------- 1. 检查 Docker ----------
echo -e "\n${GREEN}[1/6] 检查 Docker${NC}"
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
echo -e "\n${GREEN}[2/6] 检查 .env${NC}"
if [ ! -f "$ROOT/.env" ]; then
    if [ -f "$ROOT/.env.example" ]; then
        cp "$ROOT/.env.example" "$ROOT/.env"
        echo -e "${YELLOW}已从 .env.example 创建 .env。请设置必填项：${NC}"
        echo -e "${YELLOW}  JWT_SECRET=$(openssl rand -base64 32)${NC}"
        echo -e "${YELLOW}  MYSQL_PASSWORD=自定义强密码${NC}"
        echo -e "${YELLOW}  并确认 CORS_ALLOWED_ORIGINS。修改后重新运行本脚本。${NC}"
    else
        echo -e "${RED}错误: 既无 .env 也无 .env.example，请先创建 .env。${NC}"
        exit 1
    fi
else
    echo ".env 已存在"
fi

# ---------- 3. 镜像复用检查 ----------
echo -e "\n${GREEN}[3/6] 检查镜像（存在即复用，缺失才拉取/构建）${NC}"
missing_runtime=()
for img in "${RUNTIME_IMAGES[@]}"; do
    if has_image "$img"; then
        echo -e "  ${GREEN}✔ 已有${NC} $img（复用）"
    else
        echo -e "  ${YELLOW}✘ 缺失${NC} $img（将拉取）"
        missing_runtime+=("$img")
    fi
done

missing_built=()
for img in "${BUILT_IMAGES[@]}"; do
    if has_image "$img"; then
        echo -e "  ${GREEN}✔ 已有${NC} $img（复用）"
    else
        echo -e "  ${YELLOW}✘ 缺失${NC} $img（将构建）"
        missing_built+=("$img")
    fi
done

# ---------- 4. 决定构建/拉取策略 ----------
echo -e "\n${GREEN}[4/6] 构建策略${NC}"
NEED_BUILD=false
if [ "$REBUILD" = true ]; then
    echo -e "${YELLOW}检测到 --rebuild，强制重新构建后端/前端镜像。${NC}"
    NEED_BUILD=true
elif [ ${#missing_built[@]} -gt 0 ]; then
    echo -e "${YELLOW}存在缺失的构建镜像（${missing_built[*]}），将执行构建（首次构建需拉基础镜像，较慢）。${NC}"
    NEED_BUILD=true
else
    echo -e "${GREEN}geo-saas-backend / geo-saas-frontend 均已存在，复用，跳过构建。${NC}"
fi

if [ "$FORCE_PULL" = true ]; then
    echo -e "${YELLOW}检测到 --pull，强制重新拉取外部基础镜像。${NC}"
fi

# ---------- 5. 构建并启动 ----------
echo -e "\n${GREEN}[5/6] 启动服务${NC}"
if [ "$NEED_BUILD" = true ]; then
    (cd "$ROOT" && docker compose up -d --build)
elif [ "$FORCE_PULL" = true ]; then
    (cd "$ROOT" && docker compose pull)
    (cd "$ROOT" && docker compose up -d)
else
    (cd "$ROOT" && docker compose up -d)
fi

# ---------- 6. 等待并输出 ----------
echo -e "\n${GREEN}[6/6] 等待服务启动${NC}"
echo "等待数据库初始化..."
sleep 15

(cd "$ROOT" && docker compose ps)

echo "========================================="
echo -e "${GREEN}  部署完成${NC}"
echo -e "  访问地址: ${GREEN}http://localhost${NC} (前端，唯一对外入口)"
echo -e "  后端 API: 容器内网 http://backend:8080（经前端 Nginx 反代 /api）"
echo -e "  MySQL/Redis/RabbitMQ: 容器内网按服务名访问，未暴露宿主端口"
echo ""
echo "  默认管理员账号: admin"
echo "  默认管理员密码: admin123"
echo -e "  停止服务: ${YELLOW}docker compose down${NC}"
echo "========================================="
