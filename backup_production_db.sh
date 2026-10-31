#!/usr/bin/env bash
# ==============================================================================
# All Gujarat Vankar Samaj - Dedicated Verified Database Snapshot Tool
# Stage 1: Backups & Production Environment Inspection
# Security: Enforces chmod 700 on backup dir, chmod 600 on archive,
#           forbids public_html destination, and isolates credentials in chmod 600 CNF.
# ==============================================================================

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
BACKEND_DIR="$PROJECT_ROOT/next-nest/backend"
BACKUP_DIR="$PROJECT_ROOT/deploy/backups"
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
BACKUP_FILE="$BACKUP_DIR/db_backup_$TIMESTAMP.sql.gz"
CNF_FILE="$PROJECT_ROOT/.mysql_backup_$TIMESTAMP.cnf"

# Strict safety check: Ensure backup is never placed inside public_html
if [[ "$BACKUP_DIR" =~ /public_html(/|$) ]]; then
    echo "❌ Critical Security Error: Backup directory cannot be inside public_html!"
    exit 1
fi

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

ENV_FILE="$PROJECT_ROOT/.env.production"
if [ ! -f "$ENV_FILE" ]; then
    ENV_FILE="$BACKEND_DIR/.env"
fi

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: Production environment configuration not found at $ENV_FILE"
    exit 1
fi

set -a
source "$ENV_FILE"
set +a

if [ -z "${DB_HOST:-}" ] || [ -z "${DB_USER:-}" ] || [ -z "${DB_PASSWORD:-}" ] || [ -z "${DB_NAME:-}" ]; then
    echo "❌ Error: Database credentials missing in $ENV_FILE"
    exit 1
fi

cleanup() {
    rm -f "$CNF_FILE"
}
trap cleanup EXIT INT TERM

echo "📦 Creating verified pre-deployment database backup..."
cat << EOF > "$CNF_FILE"
[client]
host=${DB_HOST}
user=${DB_USER}
password="${DB_PASSWORD}"
EOF
chmod 600 "$CNF_FILE"

mysqldump --defaults-extra-file="$CNF_FILE" --single-transaction --quick --skip-lock-tables "$DB_NAME" | gzip > "$BACKUP_FILE"
rm -f "$CNF_FILE"

chmod 600 "$BACKUP_FILE"

if ! gzip -t "$BACKUP_FILE" > /dev/null 2>&1; then
    echo "❌ Critical Error: Database backup failed archive verification (corrupt gzip archive)!"
    rm -f "$BACKUP_FILE"
    exit 1
fi

BACKUP_SIZE=$(ls -lh "$BACKUP_FILE" | awk '{print $5}')
echo "✅ Database backup verified successfully!"
echo "   File: $BACKUP_FILE"
echo "   Permissions: 0600 (User-only read/write)"
echo "   Size: $BACKUP_SIZE"
