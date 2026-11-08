#!/usr/bin/env bash
# Install Caddy and install site config from ROUTING_DOMAIN in .env (HTTPS on 443).
set -euo pipefail

REPO_DIR="${REPO_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$REPO_DIR"

if [[ ! -f .env ]]; then
  echo "Missing .env — set ROUTING_DOMAIN before setup-caddy.sh" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

if [[ -z "${ROUTING_DOMAIN:-}" ]]; then
  echo "Set ROUTING_DOMAIN in .env (DNS A record must point at this instance)" >&2
  exit 1
fi

if ! command -v envsubst &>/dev/null; then
  if command -v apt-get &>/dev/null; then
    sudo apt-get install -y gettext-base
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y gettext
  fi
fi

install_caddy_dnf() {
  sudo dnf install -y dnf-plugins-core curl
  if [[ ! -f /etc/yum.repos.d/caddy-stable.repo ]]; then
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/pki/rpm-gpg/RPM-GPG-KEY-caddy-stable >/dev/null
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/rpm/caddy-stable.repo' | sudo tee /etc/yum.repos.d/caddy-stable.repo
  fi
  sudo dnf install -y caddy
}

install_caddy_apt() {
  sudo apt-get update
  sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
  sudo apt-get update
  sudo apt-get install -y caddy
}

if ! command -v caddy &>/dev/null; then
  if command -v dnf &>/dev/null; then
    install_caddy_dnf
  elif command -v apt-get &>/dev/null; then
    install_caddy_apt
  else
    echo "Install Caddy manually: https://caddyserver.com/docs/install" >&2
    exit 1
  fi
fi

sudo mkdir -p /etc/caddy

TEMP=$(mktemp)
export ROUTING_DOMAIN
envsubst '$ROUTING_DOMAIN' < "$REPO_DIR/deploy/ec2/Caddyfile.template" > "$TEMP"
sudo cp "$TEMP" /etc/caddy/Caddyfile
rm -f "$TEMP"

sudo systemctl enable caddy
sudo systemctl reload caddy 2>/dev/null || sudo systemctl restart caddy

echo "Caddy serving https://${ROUTING_DOMAIN} -> 127.0.0.1:3000"
echo "Security group should allow 80/443 only (not public 3000)."
