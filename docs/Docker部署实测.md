# Docker Compose 实测指南（容器内网部署 · Linux/1Panel）

> 状态：**已验证（2026-09）**—— WSL2 Debian12 + 1Panel 共存环境下，
> `docker compose up -d --build` 全栈 6 容器健康，后端 Java 25 启动成功，
> 前端 `http://127.0.0.1:8009` 返回 200，`admin/sbc19921107` 登录可用。

## 一、部署形态（重要）

本项目容器**端口在容器内**（container-internal）：除前端外，mysql/redis/rabbitmq/backend/phpmyadmin
均**不发布宿主端口**，容器间通过 `geo-saas-net` 自定义网络按**服务名**互访（backend 访问 `mysql:3306` / `redis:6379` / `rabbitmq:5672`）。

- **唯一对外入口**：前端 Nginx/OpenResty 的 `80` 端口，映射为宿主 **`127.0.0.1:8009`**（回环）。
- 宿主 `80` 端口已被 **1Panel 的 openresty（host 网络）** 占用，前端不直接绑 80；
  对外访问通常经 1Panel Web 面板建站/反向代理指向 `http://127.0.0.1:8009`。
- 后端接口不直接暴露宿主，前端 Nginx 把 `/api` 反代到容器内 `backend:8080`。

## 二、前置条件

- Docker Engine + Compose v2（本项目在 WSL2 Debian12、docker 29.x 实测）
- 1Panel（可选共存；若不用 1Panel，可把前端端口改为 `8009:80` 或 `80:80`）
- 项目根目录准备 `.env`（`JWT_SECRET` **必填**，缺失时后端 fail-fast 拒绝启动）。模板见 `.env.example`：

```env
JWT_SECRET=<openssl rand -base64 32 生成的值>
MYSQL_HOST=mysql              # compose 服务名，容器内互访
MYSQL_PASSWORD=<你的密码>
REDIS_HOST=redis
RABBITMQ_HOST=rabbitmq
CORS_ALLOWED_ORIGINS=http://localhost
SPRING_PROFILES_ACTIVE=prod
AI_SIMULATION_ENABLED=true
# 可选：GEO 真实采集器（G-01），默认关闭
# GEO_COLLECTOR_ENABLED=true
# GEO_PERPLEXITY_API_KEY=pplx-xxx
```

## 三、一键启动

```bash
cp .env.example .env          # 首次：按需修改密码/JWT_SECRET
docker compose up -d --build
```

首次启动 MySQL 容器执行挂载的 `geo-saas-backend/src/main/resources/db/init.sql`：
自动建库 `geo_saas`、建全部表（含 `asset_record`）、注入 `admin/sbc19921107` 与系统配置。

## 四、验证清单

```bash
# 1. 全部容器健康（期望 mysql/redis/rabbitmq healthy，backend/frontend running）
docker compose ps

# 2. 后端启动日志（期望 "Started GeoApplication"）
docker compose logs backend | grep -E 'Started GeoApplication|Tomcat started'

# 3. 前端可达（唯一对外入口）
curl -I http://127.0.0.1:8009/        # 期望 200

# 4. 端到端冒烟（在后端容器内直连，或临时发布端口后执行）
#    后端未发布宿主端口，冒烟脚本需在 compose 网络内跑：
docker compose exec backend sh -c "cd /app && python smoke_test.py" 2>/dev/null || echo "smoke_test 未打进后端镜像，可用 curl 从容器内验证"
docker compose exec backend curl -s http://127.0.0.1:8080/api/v1/system/health   # 期望 {"code":200,...}

# 5. 登录（从 backend 容器内或经前端反代）
curl -s -X POST http://127.0.0.1:8009/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"sbc19921107"}'
```

## 五、静态检查结论

| 检查项 | 结论 |
|--------|------|
| MySQL 首次初始化 `init.sql` | ✅ 挂载 `docker-entrypoint-initdb.d`，自动建库建表 |
| 后端 prod 档案环境变量 | ✅ `MYSQL_HOST/USER/PASSWORD`、`REDIS_HOST`、`RABBITMQ_HOST`、`JWT_SECRET`(fail-fast)、`CORS_ALLOWED_ORIGINS` 齐全 |
| RabbitMQ 联动 | ✅ compose 提供 rabbitmq 4，容器内按服务名连接 |
| 采集器配置 | ✅ 默认关闭，未配 key 后端照常启动 |
| 前端镜像 | ✅ node:24-alpine 多阶段构建（npmmirror `npm ci`）+ 复用 1panel/openresty 运行 |
| 镜像源 | ✅ Maven 走腾讯云；npm 走 npmmirror（非阿里、国内直连） |

## 六、注意事项

- **数据卷持久化**：`mysql-data` 卷在首次（空卷）时执行 `init.sql`；改表结构需 `docker compose down -v` 重建（会清空数据）。
- **端口占用**：唯一宿主端口是 `127.0.0.1:8009`（前端）；宿主 `80` 属 1Panel openresty。若与其它服务冲突，改 compose 前端端口映射即可。
- **镜像复用**：`deploy.sh` 会逐一 `image inspect` 跳过已存在的镜像，减少重复拉取；首次拉取依赖网络（必要时开启代理）。
