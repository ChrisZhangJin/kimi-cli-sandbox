# Kimi CLI Docker (China Optimized)

A Docker setup for running the [Kimi Code CLI](https://www.kimi.com/code) (K2.7+ native binary) with China mirrors and proxy support.

## Features

- ✅ Pre-configured with China mirrors (Tsinghua/USTC)
- ✅ Proxy support via `.env` file
- ✅ No browser authentication needed - just set API key
- ✅ Persist sessions across container restarts

## Quick Start

1. **Clone/copy the files** to your project directory

2. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env and add your KIMI_API_KEY and proxy settings if needed
   ```

3. **Build and run:**
   ```bash
   docker-compose build
   docker-compose run --rm kimi
   ```

## Configuration

### API Key (Required)

Get your API key from [Kimi Code Console](https://www.kimi.com/code/console):

```bash
# .env
KIMI_API_KEY=sk-kimi-your-actual-api-key
```

> **Note:** This setup is configured for **Kimi Code** platform by default (base URL: `https://api.kimi.com/coding/v1`). If you're using Moonshot AI Platform instead, set `KIMI_BASE_URL=https://api.moonshot.cn/v1` in your `.env`.

### Proxy Settings (Optional)

If you're behind a firewall or need proxy, edit `.env`:

```bash
# .env - Basic proxy (use host.docker.internal for Docker Desktop)
HTTP_PROXY=http://host.docker.internal:7890
HTTPS_PROXY=http://host.docker.internal:7890

# .env - With authentication
HTTP_PROXY=http://user:password@proxy.example.com:8080
HTTPS_PROXY=http://user:password@proxy.example.com:8080
```

> **Note:** On macOS/Windows Docker Desktop, use `host.docker.internal` instead of `127.0.0.1` to access host's proxy.

## Usage Examples

### Interactive mode
```bash
docker-compose run --rm kimi
```

### Run a single command
```bash
docker-compose run --rm kimi kimi "Explain this code"
```

### Analyze a file/directory
```bash
# Mount current directory and analyze
docker-compose run --rm kimi kimi "Review the code in /workspace"
```

### Bash shell access
```bash
docker-compose run --rm kimi /bin/bash
```

### Run container in background (for `docker exec`)
```bash
# Start container in background
docker-compose up -d

# Execute into the running container
docker exec -it kimi-sandbox-kimi-1 /bin/bash

# Inside container, you can use kimi directly
kimi

# Stop the container when done
docker-compose down
```

### Using Docker directly (without compose)

If you prefer not to use docker-compose:

```bash
# Build
docker build -t kimi-cli .

# Run with API key only
docker run -it \
  -e KIMI_API_KEY=your_key \
  -v $(pwd):/workspace \
  kimi-cli

# Run with custom base URL (for Moonshot platform)
docker run -it \
  -e KIMI_API_KEY=your_key \
  -e KIMI_BASE_URL=https://api.moonshot.cn/v1 \
  -v $(pwd):/workspace \
  kimi-cli

# Run with proxy
docker run -it \
  -e KIMI_API_KEY=your_key \
  -e HTTP_PROXY=http://host:port \
  -e HTTPS_PROXY=http://host:port \
  -v $(pwd):/workspace \
  kimi-cli kimi "Your prompt here"
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `KIMI_API_KEY` | ✅ Yes | Your Kimi Code API key |
| `KIMI_BASE_URL` | ❌ No | API base URL (default: `https://api.kimi.com/coding/v1`) |
| `HTTP_PROXY` | ❌ No | HTTP proxy URL |
| `HTTPS_PROXY` | ❌ No | HTTPS proxy URL |
| `NO_PROXY` | ❌ No | Comma-separated hosts to bypass proxy |
| `KIMI_MODEL_NAME` | ❌ No | Model alias to use (default: `kimi-for-coding`) |

## China Mirrors Used

- **APT (Debian)**: Tsinghua University Mirror
- **Kimi Code installer**: `code.kimi.com` (Moonshot's own CDN — no GFW hops)

## Troubleshooting

### Build is slow

The Dockerfile uses China mirrors. If still slow, you can build with proxy:

```bash
# Build with proxy (if your build machine needs proxy)
docker build \
  --build-arg HTTP_PROXY=http://host:port \
  --build-arg HTTPS_PROXY=http://host:port \
  -t kimi-cli .
```

### Cannot connect to API inside container

If you get connection errors:

1. Check your API key is correct in `.env`
2. Verify you're using the correct `KIMI_BASE_URL` for your platform:
   - **Kimi Code**: `https://api.kimi.com/coding/v1` (default)
   - **Moonshot AI**: `https://api.moonshot.cn/v1`
3. If using proxy, ensure the proxy address is accessible from Docker container
4. Test connectivity:
   ```bash
   docker-compose run --rm kimi /bin/bash
   # Inside container:
   curl -v $KIMI_BASE_URL/models -H "Authorization: Bearer $KIMI_API_KEY"
   ```

### Permission issues with volumes

If you get permission errors when mounting volumes:

```bash
# Run with user flag (use your host UID/GID)
docker run -it -u $(id -u):$(id -g) -v $(pwd):/workspace kimi-cli
```

## File Structure

```
.
├── Dockerfile          # Image definition with China mirrors
├── docker-compose.yml  # Service configuration with env vars
├── .env.example        # Template for environment variables
├── .dockerignore       # Build context exclusions
└── README.md           # This file
```
