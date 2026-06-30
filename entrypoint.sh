#!/usr/bin/env bash
# Materialize ~/.kimi-code/config.toml from env vars on first run.
# Kept out of the image so the API key never lands in a Docker layer.
set -euo pipefail

CONFIG_DIR="${HOME}/.kimi-code"
CONFIG_FILE="${CONFIG_DIR}/config.toml"

if [[ ! -f "$CONFIG_FILE" && -n "${KIMI_API_KEY:-}" ]]; then
  mkdir -p "$CONFIG_DIR"
  cat > "$CONFIG_FILE" <<EOF
default_model = "default"

[providers.kimi]
type = "kimi"
name = "kimi"
base_url = "${KIMI_BASE_URL:-https://api.kimi.com/coding/v1}"
api_key = "${KIMI_API_KEY}"

[models.default]
model = "${KIMI_MODEL_NAME:-kimi-for-coding}"
alias = "default"
provider = "kimi"
max_context_size = 128000
EOF
  chmod 600 "$CONFIG_FILE"
fi

exec "$@"
