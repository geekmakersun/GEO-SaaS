# =====================================================
# GEO-SaaS 全域AI搜索优化平台 - Docker 一键启动脚本
# =====================================================
# 使用方法: 右键 -> 使用 PowerShell 运行
# 依赖:    Docker Desktop（或 Docker Engine 24+）+ Docker Compose 2+
# 说明:    统一以 Docker Compose 拉起全套服务，无需在宿主机安装
#          JDK / Node / MySQL / Redis / Maven
# =====================================================

$ErrorActionPreference = "Continue"
$GREEN = "Green"; $YELLOW = "Yellow"; $RED = "Red"; $CYAN = "Cyan"
$ENV_FILE = Join-Path $PSScriptRoot ".env"
$ENV_TEMPLATE = Join-Path $PSScriptRoot ".env.example"

function Write-Info  { param($m) Write-Host "  [INFO] $m" -ForegroundColor $GREEN }
function Write-Warn  { param($m) Write-Host "  [WARN] $m" -ForegroundColor $YELLOW }
function Write-Err   { param($m) Write-Host "  [ERROR] $m" -ForegroundColor $RED }

function Show-Banner {
    Clear-Host
    $banner = @"

====================================================
           GEO-SaaS 全域AI搜索优化平台
           一键启动脚本 (Docker) v2.0
====================================================

"@
    Write-Host $banner -ForegroundColor $CYAN
}

# ===========================================
# 1. 检查 Docker
# ===========================================
function Check-Docker {
    Write-Host "`n========== [1/4] 检查 Docker ==========" -ForegroundColor $CYAN
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Err "未检测到 docker 命令。请先安装 Docker Desktop 并确保其在 PATH 中。"
        Write-Err "下载: https://www.docker.com/products/docker-desktop/"
        exit 1
    }
    $v = docker --version 2>&1
    $c = docker compose version 2>&1
    Write-Info "Docker: $v"
    Write-Info "Compose: $c"

    try {
        docker info *> $null
        if ($LASTEXITCODE -ne 0) { throw "daemon 未运行" }
        Write-Info "Docker daemon 运行正常"
    } catch {
        Write-Err "Docker daemon 未运行，请启动 Docker Desktop 后重试。"
        exit 1
    }
}

# ===========================================
# 2. 准备 .env
# ===========================================
function Ensure-Env {
    Write-Host "`n========== [2/4] 检查 .env ==========" -ForegroundColor $CYAN
    if (-not (Test-Path $ENV_FILE)) {
        if (Test-Path $ENV_TEMPLATE) {
            Copy-Item $ENV_TEMPLATE $ENV_FILE
            Write-Warn "未找到 .env，已从 .env.example 创建。"
            Write-Warn "请检查并填写 JWT_SECRET、MYSQL_PASSWORD 等配置后重新运行。"
        } else {
            Write-Err "既无 .env 也无 .env.example，请先创建 .env 配置文件。"
            exit 1
        }
    } else {
        Write-Info ".env 已存在"
    }
}

# ===========================================
# 3. 拉起服务
# ===========================================
function Start-Compose {
    Write-Host "`n========== [3/4] 启动全部服务 ==========" -ForegroundColor $CYAN
    Push-Location $PSScriptRoot
    try {
        docker compose up -d --build
        if ($LASTEXITCODE -ne 0) {
            Write-Err "docker compose up 失败，请查看上方日志。"
            exit 1
        }
    } finally { Pop-Location }
    Write-Info "服务已启动，等待初始化..."
    Start-Sleep -Seconds 12
}

# ===========================================
# 4. 输出状态与访问地址
# ===========================================
function Show-Result {
    Write-Host "`n========== [4/4] 服务状态 ==========" -ForegroundColor $CYAN
    Push-Location $PSScriptRoot
    try { docker compose ps } finally { Pop-Location }

    $box = @"

====================================================
                    启动完成
----------------------------------------------------
  前端地址:  http://localhost
  后端地址:  http://localhost:8080
  RabbitMQ:  http://localhost:15672 (guest/guest)
  默认管理员: admin / admin123
  停止服务:  docker compose down
====================================================

"@
    Write-Host $box -ForegroundColor $GREEN

    Start-Sleep -Seconds 1
    Start-Process "http://localhost"
}

# ===========================================
# 主流程
# ===========================================
Show-Banner
Check-Docker
Ensure-Env
Start-Compose
Show-Result
