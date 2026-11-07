# AWS EC2 + Docker hosting (PoC)

Run the **full app** (UI + API) on one EC2 instance. Data (CSV, routes) stays **in memory** until the container restarts.

## 1. Create EC2

| Setting | Suggestion |
|---------|----------------|
| AMI | Amazon Linux 2023 or Ubuntu 22.04 |
| Instance type | `t3.small` |
| Storage | 20 GB gp3 |
| Elastic IP | Attach for a stable URL |
| Security group | TCP **3000** (app) from your team; **22** SSH from your IP only |

Optional HTTPS: open **80** and **443**, run Caddy on the host using [ec2/Caddyfile.example](ec2/Caddyfile.example), set in `.env`: `TRUST_PROXY=true`, `COOKIE_SECURE=true`.

## 2. Install on the instance

```bash
git clone https://github.com/<org>/ROUTINGv2.git
cd ROUTINGv2
cp .env.example .env
# Edit .env — see below
chmod +x deploy/ec2/*.sh
./deploy/ec2/bootstrap.sh
# Log out/in if bootstrap added you to the docker group
./deploy/ec2/redeploy.sh
```

## 3. Environment (`.env` on the server)

```bash
GOOGLE_MAPS_API_KEY=...        # Geocoding, Distance Matrix, Directions
ACCESS_CODE=...                # Team secret for the share link
NODE_ENV=production
PORT=3000
HOST_PORT=3000                 # Host port published by docker compose

# HTTP PoC on Elastic IP (no TLS):
COOKIE_SECURE=false

# Behind Caddy/nginx with HTTPS:
# TRUST_PROXY=true
# COOKIE_SECURE=true
```

**Share link:** `http(s)://<your-elastic-ip-or-domain>/?code=<ACCESS_CODE>`

Health check (no access code): `GET /api/health`

## 4. GitHub Actions deploy

After EC2 is set up, add **repository secrets** (Settings → Secrets and variables → Actions):

| Secret | Example |
|--------|---------|
| `EC2_HOST` | Elastic IP or DNS name |
| `EC2_USER` | `ec2-user` (Amazon Linux) or `ubuntu` |
| `EC2_SSH_PRIVATE_KEY` | Contents of your `.pem` key |

Optional **variable** `EC2_APP_DIR` — absolute path to the repo on the server (default: `$HOME/ROUTINGv2` on the deploy user).

Pushes to `main` and **workflow_dispatch** run [deploy-aws-ec2.yml](../.github/workflows/deploy-aws-ec2.yml), which SSHs in and runs `deploy/ec2/redeploy.sh`. Until secrets exist, the workflow job is skipped automatically.

You do **not** need long-lived AWS access keys in GitHub for this SSH-based deploy.

## 5. Local Docker test

```bash
cp .env.example .env
# Set ACCESS_CODE for local gate testing
docker compose up --build
```

Open `http://localhost:3000/?code=<ACCESS_CODE>`.

## AWS containers (reference)

Images are standard **Docker/OCI**. **Amazon ECR** is AWS’s registry; this PoC builds on the EC2 host via `docker compose build`. A later upgrade can push from GitHub Actions to ECR and pull on the instance.
