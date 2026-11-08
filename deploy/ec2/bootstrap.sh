#!/usr/bin/env bash
# First-time setup on a fresh Amazon Linux 2023 or Ubuntu EC2 instance.
# Run as a user with sudo, after cloning the repo to e.g. ~/ROUTINGv2.
set -euo pipefail

REPO_DIR="${REPO_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$REPO_DIR"

if command -v dnf &>/dev/null; then
  sudo dnf install -y docker git
  sudo systemctl enable --now docker
elif command -v apt-get &>/dev/null; then
  sudo apt-get update
  sudo apt-get install -y docker.io docker-compose-v2 git
  sudo systemctl enable --now docker
else
  echo "Unsupported OS: install Docker and git manually, then re-run." >&2
  exit 1
fi

if ! groups "$USER" | grep -q docker; then
  sudo usermod -aG docker "$USER"
  echo "Added $USER to docker group. Log out and back in (or newgrp docker), then run deploy/ec2/redeploy.sh"
fi

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env from .env.example — edit GOOGLE_MAPS_API_KEY and ACCESS_CODE before starting."
fi

echo "Bootstrap complete."
echo "  1. Edit .env (ROUTING_DOMAIN, secrets, TRUST_PROXY=true, COOKIE_SECURE=true)"
echo "  2. ./deploy/ec2/redeploy.sh"
echo "  3. sudo ./deploy/ec2/setup-caddy.sh   # HTTPS on 443"
