# Dockerfile for Kimi Code CLI (Optimized for China)
# 
# This Dockerfile builds an image with kimi-cli pre-installed.
# You can use it by setting the KIMI_API_KEY environment variable
# without needing to go through the browser authentication flow.
#
# Build:
#   docker build -t kimi-cli .
#
# Run with your API key:
#   docker run -it -e KIMI_API_KEY=your_api_key_here kimi-cli

FROM python:3.12-slim

# ===== China Mirrors Configuration =====
# Use Tsinghua mirror for apt (Debian)
RUN rm -f /etc/apt/sources.list.d/*.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian trixie main contrib non-free" > /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian trixie-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security trixie-security main contrib non-free" >> /etc/apt/sources.list

# Use Tsinghua mirror for PyPI
ENV PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
ENV PIP_TRUSTED_HOST=pypi.tuna.tsinghua.edu.cn

# ===== Install Dependencies =====
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ===== Install kimi-cli =====
RUN pip install --no-cache-dir kimi-cli

# ===== Create Default Config =====
# Create the config directory and a default config file
RUN mkdir -p /root/.kimi && \
    echo 'default_model = "default"' > /root/.kimi/config.toml && \
    echo '' >> /root/.kimi/config.toml && \
    echo '[providers.kimi]' >> /root/.kimi/config.toml && \
    echo 'type = "kimi"' >> /root/.kimi/config.toml && \
    echo 'name = "kimi"' >> /root/.kimi/config.toml && \
    echo 'base_url = "https://api.kimi.com/coding/v1"' >> /root/.kimi/config.toml && \
    echo 'api_key = ""' >> /root/.kimi/config.toml && \
    echo '' >> /root/.kimi/config.toml && \
    echo '[models.default]' >> /root/.kimi/config.toml && \
    echo 'model = "kimi-k2-turbo"' >> /root/.kimi/config.toml && \
    echo 'alias = "default"' >> /root/.kimi/config.toml && \
    echo 'provider = "kimi"' >> /root/.kimi/config.toml && \
    echo 'max_context_size = 128000' >> /root/.kimi/config.toml

# ===== Configuration =====
WORKDIR /workspace

# Disable auto-update check (not needed in container)
ENV KIMI_CLI_NO_AUTO_UPDATE=1

# Default command shows help
CMD ["kimi", "--help"]
