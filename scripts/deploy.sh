#!/bin/bash
# scripts/deploy.sh

set -e

APP_NAME="my-node-app"
APP_DIR="/var/www/my-node-app"
DEPLOY_DIR="/home/$(whoami)/deployments"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "[DEPLOY] Starting deployment at $TIMESTAMP"

# 1. Ensure directories exist
mkdir -p "$APP_DIR"
mkdir -p "$DEPLOY_DIR"

# 2. Check deployment package
if [ ! -f "$DEPLOY_DIR/deployment.tar.gz" ]; then
  echo "[ERROR] deployment.tar.gz not found in $DEPLOY_DIR"
  exit 1
fi

# 3. Backup current version
if [ -d "$APP_DIR/current" ]; then
  echo "[DEPLOY] Backing up current version..."
  cp -r "$APP_DIR/current" "$APP_DIR/backup_$TIMESTAMP"
fi

# 4. Extract new build
echo "[DEPLOY] Extracting deployment package..."
rm -rf "$APP_DIR/current"
mkdir -p "$APP_DIR/current"
tar -xzf "$DEPLOY_DIR/deployment.tar.gz" -C "$APP_DIR/current"

# 5. Install dependencies
echo "[DEPLOY] Installing production dependencies..."
cd "$APP_DIR/current"
npm install --omit=dev

# 6. Runtime environment variables
export NODE_ENV=production
export PORT=3000
export DEPLOYED_AT="$TIMESTAMP"
export APP_VERSION="1.0.0"

# DB ENV - GitHub Actions SSH script should pass these values
export DB_HOST="${DB_HOST}"
export DB_USER="${DB_USER}"
export DB_PASSWORD="${DB_PASSWORD}"
export DB_NAME="${DB_NAME}"

# 7. Validate DB variables
if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_NAME" ]; then
  echo "[ERROR] DB environment variables missing"
  echo "Required: DB_HOST, DB_USER, DB_PASSWORD, DB_NAME"
  exit 1
fi

# 8. Restart app using PM2 safely
echo "[DEPLOY] Restarting application with PM2..."

pm2 describe "$APP_NAME" > /dev/null

if [ $? -ne 0 ]; then
  echo "[DEPLOY] Starting app..."
  pm2 start ecosystem.config.js --env production
else
  echo "[DEPLOY] Restarting app..."
  pm2 restart "$APP_NAME" --update-env
fi

pm2 save

# 9. Clean old backups - keep last 3
echo "[DEPLOY] Cleaning old backups..."
cd "$APP_DIR"
ls -dt backup_* 2>/dev/null | tail -n +4 | xargs rm -rf || true

echo "[DEPLOY] Deployment complete! App is live."
