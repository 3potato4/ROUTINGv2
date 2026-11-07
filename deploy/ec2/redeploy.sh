#!/usr/bin/env bash
# Pull latest main and restart the Docker container (run on EC2 after git remote is configured).
set -euo pipefail

REPO_DIR="${REPO_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
BRANCH="${DEPLOY_BRANCH:-main}"

cd "$REPO_DIR"

if [[ -d .git ]]; then
  git fetch origin "$BRANCH"
  git checkout "$BRANCH"
  git pull origin "$BRANCH"
fi

if [[ ! -f .env ]]; then
  echo "Missing .env — copy .env.example to .env and set secrets." >&2
  exit 1
fi

docker compose build --pull
docker compose up -d --remove-orphans
docker compose ps

HOST_PORT="${HOST_PORT:-3000}"
echo "App should be on port ${HOST_PORT} — check: curl -sS http://127.0.0.1:${HOST_PORT}/api/health"
