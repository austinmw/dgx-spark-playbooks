#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

cleanup() {
  echo "Stopping gemma4-chat stack..."
  docker compose down >/dev/null 2>&1 || true
  exit 0
}

trap cleanup INT TERM HUP QUIT EXIT

if [ ! -f .env ]; then
  echo "Missing ${SCRIPT_DIR}/.env. Copy .env.example to .env and fill in the secrets first." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon not reachable." >&2
  exit 1
fi

docker compose up -d

echo "gemma4-chat is running. Keep this process alive for NVIDIA Sync."
while :; do
  sleep 86400
done
