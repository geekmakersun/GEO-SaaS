# GEO-SaaS · Global AI Search Optimization Platform

<div align="center">

[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-v2.0.0-blue.svg)](https://github.com/wch887292/geo-saa/releases/tag/v2.0.0)
[![Java](https://img.shields.io/badge/Java-17-orange.svg)]()
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-brightgreen.svg)]()
[![Vue](https://img.shields.io/badge/Vue-3-4FC08D.svg)]()

</div>

An AI-driven **Generative Engine Optimization (GEO)** platform that helps brands improve visibility across AI search and traditional search engines — covering brand diagnosis, knowledge base, AI content creation, multi-channel distribution, and monitoring in one place. No real AI API key required for a quick trial (built-in simulation mode).

> **中文**: [README.md](README.md)

## 🌐 Official Site & Related Open-Source Projects

Maintained by **Jinjiang Feihongzhi Technology Enterprise Management Co., Ltd. · Feiyang Qiyuan R&D Center** (Lead: Wu Cihong), part of the Feihongzhi klAI open-source ecosystem.

- 🏠 **Official site**: [https://www.klai.top](https://www.klai.top) — Feihongzhi klAI · Quanzhou manufacturing-AI service provider
- 📦 **Open-source matrix**: [https://www.klai.top/opensource.html](https://www.klai.top/opensource.html)
- 📚 **AI knowledge base**: [https://kb.klai.top](https://kb.klai.top) — product docs & smart Q&A (MaxKB-powered)

**Related projects**:

| Project | Description |
|------|------|
| [GEO-SaaS](https://github.com/wch887292/geo-saa) | AI-driven GEO search optimization platform (this repo) |
| [Feihongzhi Enterprise AI Platform](https://github.com/wch887292/fyqy-ai-agent) | AI-native integrated management platform for SME manufacturers |
| [FyqyClaw](https://github.com/wch887292/FyqyClaw) | Full-lifecycle AI-driven dev tool (IDE + AI Agent) |
| [Xingmian AI](https://github.com/wch887292/xmai) | Sleep-health WeChat mini-program + private-deployable backend |

> ⭐ If this project helps you, please **Star** and share it so more people discover the Feihongzhi open-source ecosystem!

## 📚 Documentation

| Document | Description |
|------|------|
| [Architecture](docs/ARCHITECTURE.md) | System architecture, module breakdown, data flow |
| [Roadmap](docs/ROADMAP.md) | Future planning & community plan |
| [GEO/AAO Dev Guide](docs/GEO_AAO_DEV_GUIDE.md) | 3-generation search optimization (SEO/AEO/GEO/AAO) strategy & product mapping |
| [Retrospective Optimization](docs/RETROSPECTIVE_OPTIMIZATION.md) | Findings & engineering optimization log |
| [Docker Compose Test](docs/DOCKER_COMPOSE_TEST.md) | Compose one-click deployment verification checklist |
| [Dependency Assessment](docs/DEPENDENCY_ASSESSMENT.md) | Frontend major-version upgrade risk & acceptance |
| [API Docs](APIDOC.md) | Endpoint list & field descriptions |
| [Contributing](CONTRIBUTING.md) | How to file Issues / Pull Requests |
| [Code of Conduct](CODE_OF_CONDUCT.md) | Community covenant |
| [Security](SECURITY.md) | Vulnerability reporting & security config reminders |
| [Changelog](CHANGELOG.md) | Version change log |

## Tech Stack

| Layer | Technology |
|------|------|
| Frontend | Vue 3 + Vite + Element Plus + ECharts + Pinia |
| Backend | Spring Boot 3.2 + Spring Security + MyBatis-Plus |
| Database | MySQL 8.0 + Redis 7 |
| Build | Maven 3.9 + npm (in containers) |
| Runtime | Docker (JDK 17 + Node.js 22 inside containers) |

## Quick Start (Docker)

> This project standardizes on **Docker Compose** for startup/deployment. No need to install JDK / Node / MySQL / Redis / Maven on the host.

### Prerequisites

- Docker Desktop (Windows/macOS) or Docker Engine 24+ (Linux)
- Docker Compose 2+

### One-click start

Run at the project root:

```bash
docker compose up -d --build
```

Or use the deploy scripts:

```powershell
.\deploy.ps1     # Windows
./deploy.sh      # Linux/macOS
```

`docker compose up` brings up the full stack at once: `mysql`, `redis`, `rabbitmq`, `backend`(8080), `frontend`(80), and runs the database init script automatically.

### Configure `.env`

Before first deploy, create the env file from the template:

```bash
cp .env.example .env
```

Key variables:

| Variable | Default | Description |
|------|--------|------|
| `JWT_SECRET` | none (required) | JWT signing secret; generate with `openssl rand -base64 32` |
| `MYSQL_PASSWORD` | `root` | MySQL root password (must match backend) |
| `CORS_ALLOWED_ORIGINS` | `http://localhost` | Allowed frontend origins |
| `BUILD_PROXY` | empty | Optional build-time proxy (only if container egress is restricted) |

> Under the `prod` profile, the backend deliberately fails fast if `JWT_SECRET` is missing (fail-safe design).

### Access

| Service | Address |
|------|------|
| Frontend | `http://localhost` |
| Backend API | `http://localhost:8080` |
| RabbitMQ management | `http://localhost:15672` (guest/guest) |
| Default admin | `admin` / `admin123` |

### Common commands

```bash
docker compose ps               # service status
docker compose logs -f backend  # follow backend logs
docker compose down             # stop & remove containers (keep volumes)
docker compose down -v          # stop & wipe volumes (reset environment)
```

### Local dev mode (optional)

For hot-reload development, keep deps and backend in Docker and run the frontend via Vite:

```bash
# 1) Start deps + backend only
docker compose up -d mysql redis rabbitmq backend

# 2) Frontend dev server (port 3000, /api proxies to 8080)
cd geo-saa-frontend
npm install
npm run dev
```

Frontend changes hot-reload while the backend API is provided by Docker.

### Decoupled frontend/backend deploy (optional)

The default setup is **same-origin**: Nginx reverse-proxies `/api` to the backend, so the frontend never needs to know the backend address. To fully decouple (frontend on any static host, backend on its own server/domain), only two configs:

1. **Inject the backend address at frontend build time** (cross-origin direct call, bypassing the Nginx proxy):
   ```bash
   VITE_API_BASE=http://<backend-domain-or-ip>:8080 npm run build
   ```
2. **Allow the frontend origin in the backend** (`.env`, comma-separated):
   ```env
   CORS_ALLOWED_ORIGINS=http://localhost,http://<frontend-domain>
   ```

> Decoupled, the frontend is pure static assets and can live on any static host (Nginx / CDN / object storage), fully independent of the backend; the backend only depends on MySQL / Redis / RabbitMQ.

## Project Structure

```
geo-saa/
├── start.ps1                  # Docker one-click start script
├── deploy.ps1                 # Docker deploy script (Windows)
├── deploy.sh                  # Docker deploy script (Linux/macOS)
├── docker-compose.yml         # Docker Compose orchestration (standard start)
├── .env.example               # env template (copy to .env)
├── geo-saa-backend/           # backend service
│   ├── pom.xml
│   ├── docker/Dockerfile
│   └── src/main/
│       ├── java/com/geosaa/
│       │   ├── GeoApplication.java        # bootstrap
│       │   ├── config/                     # config
│       │   ├── security/                   # JWT auth
│       │   ├── common/                     # utilities
│       │   ├── ai/                         # AI adapter
│       │   └── modules/
│       │       ├── auth/                   # auth
│       │       ├── diagnose/               # brand diagnosis
│       │       ├── knowledge/              # knowledge base
│       │       ├── content/                # AI content creation
│       │       ├── distribute/             # multi-channel distribution
│       │       └── monitor/                # data monitoring
│       └── resources/
│           ├── application.yml             # main config
│           ├── application-dev.yml         # dev config
│           └── db/init.sql                 # DB init
├── geo-saa-frontend/          # frontend service
│   ├── package.json
│   ├── Dockerfile
│   ├── vite.config.js
│   ├── nginx/default.conf        # Nginx deploy config
│   └── src/
│       ├── api/                 # API wrappers
│       ├── views/               # pages
│       │   ├── dashboard/       # dashboard
│       │   ├── diagnose/        # AI brand diagnosis
│       │   ├── knowledge/       # knowledge base
│       │   ├── content/         # AI content creation
│       │   ├── distribute/      # distribution
│       │   ├── monitor/         # monitoring
│       │   └── system/          # settings
│       ├── router/              # routes
│       ├── store/               # state
│       └── components/          # shared components
```

## Feature Modules

### 1. Brand Diagnosis
- Input brand keywords; AI auto-analyzes search-engine performance
- Generates SEO health report and optimization suggestions

### 2. Knowledge Base
- Manage brand info, core keywords, product advantages
- Knowledge version-history tracking

### 3. AI Content Creation
- Multi-industry templates (tech, medical, education, finance, e-commerce, legal)
- Batch-generate AI-optimized articles
- Sensitive-word filtering
- **GEO nine-tactic health check** (`POST /content/geo-validate`): weighted scoring per the Princeton KDD 2024 paper's nine tactics (expert quotes / quantitative data / citations / fluency / technical terms, etc.); **keyword-stuffing auto-block** (paper measured −8%~−10% visibility) returns HTTP 400 on content creation

### 4. Multi-channel Distribution
- 150+ channels supported
- Scheduled-task dispatch
- Progress tracking

### 5. Data Monitoring
- Search ranking monitoring
- Traffic analysis
- Brand-volume trends
- Core metrics include a **data-truth gate**: when `hasData=false`, no random numbers are used to fake data (simulation mode tagged `simulated`; production disables simulation and returns real empties)
- **GEO real-data collector** (configurable Perplexity / OpenAI-compatible gateway, daily auto-collects mentionRate / first-recommendation rate / index count into stats; on failure never writes simulated data)

### 6. Asset Notarization
- Standalone `asset_record` data model (content/knowledge/distribution/diagnosis aggregation + independent dual-view notarization)
- Filter by year/month, paginated browsing of brand assets

### 7. System Management
- User auth & permission management
- AI model config (OpenAI / Qwen / Doubao)
- Simulation mode (experience without an API Key)

## Configuration

### AI model config

In `application.yml`:

```yaml
ai:
  openai:
    api-key: "sk-xxx"
    api-url: https://api.openai.com/v1
    model: gpt-4
  tongyi:
    api-key: "sk-xxx"
  doubao:
    api-key: "sk-xxx"
  simulation:
    enabled: true
```

### Dev mode

- RabbitMQ disabled by default (core features unaffected)
- Default DB credentials: `root` / `root`
- Log level: `com.geosaa: debug`

## FAQ

### Q: Startup error "port 8080 already in use"
A: Under Docker, first ensure the host port is free, or adjust the port mapping in `docker-compose.yml`:
```powershell
netstat -ano | findstr ":8080 "
Stop-Process -Id <PID> -Force
```

### Q: Database connection failed / backend won't start
A: Check container status and logs; ensure dependent services are healthy before backend:
```bash
docker compose ps
docker compose logs -f backend
```
Default DB credentials are `root/root`; change them via `MYSQL_PASSWORD` in `.env`.

### Q: Frontend can't reach backend API
A: Under Docker both are on the same Compose network and the frontend proxies `/api` to the backend via Nginx; if you change ports, update `docker-compose.yml` and `nginx/default.conf` accordingly.

### Q: Don't need RabbitMQ?
A: The `dev` profile disables RabbitMQ; in `docker-compose.yml` that service is optional and not required for core features.

---

## 🤝 Community Support

Stay tuned to Feihongzhi klAI for the latest open-source updates and tutorials.

*Jinjiang Feihongzhi Technology Enterprise Management Co., Ltd. · Feiyang Qiyuan R&D Center · Lead: Wu Cihong*

## Open-Source License

This project is open-sourced under the [MIT License](LICENSE). Contributions via Issues and Pull Requests are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).

---

⭐ If this project helps you, please Star and share!
