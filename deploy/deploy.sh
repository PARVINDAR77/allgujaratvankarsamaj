#!/usr/bin/env bash

set -Eeuo pipefail

# =========================================================
# Hostinger Shared Hosting Deployment Script
# =========================================================

# Resolve project root regardless of where script is run from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# ---------------------------------------------------------
# Configuration for Hostinger
# ---------------------------------------------------------
# Hostinger typically uses /home/uXXXXXXX/domains/yourdomain.com/public_html
# Replace these with your actual Hostinger absolute paths!
ADMIN_WEB_ROOT="/home/u796269890/domains/allgujaratvankarsamaj.com/public_html/admin"
APP_WEB_ROOT="/home/u796269890/domains/allgujaratvankarsamaj.com/public_html"

# Lock file placed in project root (shared hosts often restrict /tmp)
LOCK_FILE="$PROJECT_ROOT/deploy.lock"

# ---------------------------------------------------------
# Locking Mechanism
# ---------------------------------------------------------
if [ -f "$LOCK_FILE" ]; then
    LOCK_PID=$(cat "$LOCK_FILE")
    if ps -p "$LOCK_PID" > /dev/null 2>&1; then
        echo "⚠️ Another deployment is currently running (PID: $LOCK_PID)!"
        exit 1
    else
        echo "🧹 Removing stale lock file..."
        rm -f "$LOCK_FILE"
    fi
fi

echo $$ > "$LOCK_FILE"

cleanup() {
    rm -f "$LOCK_FILE"
    rm -f "$PROJECT_ROOT/mysql-backup.cnf"
    echo "🧹 Cleanup complete."
}
trap cleanup EXIT
trap 'echo "❌ Deployment failed at line $LINENO"; exit 1' ERR

echo "=========================================="
echo "🚀 Starting Hostinger Production Deployment"
echo "=========================================="

# ---------------------------------------------------------
# Validations
# ---------------------------------------------------------
echo "🔍 Validating requirements..."

# Removed 'pm2' and 'flutter' from strict requirements.
# On shared hosting, compiling Flutter is often impossible due to lack of Android SDK/memory.
# We highly recommend compiling Flutter LOCALLY and pushing the 'build/web' folder to Git!
REQUIRED_CMDS=("git" "node" "npm" "npx" "mysql" "mysqldump" "curl" "gzip")
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" > /dev/null 2>&1; then
        echo "❌ Required command '$cmd' is not installed in this shared hosting environment."
        exit 1
    fi
done

if [ ! -f ".env.production" ]; then
    echo "❌ Error: .env.production file missing in project root!"
    exit 1
fi

echo "📦 Loading production environment..."
set -a; source .env.production; set +a

if [ -z "${DB_HOST:-}" ] || [ -z "${DB_USER:-}" ] || [ -z "${DB_PASSWORD:-}" ] || [ -z "${DB_NAME:-}" ]; then
    echo "❌ Error: Database credentials must be in .env.production"
    exit 1
fi

# ---------------------------------------------------------
# Database Backup
# ---------------------------------------------------------
DATE=$(date +'%Y-%m-%d_%H-%M-%S')
BACKUP_DIR="$PROJECT_ROOT/deploy/backups"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/db_backup_$DATE.sql.gz"

echo "💾 Backing up Hostinger database before pulling code..."
cat << EOF > "$PROJECT_ROOT/mysql-backup.cnf"
[client]
host=${DB_HOST}
user=${DB_USER}
password="${DB_PASSWORD}"
EOF
chmod 600 "$PROJECT_ROOT/mysql-backup.cnf"

mysqldump --defaults-extra-file="$PROJECT_ROOT/mysql-backup.cnf" "$DB_NAME" | gzip > "$BACKUP_FILE"
rm -f "$PROJECT_ROOT/mysql-backup.cnf"

echo "✅ Backup created at $BACKUP_FILE"

# ---------------------------------------------------------
# Git Sync
# ---------------------------------------------------------
echo "📥 Pulling latest code from git..."
git pull origin main

CURRENT_COMMIT=$(git rev-parse --short HEAD)
echo "📌 Target Commit: $CURRENT_COMMIT"

# ---------------------------------------------------------
# Build & Deploy: NestJS Backend
# ---------------------------------------------------------
echo "⚙️ Building NestJS Backend..."
cd "$PROJECT_ROOT/next-nest/backend"

# On shared hosting, memory is limited. If 'npm ci' crashes, try 'npm install --production'
npm ci
npx prisma generate

echo "🗄️ Running Database Migrations..."
npx prisma migrate deploy
npm run build
cd "$PROJECT_ROOT"

# ---------------------------------------------------------
# Next.js Admin (Pre-built)
# ---------------------------------------------------------
echo "🖥️ Using pre-built Next.js Admin Panel (built locally)..."
# Hostinger shared hosting kills the Next.js build worker due to process limits.
# Build Next.js locally with 'npm run build' and push the 'out/' folder to Git.
if [ ! -d "$PROJECT_ROOT/next-nest/frontend/out" ]; then
    echo "❌ ERROR: next-nest/frontend/out/ not found!"
    echo "⚠️ Build Next.js locally and push the 'out/' folder to Git first:"
    echo "   cd next-nest/frontend && npm run build && git add out && git commit && git push"
    exit 1
fi
echo "✅ Found pre-built Next.js output."
cd "$PROJECT_ROOT"

# ---------------------------------------------------------
# Build: Flutter Web (WARNING)
# ---------------------------------------------------------
echo "📱 Preparing Flutter Web Application..."
# We skip 'flutter build web' because Hostinger Business does not support the Flutter SDK.
# The script assumes you ran 'flutter build web' LOCALLY and pushed the 'application/build/web' folder to Git.
if [ ! -d "$PROJECT_ROOT/application/build/web" ]; then
    echo "❌ Error: application/build/web directory not found!"
    echo "⚠️ You must build Flutter locally and push the build/web folder to Git when using shared hosting."
    exit 1
fi

# ---------------------------------------------------------
# Pre-rollback Snapshot (App State)
# ---------------------------------------------------------
echo "📸 Preparing rollback artifacts..."
PREV_ADMIN_DIR="${ADMIN_WEB_ROOT}_prev"
PREV_APP_DIR="${APP_WEB_ROOT}_prev"

[ -d "$ADMIN_WEB_ROOT" ] && cp -r "$ADMIN_WEB_ROOT" "$PREV_ADMIN_DIR"
[ -d "$APP_WEB_ROOT" ] && cp -r "$APP_WEB_ROOT" "$PREV_APP_DIR"

# ---------------------------------------------------------
# Atomic Replacements & Reloads
# ---------------------------------------------------------
echo "🔄 Executing atomic deployments..."

# 1. NestJS (Hostinger Passenger Restart)
# Hostinger Node.js apps are restarted by touching the tmp/restart.txt file in the app directory.
# Adjust the path to wherever your Hostinger Node.js App is configured to run from.
mkdir -p "$PROJECT_ROOT/next-nest/backend/tmp"
touch "$PROJECT_ROOT/next-nest/backend/tmp/restart.txt"

# 2. Next.js Admin (Atomic MV)
mkdir -p "$(dirname "$ADMIN_WEB_ROOT")"
rm -rf "${ADMIN_WEB_ROOT}_tmp"
cp -r "$PROJECT_ROOT/next-nest/frontend/out" "${ADMIN_WEB_ROOT}_tmp"
mv "${ADMIN_WEB_ROOT}" "${ADMIN_WEB_ROOT}_old" 2>/dev/null || true
mv "${ADMIN_WEB_ROOT}_tmp" "${ADMIN_WEB_ROOT}"
rm -rf "${ADMIN_WEB_ROOT}_old"

# 3. Flutter App (Atomic MV)
mkdir -p "$(dirname "$APP_WEB_ROOT")"
rm -rf "${APP_WEB_ROOT}_tmp"
cp -r "$PROJECT_ROOT/application/build/web" "${APP_WEB_ROOT}_tmp"
mv "${APP_WEB_ROOT}" "${APP_WEB_ROOT}_old" 2>/dev/null || true
mv "${APP_WEB_ROOT}_tmp" "${APP_WEB_ROOT}"
rm -rf "${APP_WEB_ROOT}_old"

# ---------------------------------------------------------
# Health Checks with Retry
# ---------------------------------------------------------
echo "🩺 Running Health Checks..."

# Give Hostinger Passenger time to spin up the Node app
sleep 5 

check_health() {
    local url=$1
    local retries=5
    local wait=3
    while [ $retries -gt 0 ]; do
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        if [ "$HTTP_CODE" = "200" ]; then
            return 0
        fi
        sleep $wait
        retries=$((retries - 1))
    done
    return 1
}

HEALTH_FAIL=0

# Hostinger apps are exposed on public URLs. Update this to your actual API domain!
API_DOMAIN="https://allgujaratvankarsamaj.com/api/v1"

if ! check_health "$API_DOMAIN/health"; then
    echo "❌ Backend health check failed!"
    HEALTH_FAIL=1
fi

if ! check_health "$API_DOMAIN/advertisements"; then
    echo "❌ Public Advertisements API check failed!"
    HEALTH_FAIL=1
fi

# ---------------------------------------------------------
# Rollback Logic
# ---------------------------------------------------------
if [ $HEALTH_FAIL -eq 1 ]; then
    echo "🚨 Health checks failed. Initiating application rollback..."
    
    if [ -d "$PREV_ADMIN_DIR" ]; then
        rm -rf "$ADMIN_WEB_ROOT"
        mv "$PREV_ADMIN_DIR" "$ADMIN_WEB_ROOT"
        echo "⏪ Admin Panel static assets rolled back."
    fi
    
    if [ -d "$PREV_APP_DIR" ]; then
        rm -rf "$APP_WEB_ROOT"
        mv "$PREV_APP_DIR" "$APP_WEB_ROOT"
        echo "⏪ Flutter Web static assets rolled back."
    fi

    # Trigger restart again to load the old backend if Node was reverted
    touch "$PROJECT_ROOT/next-nest/backend/tmp/restart.txt"

    echo "⚠️ Backend automatic rollback requires manual verification."
    echo "⚠️ Please check Hostinger Node.js error logs and restore manually using backup: $BACKUP_FILE"
    exit 1
fi

rm -rf "$PREV_ADMIN_DIR" "$PREV_APP_DIR"

echo "=========================================="
echo "✅ DEPLOYMENT SUCCESSFUL!"
echo "Date: $(date)"
echo "Target Commit: $CURRENT_COMMIT"
echo "=========================================="
