> **English / 英文文档**：[README_EN.md](README_EN.md) · [FAQ (English)](FAQ_EN.md)

# GEO-SaaS 全域AI搜索优化平台

<div align="center">

[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-v2.0.0-blue.svg)](https://github.com/wch887292/geo-saa/releases/tag/v2.0.0)
[![Java](https://img.shields.io/badge/Java-17-orange.svg)]()
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-brightgreen.svg)]()
[![Vue](https://img.shields.io/badge/Vue-3-4FC08D.svg)]()

</div>

基于 AI 驱动的全域搜索引擎优化平台，提供品牌诊断、知识库管理、AI内容创作、多渠道分发和数据监测等一站式解决方案。

> **English:** GEO-SaaS is an AI-driven **Generative Engine Optimization (GEO)** platform that helps brands improve visibility across AI search and traditional search engines — covering brand diagnosis, knowledge base, AI content creation, multi-channel distribution, and monitoring in one place. No real AI API key required for a quick trial (built-in simulation mode).

## 🌐 官方站点与关联开源项目

本仓库由 **晋江市飞虹智科技企业管理有限公司 · 飞扬企源研发中心** 维护（负责人：吴赐虹），是飞虹智 klAI 开源生态的一部分。

- 🏠 **官方网站**：[https://www.klai.top](https://www.klai.top) — 飞虹智 klAI · 泉州制造业 AI 服务商
- 📦 **开源矩阵**：[https://www.klai.top/opensource.html](https://www.klai.top/opensource.html) — 全部开源项目一览
- 📚 **AI 知识库**：[https://kb.klai.top](https://kb.klai.top) — 产品文档与智能问答（MaxKB 驱动）

**关联项目**：

| 项目 | 简介 |
|------|------|
| [GEO-SaaS](https://github.com/wch887292/geo-saa) | AI 驱动的全域 GEO 搜索优化平台（本仓库） |
| [飞虹智·企业AI平台](https://github.com/wch887292/fyqy-ai-agent) | 中小制造企业 AI 原生一体化管理平台 |
| [FyqyClaw](https://github.com/wch887292/FyqyClaw) | 全流程 AI 驱动开发工具（IDE + AI Agent） |
| [星眠AI](https://github.com/wch887292/xmai) | 睡眠健康管理微信小程序 + 私有部署后端 |

> ⭐ 如果这个项目对你有帮助，欢迎 **Star** 并分享，让更多人发现飞虹智开源生态！


## 📚 文档导航

| 文档 | 说明 |
|------|------|
| [架构说明](docs/ARCHITECTURE.md) | 系统架构、模块划分与数据流 |
| [开发路线图](docs/ROADMAP.md) | 未来规划与社区计划 |
| [GEO/AAO 开发指南](docs/GEO_AAO_DEV_GUIDE.md) | 三代搜索优化（SEO/AEO/GEO/AAO）战略与产品映射 |
| [复盘优化报告](docs/RETROSPECTIVE_OPTIMIZATION.md) | 体检发现与工程化优化记录 |
| [全面复盘(2026-08-13)](docs/RETROSPECTIVE_20260813.md) | 全仓体检、文档时效与依赖健康检查报告 |
| [Docker 实测指南](docs/DOCKER_COMPOSE_TEST.md) | Compose 一键部署验证清单 |
| [依赖升级评估](docs/DEPENDENCY_ASSESSMENT.md) | 前端大版本升级风险与验收标准 |
| [GEO 采集器试采手册](docs/GEO_COLLECTOR_RUNBOOK.md) | 配真实 Key 后 3 分钟完成首次试采 |
| [npm 发布手册](docs/NPM_PUBLISH_GUIDE.md) | @feihong/geo-engine 发布流程与 token 配置 |
| [API 文档](APIDOC.md) | 接口清单与字段说明 |
| [贡献指南](CONTRIBUTING.md) | 如何提 Issue / Pull Request |
| [行为准则](CODE_OF_CONDUCT.md) | 社区行为公约 |
| [安全策略](SECURITY.md) | 漏洞报送与安全配置提醒 |
| [更新日志](CHANGELOG.md) | 版本变更记录 |

## 技术栈

| 层级 | 技术 |
|------|------|
| 前端 | Vue 3 + Vite + Element Plus + ECharts + Pinia |
| 后端 | Spring Boot 3.2 + Spring Security + MyBatis-Plus |
| 数据库 | MySQL 8.0 + Redis 7 |
| 构建 | Maven 3.9 + npm（容器内完成） |
| 运行环境 | Docker（容器内 JDK 17 + Node.js 22） |

## 快速开始（Docker 一键部署）

> 本项目统一以 **Docker Compose** 作为标准启动/部署方式，无需在宿主机安装 JDK / Node / MySQL / Redis / Maven。

### 前置条件

- Docker Desktop（Windows/macOS）或 Docker Engine 24+（Linux）
- Docker Compose 2+

### 一键启动

在项目根目录执行：

```bash
docker compose up -d --build
```

或使用部署脚本：

```powershell
.\deploy.ps1     # Windows
./deploy.sh      # Linux/macOS
```

`docker compose up` 会一次性拉起全套服务：`mysql`、`redis`、`rabbitmq`、`backend`(8080)、`frontend`(80)，并自动执行数据库初始化脚本。

### 配置 `.env`

首次部署前，从模板创建并填写环境变量：

```bash
cp .env.example .env
```

关键变量：

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `JWT_SECRET` | 无（必填） | JWT 签名密钥，用 `openssl rand -base64 32` 生成 |
| `MYSQL_PASSWORD` | `root` | MySQL root 密码（与 backend 一致） |
| `CORS_ALLOWED_ORIGINS` | `http://localhost` | 允许跨域访问的前端域名 |
| `BUILD_PROXY` | 空 | 可选：构建期代理，仅容器出网受限时使用 |

> 后端在 `prod` profile 下，缺失 `JWT_SECRET` 会故意 fail-fast 拒绝启动（安全设计）。

### 访问系统

| 服务 | 地址 |
|------|------|
| 前端 | `http://localhost` |
| 后端 API | `http://localhost:8080` |
| RabbitMQ 管理 | `http://localhost:15672`（guest/guest） |
| 默认管理员 | `admin` / `admin123` |

### 常用命令

```bash
docker compose ps               # 查看服务状态
docker compose logs -f backend  # 跟踪后端日志
docker compose down             # 停止并移除容器（保留数据卷）
docker compose down -v          # 停止并清空数据卷（重置环境）
```

### 本地开发模式（可选）

需要前后端热更新开发时，可只把依赖与后端放在 Docker，前端用 Vite dev：

```bash
# 1) 仅启动依赖 + 后端
docker compose up -d mysql redis rabbitmq backend

# 2) 前端开发服务器（端口 3000，/api 自动代理到 8080）
cd geo-saa-frontend
npm install
npm run dev
```

前端改动即时热更新，后端 API 由 Docker 提供。

### 前后端解耦部署（可选）

项目默认是**同域部署**：Nginx 把 `/api` 反向代理到后端，前端无需关心后端地址。若想彻底解耦（前端独立静态托管、后端独立服务器/域名），只需两处配置：

1. **前端构建时注入后端地址**（跨域直连，绕过 Nginx 反代）：
   ```bash
   VITE_API_BASE=http://<后端域名或IP>:8080 npm run build
   ```
2. **后端放行前端域名**（`.env` 里配置，逗号分隔）：
   ```env
   CORS_ALLOWED_ORIGINS=http://localhost,http://<前端域名>
   ```

> 解耦后前端是纯静态资源，可部署到任意静态托管（Nginx / CDN / 对象存储），与后端完全无关；后端仅依赖 MySQL / Redis / RabbitMQ。

## 项目结构

```
geo-saa/
├── start.ps1                  # Docker 一键启动脚本
├── deploy.ps1                 # Docker 部署脚本（Windows）
├── deploy.sh                  # Docker 部署脚本（Linux/macOS）
├── docker-compose.yml         # Docker Compose 编排（标准启动方式）
├── .env.example               # 环境变量模板（复制为 .env）
├── geo-saa-backend/           # 后端服务
│   ├── pom.xml
│   ├── docker/
│   │   └── Dockerfile
│   └── src/main/
│       ├── java/com/geosaa/
│       │   ├── GeoApplication.java        # 启动类
│       │   ├── config/                     # 配置类
│       │   ├── security/                   # JWT 安全认证
│       │   ├── common/                     # 公共工具
│       │   ├── ai/                         # AI 适配器
│       │   └── modules/
│       │       ├── auth/                   # 认证模块
│       │       ├── diagnose/               # 品牌诊断
│       │       ├── knowledge/              # 知识库
│       │       ├── content/                # AI 内容创作
│       │       ├── distribute/             # 多渠道分发
│       │       └── monitor/                # 数据监测
│       └── resources/
│           ├── application.yml             # 主配置
│           ├── application-dev.yml         # 开发环境配置
│           └── db/init.sql                 # 数据库初始化
├── geo-saa-frontend/          # 前端服务
│   ├── package.json
│   ├── Dockerfile
│   ├── vite.config.js
│   ├── nginx/
│   │   └── default.conf        # Nginx 部署配置
│   └── src/
│       ├── api/                 # API 请求封装
│       ├── views/               # 页面视图
│       │   ├── dashboard/       # 仪表盘
│       │   ├── diagnose/        # AI 品牌诊断
│       │   ├── knowledge/       # 知识库管理
│       │   ├── content/         # AI 内容创作
│       │   ├── distribute/      # 分发管理
│       │   ├── monitor/         # 数据监测
│       │   └── system/          # 系统设置
│       ├── router/              # 路由配置
│       ├── store/               # 状态管理
│       └── components/          # 公共组件
```

## 功能模块

### 1. 品牌诊断
- 输入品牌关键词，AI 自动分析搜索引擎表现
- 生成 SEO 健康报告和优化建议

### 2. 知识库管理
- 管理品牌信息、核心关键词、产品优势
- 知识版本历史追踪

### 3. AI 内容创作
- 多行业模板支持（科技、医疗、教育、金融、电商、法律）
- 批量生成 AI 优化文章
- 敏感词过滤
- **GEO 九战术健康度校验**（`POST /content/geo-validate`）：按 Princeton KDD 2024 论文九大战术
  （专家引语 / 量化数据 / 引用来源 / 流畅度 / 技术术语等）加权评分；
  **关键词堆砌自动拦截**（论文实测可见度 −8%~−10%），创建内容时返回 400

### 4. 多渠道分发
- 支持 150+ 渠道分发
- 定时任务调度
- 进度追踪

### 5. 数据监测
- 搜索排名监控
- 流量分析
- 品牌声量趋势
- 核心指标含**数据真实性闸门**：`hasData=false` 时不再用随机数冒充
  （模拟模式打 `simulated` 标，生产关闭模拟返回真实空值）
- **GEO 真实数据采集器**（可配 Perplexity / OpenAI 兼容网关，每日自动采集
  mentionRate/首推率/收录量写入统计表，失败绝不写入模拟数据）

### 6. 资产存证
- 独立 `asset_record` 数据模型（内容/知识/分发/诊断聚合 + 独立存证双视图）
- 按年/月过滤、分页浏览品牌资产

### 7. 系统管理
- 用户认证与权限管理
- AI 模型配置（OpenAI / 通义千问 / 豆包）
- 模拟模式（无需 API Key 即可体验）

## 配置说明

### AI 模型配置

在 `application.yml` 中配置 AI 模型：

```yaml
ai:
  openai:
    api-key: "sk-xxx"           # OpenAI API Key
    api-url: https://api.openai.com/v1
    model: gpt-4
  tongyi:
    api-key: "sk-xxx"           # 通义千问 API Key
  doubao:
    api-key: "sk-xxx"           # 豆包 API Key
  simulation:
    enabled: true               # 模拟模式，无 API Key 时返回模拟数据
```

### 开发模式

- RabbitMQ 默认禁用，不影响核心功能
- 数据库默认凭据: `root` / `root`
- 日志级别: `com.geosaa: debug`

## 常见问题

### Q: 启动报错 "端口 8080 已被占用"
A: Docker 环境下先确认宿主机端口未被占用，或调整 `docker-compose.yml` 的端口映射：
```powershell
netstat -ano | findstr ":8080 "
Stop-Process -Id <PID> -Force
```

### Q: 数据库连接失败 / 后端起不来
A: 检查容器状态与日志，确保依赖服务 healthy 后再起 backend：
```bash
docker compose ps
docker compose logs -f backend
```
数据库凭据默认 `root/root`，可在 `.env` 中通过 `MYSQL_PASSWORD` 统一修改。

### Q: 前端无法访问后端 API
A: Docker 部署下前后端在同一 Compose 网络，前端已通过 Nginx 反向代理 `/api` 到后端；若改动端口，需同步调整 `docker-compose.yml` 与 `nginx/default.conf`。

### Q: 不需要 RabbitMQ
A: 后端 `dev` profile 已禁用 RabbitMQ；`docker-compose.yml` 中该服务是可选编排，不启动它不影响核心功能。


---

## 🤝 社区支持

关注飞虹智 klAI 动态，获取最新开源项目更新与技术教程：

![社区支持二维码](https://github.com/geo-saa/releases/download/v1.0.0-community/qrcode-community.png)

扫码加入 **飞虹智企微小助手**，获取：
- 技术答疑与部署指导
- 开源项目更新通知
- 本地化服务预约（泉州地区）
- 企业 AI 数字化咨询

---

*晋江市飞虹智科技企业管理有限公司 · 飞扬企源研发中心 · 负责人：吴赐虹*

## 开源许可证

本项目采用 [MIT License](LICENSE) 开源。欢迎通过 [贡献指南](CONTRIBUTING.md) 提交 Issue 与 Pull Request，共建社区。

---

⭐ 如果这个项目对你有帮助，欢迎 Star 与分享！

---

## 组织与署名

<!-- FYQY-ENTITY-BLOCK v1 -->

**公司**：晋江市飞虹智科技企业管理有限公司
**中心**：飞扬企源研发中心
**负责人**：吴赐虹

- 官网：https://www.klai.top
- 知识库：https://kb.klai.top
- 开源矩阵：https://github.com/wch887292
- 实体权威声明（机器可读）：https://www.klai.top/entity.jsonld

> 本项目版权归 晋江市飞虹智科技企业管理有限公司 所有，由 飞扬企源研发中心 研发交付。
> Entity: `https://www.klai.top/#organization` · Author: `https://www.klai.top/#person-wuchihong`
