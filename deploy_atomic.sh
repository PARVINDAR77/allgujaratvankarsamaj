#!/usr/bin/env bash
# ==============================================================================
# All Gujarat Vankar Samaj - Atomic Production Deployment & Rollback Engine
# Features:
# 1. Pre-deployment verified DB snapshot (gzip -t)
# 2. Atomic Directory Swap with emergency signal trap recovery
# 3. Controlled Migration Application with non-destructive verification
# 4. Zero-DB Liveness Probe verification over Unix domain socket
# 5. Automated Rollback on post-deployment health check failure
# ==============================================================================

set -Eeuo pipefail

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null || true
export PATH="$HOME/.nvm/versions/node/v20.20.2/bin:$HOME/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
cd "$PROJECT_ROOT"

BACKEND_DIR="$PROJECT_ROOT/next-nest/backend"
SOCKET_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock"
PUBLIC_HTML="/home/u796269890/domains/allgujaratvankarsamaj.com/public_html"
LOCK_FILE="$PROJECT_ROOT/deploy_atomic.lock"
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
PID=$$

STAGING_DIR="$BACKEND_DIR/dist_staging_$TIMESTAMP"
BACKUP_DIST="$BACKEND_DIR/dist_backup_$TIMESTAMP"
FAILED_DIST="$BACKEND_DIR/dist_failed_$TIMESTAMP"

echo "================================================================="
echo "  All Gujarat Vankar Samaj - Atomic Deployment ($TIMESTAMP)     "
echo "================================================================="

# 1. Single-Instance Deployment Lock
if [ -f "$LOCK_FILE" ]; then
    OLD_PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
    if [ -n "$OLD_PID" ] && ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "❌ Error: Another deployment is currently in progress (PID: $OLD_PID)!"
        exit 1
    else
        rm -f "$LOCK_FILE"
    fi
fi
echo "$PID" > "$LOCK_FILE"

# Comprehensive signal trap with emergency directory restoration
cleanup() {
    local exit_code=$?
    rm -f "$LOCK_FILE"
    rm -f "$PROJECT_ROOT/mysql-backup.cnf"
    if [ -n "${STAGING_DIR:-}" ] && [ -d "$STAGING_DIR" ]; then
        rm -rf "$STAGING_DIR"
    fi
    # Emergency restoration: if live dist is missing but backup exists, restore it!
    if [ ! -d "$BACKEND_DIR/dist" ] && [ -n "${BACKUP_DIST:-}" ] && [ -d "$BACKUP_DIST" ]; then
        echo "🚨 Emergency restoration: Restoring live dist from backup..."
        mv "$BACKUP_DIST" "$BACKEND_DIR/dist" 2>/dev/null || true
    fi
    exit "$exit_code"
}
trap cleanup EXIT INT TERM HUP

# 2. Validate Paths & Environment
if [ ! -d "$BACKEND_DIR" ]; then
    echo "❌ Error: Backend directory does not exist at $BACKEND_DIR"
    exit 1
fi

if [ ! -f ".env.production" ]; then
    echo "❌ Error: .env.production file is missing in $PROJECT_ROOT"
    exit 1
fi

set -a
source .env.production
set +a

if [ -z "${DB_HOST:-}" ] || [ -z "${DB_USER:-}" ] || [ -z "${DB_PASSWORD:-}" ] || [ -z "${DB_NAME:-}" ]; then
    echo "❌ Error: Database credentials missing in .env.production"
    exit 1
fi

# 3. Stage 1: Verified Pre-Deployment Database Snapshot
BACKUP_DIR="$PROJECT_ROOT/deploy/backups"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/db_backup_$TIMESTAMP.sql.gz"

echo "📦 Creating verified database backup..."
cat << EOF > "$PROJECT_ROOT/mysql-backup.cnf"
[client]
host=${DB_HOST}
user=${DB_USER}
password="${DB_PASSWORD}"
EOF
chmod 600 "$PROJECT_ROOT/mysql-backup.cnf"

mysqldump --defaults-extra-file="$PROJECT_ROOT/mysql-backup.cnf" --single-transaction --quick --skip-lock-tables "$DB_NAME" | gzip > "$BACKUP_FILE"
rm -f "$PROJECT_ROOT/mysql-backup.cnf"

if ! gzip -t "$BACKUP_FILE" > /dev/null 2>&1; then
    echo "❌ Critical Error: Database backup failed verification (corrupt gzip archive)!"
    exit 1
fi
echo "✅ Database backup verified ($BACKUP_FILE)"

# 4. Stage 2: Staged Backend Directory Preparation
echo "⚙️ Preparing staged backend distribution..."
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
cp -rf "$BACKEND_DIR/dist"/* "$STAGING_DIR/"

# Integrity check on staging directory
if [ ! -f "$STAGING_DIR/main.js" ] || [ ! -f "$STAGING_DIR/app.module.js" ]; then
    echo "❌ Error: Staged build integrity check failed (missing main.js or app.module.js)!"
    rm -rf "$STAGING_DIR"
    exit 1
fi
echo "✅ Staged backend distribution verified."

# 5. Stage 3: Database Migration Verification (if --apply-indexes passed)
APPLY_INDEXES="${1:-}"
if [ "$APPLY_INDEXES" = "--apply-indexes" ]; then
    MIGRATION_SQL="$BACKEND_DIR/prisma/migrations/20261030100000_performance_and_search_indexes/migration.sql"
    if [ -f "$MIGRATION_SQL" ]; then
        echo "🗄️ Applying Step 5 query-driven performance indexes..."
        mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$MIGRATION_SQL"
        echo "✅ Performance indexes applied successfully."
        
        # Verify index presence in information_schema
        echo "🔍 Verifying index registration in information_schema..."
        INDEX_COUNT=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -N -e "
            SELECT COUNT(DISTINCT index_name) FROM information_schema.statistics 
            WHERE table_schema = '$DB_NAME' 
            AND index_name IN (
                'idx_matrimonial_profiles_search_composite',
                'idx_matrimonial_profiles_district_taluka',
                'idx_matrimonial_profiles_date_of_birth',
                'idx_verification_requests_profile_created',
                'idx_verification_requests_status_created',
                'idx_match_interests_receiver_created',
                'idx_match_interests_sender_created',
                'idx_govt_emp_active_status_created',
                'idx_govt_emp_featured_active_updated',
                'idx_govt_emp_employment_type'
            );
        ")
        echo "Registered performance indexes found: $INDEX_COUNT / 10"
    fi
else
    echo "ℹ️ Database migration skipped (pass --apply-indexes to execute)."
fi

# 6. Stage 4: Synchronize Hardened Reverse Proxy & Web Assets
echo "🌐 Updating reverse proxy and maintenance dashboard..."
if [ -d "$PUBLIC_HTML" ]; then
    cp -f "$PROJECT_ROOT/application/build/web/api_proxy.php" "$PUBLIC_HTML/api_proxy.php"
    cp -f "$PROJECT_ROOT/application/build/web/restart_backend.php" "$PUBLIC_HTML/restart_backend.php"
    chmod 644 "$PUBLIC_HTML/api_proxy.php" "$PUBLIC_HTML/restart_backend.php"
fi

# 7. Stage 5: Atomic Directory Swap
echo "🔄 Executing atomic directory swap for backend..."
if [ -d "$BACKEND_DIR/dist" ]; then
    mv "$BACKEND_DIR/dist" "$BACKUP_DIST" && mv "$STAGING_DIR" "$BACKEND_DIR/dist"
else
    mv "$STAGING_DIR" "$BACKEND_DIR/dist"
fi

# 8. Stage 6: Controlled Backend Restart & Liveness Probe
echo "🚀 Restarting backend via watchdog supervisor..."
touch "/home/u796269890/domains/allgujaratvankarsamaj.com/restart_trigger.txt"
bash "$PROJECT_ROOT/keep_backend_alive.sh" --force

echo "🔍 Verifying backend zero-DB liveness probe..."
IS_UP=0
for i in {1..15}; do
    sleep 1
    RESP=$(curl -s --max-time 2 --unix-socket "$SOCKET_FILE" "http://localhost/api/v1/health/liveness" 2>/dev/null || echo "")
    if echo "$RESP" | grep -q '"status"' && echo "$RESP" | grep -q '"ok"'; then
        IS_UP=1
        break
    fi
    echo "Waiting for backend liveness probe (attempt $i/15)..."
done

if [ "$IS_UP" -eq 1 ]; then
    echo "================================================================="
    echo "✅ DEPLOYMENT SUCCEEDED: Backend is healthy and serving requests!"
    echo "================================================================="
    rm -rf "$BACKUP_DIST"
    exit 0
else
    echo "================================================================="
    echo "❌ HEALTH CHECK FAILED: Initiating automated zero-downtime rollback..."
    echo "================================================================="
    mv "$BACKEND_DIR/dist" "$FAILED_DIST"
    if [ -d "$BACKUP_DIST" ]; then
        mv "$BACKUP_DIST" "$BACKEND_DIR/dist"
        touch "/home/u796269890/domains/allgujaratvankarsamaj.com/restart_trigger.txt"
        bash "$PROJECT_ROOT/keep_backend_alive.sh" --force
        echo "⏮️ Restored previous backend distribution."
    fi
    exit 1
fi
