#!/bin/bash

set -e

echo "[DB-SETUP] Starting database setup..."

# Variables
DB_NAME="myapp_db"
DB_USER="appuser"
DB_PASS="StrongPassword123"

# Install MySQL if not installed
if ! command -v mysql &> /dev/null
then
  echo "[DB-SETUP] Installing MySQL..."
  sudo apt update
  sudo apt install -y mysql-server
fi

# Start MySQL
sudo systemctl enable mysql
sudo systemctl start mysql

# Configure MySQL (remote access)
echo "[DB-SETUP] Configuring MySQL for remote access..."
sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

sudo systemctl restart mysql

# Create DB and user
echo "[DB-SETUP] Creating database and user..."

sudo mysql <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "[DB-SETUP] Database setup completed!"

