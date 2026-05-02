#!/bin/bash
# scripts/deploy.sh
# This script runs ON EC2 — triggered remotely by GitHub Actions via SSH
# NO build commands here — only extract + restart
 
APP_DIR="/var/www/my-node-app"
DEPLOY_DIR="/home/$(whoami)/deployments"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
 
echo "[DEPLOY] Starting deployment at $TIMESTAMP"
 
# 1. Ensure app directory exists
mkdir -p $APP_DIR
 
# 2. Backup current version (optional but recommended)
if [ -d "$APP_DIR/current" ]; then
  echo "[DEPLOY] Backing up current version..."
  cp -r $APP_DIR/current $APP_DIR/backup_$TIMESTAMP
fi
 
# 3. Extract the new deployment archive
echo "[DEPLOY] Extracting deployment package..."
mkdir -p $APP_DIR/current
tar -xzf $DEPLOY_DIR/deployment.tar.gz -C $APP_DIR/current
 
# 4. Install ONLY production dependencies on EC2
#    (no build step — just runtime deps)
echo "[DEPLOY] Installing production dependencies..."
cd $APP_DIR/current
npm install --omit=dev
 
# 5. Set environment variables
export NODE_ENV=production
export PORT=3000
export DEPLOYED_AT=$TIMESTAMP

# 🔥 DB CONNECTION (FINAL)
export DB_HOST="DB_EC2_PRIVATE_IP"
export DB_USER="appuser"
export DB_PASS="StrongPassword123"
export DB_NAME="myapp_db"
 
# 6. Restart app using PM2
echo "[DEPLOY] Restarting application with PM2..."
pm2 delete my-node-app 2>/dev/null || true
pm2 start ecosystem.config.js --env production
pm2 save
 
# 7. Clean up old backups (keep last 3)
echo "[DEPLOY] Cleaning old backups..."
cd $APP_DIR
ls -dt backup_* 2>/dev/null | tail -n +4 | xargs rm -rf
 
echo "[DEPLOY] Deployment complete! App is live."



