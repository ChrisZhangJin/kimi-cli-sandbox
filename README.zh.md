# Kimi CLI Docker（中国镜像优化版）

一个用于运行 [Kimi Code CLI](https://github.com/MoonshotAI/kimi-cli) 的 Docker 配置，预配置了中国镜像源并支持代理设置。

## 特性

- ✅ 预配置中国镜像源（清华/中科大）
- ✅ 通过 `.env` 文件支持代理设置
- ✅ 无需浏览器认证，只需设置 API 密钥即可使用
- ✅ 支持在容器重启后保持会话

## 快速开始

1. **克隆/复制文件** 到你的项目目录

2. **配置环境：**
   ```bash
   cp .env.example .env
   # 编辑 .env 文件，添加你的 KIMI_API_KEY 和代理设置（如需要）
   ```

3. **构建并运行：**
   ```bash
   docker-compose build
   docker-compose run --rm kimi
   ```

## 配置说明

### API 密钥（必需）

从 [Kimi Code 控制台](https://www.kimi.com/code/console) 获取你的 API 密钥：

```bash
# .env
KIMI_API_KEY=sk-kimi-your-actual-api-key
```

> **注意：** 本配置默认使用 **Kimi Code** 平台（基础 URL：`https://api.kimi.com/coding/v1`）。如果你使用的是 Moonshot AI 平台，请在 `.env` 中设置 `KIMI_BASE_URL=https://api.moonshot.cn/v1`。

### 代理设置（可选）

如果你位于防火墙后或需要使用代理，编辑 `.env`：

```bash
# .env - 基础代理（Docker Desktop 使用 host.docker.internal）
HTTP_PROXY=http://host.docker.internal:7890
HTTPS_PROXY=http://host.docker.internal:7890

# .env - 带身份验证的代理
HTTP_PROXY=http://user:password@proxy.example.com:8080
HTTPS_PROXY=http://user:password@proxy.example.com:8080
```

> **注意：** 在 macOS/Windows Docker Desktop 上，使用 `host.docker.internal` 代替 `127.0.0.1` 来访问主机的代理。

## 使用示例

### 交互模式
```bash
docker-compose run --rm kimi
```

### 运行单条命令
```bash
docker-compose run --rm kimi kimi "解释一下这段代码"
```

### 分析文件/目录
```bash
# 挂载当前目录并分析
docker-compose run --rm kimi kimi "查看 /workspace 中的代码"
```

### 进入 Bash shell
```bash
docker-compose run --rm kimi /bin/bash
```

### 后台运行容器（用于 `docker exec`）
```bash
# 在后台启动容器
docker-compose up -d

# 进入运行中的容器
docker exec -it kimi-sandbox-kimi-1 /bin/bash

# 在容器内可以直接使用 kimi
kimi

# 使用完毕后停止容器
docker-compose down
```

### 直接使用 Docker（不使用 docker-compose）

如果你不想使用 docker-compose：

```bash
# 构建镜像
docker build -t kimi-cli .

# 仅使用 API 密钥运行
docker run -it \
  -e KIMI_API_KEY=your_key \
  -v $(pwd):/workspace \
  kimi-cli

# 使用自定义基础 URL 运行（适用于 Moonshot 平台）
docker run -it \
  -e KIMI_API_KEY=your_key \
  -e KIMI_BASE_URL=https://api.moonshot.cn/v1 \
  -v $(pwd):/workspace \
  kimi-cli

# 使用代理运行
docker run -it \
  -e KIMI_API_KEY=your_key \
  -e HTTP_PROXY=http://host:port \
  -e HTTPS_PROXY=http://host:port \
  -v $(pwd):/workspace \
  kimi-cli kimi "你的提示词"
```

## 环境变量

| 变量 | 必需 | 说明 |
|------|------|------|
| `KIMI_API_KEY` | ✅ 是 | 你的 Kimi Code API 密钥 |
| `KIMI_BASE_URL` | ❌ 否 | API 基础 URL（默认：`https://api.kimi.com/coding/v1`） |
| `HTTP_PROXY` | ❌ 否 | HTTP 代理 URL |
| `HTTPS_PROXY` | ❌ 否 | HTTPS 代理 URL |
| `NO_PROXY` | ❌ 否 | 绕过代理的主机列表，逗号分隔 |
| `KIMI_MODEL_NAME` | ❌ 否 | 使用的模型（默认：`kimi-k2-turbo`） |

## 使用的中国镜像

- **APT (Debian)**：清华大学镜像
- **PyPI**：清华大学镜像
- **GitHub (uv 安装器)**：中科大镜像

## 故障排除

### 构建速度慢

Dockerfile 已使用中国镜像。如果仍然慢，可以在构建时使用代理：

```bash
# 构建时使用代理（如果构建机器需要代理）
docker build \
  --build-arg HTTP_PROXY=http://host:port \
  --build-arg HTTPS_PROXY=http://host:port \
  -t kimi-cli .
```

### 无法连接到容器内的 API

如果遇到连接错误：

1. 检查 `.env` 中的 API 密钥是否正确
2. 确认你使用了正确的 `KIMI_BASE_URL`：
   - **Kimi Code**：`https://api.kimi.com/coding/v1`（默认）
   - **Moonshot AI**：`https://api.moonshot.cn/v1`
3. 如果使用代理，确保代理地址可以从 Docker 容器访问
4. 测试连接：
   ```bash
   docker-compose run --rm kimi /bin/bash
   # 在容器内：
   curl -v $KIMI_BASE_URL/models -H "Authorization: Bearer $KIMI_API_KEY"
   ```

### 卷权限问题

如果挂载卷时遇到权限错误：

```bash
# 使用用户标志运行（使用主机的 UID/GID）
docker run -it -u $(id -u):$(id -g) -v $(pwd):/workspace kimi-cli
```

## 文件结构

```
.
├── Dockerfile          # 镜像定义，包含中国镜像配置
├── docker-compose.yml  # 服务配置，包含环境变量
├── .env.example        # 环境变量模板
├── .dockerignore       # 构建上下文排除项
├── README.md           # 英文文档
└── README.zh.md        # 中文文档（本文件）
```

## 许可证

MIT
