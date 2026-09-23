# =====================================================
# GEO-SaaS 全域AI搜索优化平台 - Docker 部署脚本 (Windows)
# =====================================================
# 用法:  .\deploy.ps1
# 依赖:  Docker Desktop（或 Docker Engine 24+）+ Docker Compose 2+
# 说明:  统一以 Docker Compose 拉起全套服务，无需宿主机 JDK/Node/MySQL/Redis
# =====================================================

$ErrorActionPreference = "Continue"
$GREEN = "Green"; $YELLOW = "Yellow"; $RED = "Red"; $CYAN = "Cyan"
$ROOT = $PSScriptRoot
$JAR = Join-Path $ROOT "geo-saa-backend\target\geo-saa-backend.jar"

function Write-Info { param($m) Write-Host "  [INFO] $m" -ForegroundColor $GREEN }
function Write-Warn { param($m) Write-Host "  [WARN] $m" -ForegroundColor $YELLOW }
function Write-Err  { param($m) Write-Host "  [ERROR] $m" -ForegroundColor $RED }

Write-Host "=========================================" -ForegroundColor $CYAN
Write-Host "  GEO-SaaS 全域AI搜索优化平台 部署脚本 (Docker)" -ForegroundColor $CYAN
Write-Host "=========================================" -ForegroundColor $CYAN

# ---------- 1. 检查 Docker ----------
Write-Host "`n[1/5] 检查 Docker" -ForegroundColor $GREEN
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Err "未检测到 docker 命令。请安装 Docker Desktop：https://www.docker.com/products/docker-desktop/"
    exit 1
}
Write-Info "Docker: $(docker --version)"
Write-Info "Compose: $(docker compose version)"
try {
    docker info *> $null
    if ($LASTEXITCODE -ne 0) { throw "daemon 未运行" }
    Write-Info "Docker daemon 运行正常"
} catch {
    Write-Err "Docker daemon 未运行，请启动 Docker Desktop 后重试。"
    exit 1
}

# ---------- 2. 准备 .env ----------
Write-Host "`n[2/5] 检查 .env" -ForegroundColor $GREEN
$envFile = Join-Path $ROOT ".env"
if (-not (Test-Path $envFile)) {
    if (Test-Path (Join-Path $ROOT ".env.example")) {
        Copy-Item (Join-Path $ROOT ".env.example") $envFile
        Write-Warn "已从 .env.example 创建 .env，请检查 JWT_SECRET、MYSQL_PASSWORD 等配置。"
    } else {
        Write-Err "既无 .env 也无 .env.example，请先创建 .env 配置文件。"
        exit 1
    }
} else {
    Write-Info ".env 已存在"
}

# ---------- 3. 构建后端 JAR（当前 Dockerfile 为 COPY jar 方式） ----------
Write-Host "`n[3/5] 检查后端 JAR" -ForegroundColor $GREEN
if (-not (Test-Path $JAR)) {
    if (Get-Command mvn -ErrorAction SilentlyContinue) {
        Write-Info "后端 JAR 缺失，使用宿主 Maven 构建（依赖 ~/.m2/settings.xml 镜像配置）..."
        Push-Location (Join-Path $ROOT "geo-saa-backend")
        try {
            mvn clean package -DskipTests
            if ($LASTEXITCODE -ne 0) { throw "Maven 构建失败" }
        } finally { Pop-Location }
    } else {
        Write-Warn "后端 JAR 缺失且未安装 Maven。"
        Write-Warn "  方案A: 安装 Maven 后构建（cd geo-saa-backend && mvn clean package -DskipTests）"
        Write-Warn "  方案B: 在后端 Dockerfile 启用注释内的多阶段构建，以纯 Docker 方式构建"
        Write-Warn "继续尝试 docker compose 构建（COPY 缺失 jar 时镜像构建会失败）。"
    }
} else {
    Write-Info "后端 JAR 已存在，跳过构建"
}

# ---------- 4. 构建并启动 ----------
Write-Host "`n[4/5] 构建并启动所有服务" -ForegroundColor $GREEN
Push-Location $ROOT
try { docker compose up -d --build } finally { Pop-Location }
if ($LASTEXITCODE -ne 0) {
    Write-Err "docker compose up 失败，请查看上方日志。"
    exit 1
}

# ---------- 5. 等待并输出 ----------
Write-Host "`n[5/5] 等待服务启动" -ForegroundColor $GREEN
Write-Host "等待数据库初始化..." -ForegroundColor $YELLOW
Start-Sleep -Seconds 15

Push-Location $ROOT
try { docker compose ps } finally { Pop-Location }

Write-Host "=========================================" -ForegroundColor $CYAN
Write-Host "  部署完成" -ForegroundColor $GREEN
Write-Host "  前端地址: http://localhost" -ForegroundColor $GREEN
Write-Host "  后端地址: http://localhost:8080" -ForegroundColor $GREEN
Write-Host "  RabbitMQ管理: http://localhost:15672 (guest/guest)" -ForegroundColor $GREEN
Write-Host ""
Write-Host "  默认管理员账号: admin" -ForegroundColor $YELLOW
Write-Host "  默认管理员密码: admin123" -ForegroundColor $YELLOW
Write-Host "  停止服务: docker compose down" -ForegroundColor $YELLOW
Write-Host "=========================================" -ForegroundColor $CYAN
