#!/bin/bash
# scripts/deploy.sh

set -e

APP_DIR="/var/www/my-node-app"
DEPLOY_DIR="/home/$(whoami)/deployments"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "[DEPLOY] Starting deployment at $TIMESTAMP"

# 1. Ensure app directory exists
mkdir -p $APP_DIR

# 2. Backup current version
if [ -d "$APP_DIR/current" ]; then
  echo "[DEPLOY] Backing up current version..."
  cp -r $APP_DIR/current $APP_DIR/backup_$TIMESTAMP
fi

# 3. Extract new build
echo "[DEPLOY] Extracting deployment package..."
rm -rf $APP_DIR/current
mkdir -p $APP_DIR/current
tar -xzf $DEPLOY_DIR/deployment.tar.gz -C $APP_DIR/current

# 4. Install dependencies
echo "[DEPLOY] Installing production dependencies..."
cd $APP_DIR/current
npm install --omit=dev

# 5. Set environment variables (runtime only)
export NODE_ENV=production
export PORT=3000
export DEPLOYED_AT=$TIMESTAMP

# 6. Restart app using PM2 (safe restart)
echo "[DEPLOY] Restarting application with PM2..."
pm2 describe my-node-app > /dev/null

if [ $? -ne 0 ]; then
  echo "[DEPLOY] Starting app..."
  pm2 start ecosystem.config.js --env production
else
  echo "[DEPLOY] Restarting app..."
  pm2 restart my-node-app
fi

pm2 save

# 7. Clean old backups (keep last 3)
echo "[DEPLOY] Cleaning old backups..."
cd $APP_DIR
ls -dt backup_* 2>/dev/null | tail -n +4 | xargs rm -rf || true

echo "[DEPLOY] Deployment complete! App is live."
