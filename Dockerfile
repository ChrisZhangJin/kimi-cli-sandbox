# Dockerfile for Kimi Code CLI (Optimized for China)
#
# Builds an image with the official Kimi Code CLI (K2.7+ native binary).
# Configure via env vars at runtime — no config file needed.
#
# Build:
#   docker build -t kimi-sandbox:0.2.0 .
#
# Run with your API key:
#   docker run -it -e KIMI_API_KEY=your_api_key_here kimi-sandbox:0.2.0

FROM debian:trixie-slim

# ===== China Mirrors Configuration =====
# Tsinghua mirror for apt (Debian trixie)
RUN rm -f /etc/apt/sources.list.d/*.list /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian trixie main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian trixie-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security trixie-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list

# ===== Install Dependencies =====
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ===== Install Kimi Code CLI =====
# Native binary installer treats KIMI_INSTALL_DIR as a --prefix root and writes
# the binary to ${KIMI_INSTALL_DIR}/bin/kimi. Setting it to /usr/local lands the
# binary at /usr/local/bin/kimi, which is already on PATH.
ENV KIMI_INSTALL_DIR=/usr/local \
    KIMI_NO_MODIFY_PATH=1
RUN curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash

# ===== Entrypoint =====
# Generates ~/.kimi-code/config.toml from env vars on container start so the
# API key never lands in an image layer. Old config.toml on the host wins.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ===== Configuration =====
WORKDIR /workspace

# Disable auto-update check (not needed in container)
ENV KIMI_CLI_NO_AUTO_UPDATE=1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# Default command shows help
CMD ["kimi", "--help"]
