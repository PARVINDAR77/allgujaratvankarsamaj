#!/usr/bin/env bash
# ==============================================================================
# All Gujarat Vankar Samaj - Production Environment Preflight Inspector (Read-Only)
# Stage 1: Backups & Production Environment Inspection
# Security: Zero credential logging; uses ephemeral chmod 600 config for DB check.
# ==============================================================================

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
BACKEND_DIR="$PROJECT_ROOT/next-nest/backend"
SOCKET_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock"
PUBLIC_HTML="/home/u796269890/domains/allgujaratvankarsamaj.com/public_html"
CNF_INSPECT=""

cleanup() {
    if [ -n "$CNF_INSPECT" ] && [ -f "$CNF_INSPECT" ]; then
        rm -f "$CNF_INSPECT"
    fi
}
trap cleanup EXIT INT TERM

echo "================================================================="
echo "  All Gujarat Vankar Samaj - Production Preflight Inspection     "
echo "  Mode: READ-ONLY (No modifications made to environment)         "
echo "  Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')                     "
echo "================================================================="

echo ""
echo "--- 1. HOST & USER IDENTITY ---"
echo "User: $(whoami 2>/dev/null || id -un)"
echo "UID/GID: $(id 2>/dev/null || echo 'N/A')"
echo "Kernel: $(uname -srm 2>/dev/null || echo 'N/A')"

echo ""
echo "--- 2. DISK CAPACITY & MOUNT ---"
df -h "$PROJECT_ROOT" 2>/dev/null || df -h .

echo ""
echo "--- 3. NODE & NPM RUNTIME ---"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null || true
export PATH="/home/u796269890/bin:$HOME/.nvm/versions/node/v20.20.2/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

if command -v node >/dev/null 2>&1; then
    echo "Node.js: $(node -v) (Location: $(which node))"
else
    echo "❌ Node.js not found in PATH"
fi

if command -v npm >/dev/null 2>&1; then
    echo "NPM: $(npm -v)"
fi

echo ""
echo "--- 4. PHP RUNTIME & CURL UNIX SOCKET CAPABILITY ---"
if command -v php >/dev/null 2>&1; then
    echo "PHP CLI: $(php -v | head -n 1)"
    php -r '
        $curl = extension_loaded("curl");
        $unix = defined("CURLOPT_UNIX_SOCKET_PATH");
        $pdo = extension_loaded("pdo_mysql");
        echo "cURL Extension: " . ($curl ? "YES" : "NO") . "\n";
        echo "cURL Unix Socket (CURLOPT_UNIX_SOCKET_PATH): " . ($unix ? "SUPPORTED" : "UNSUPPORTED") . "\n";
        echo "PDO MySQL Extension: " . ($pdo ? "YES" : "NO") . "\n";
    '
else
    echo "ℹ️ php command not directly available in current shell PATH"
fi

echo ""
echo "--- 5. FILESYSTEM SYMLINK & RENAME (mv -Tf) CAPABILITY ---"
TEST_DIR="$PROJECT_ROOT/.fs_test_$$"
mkdir -p "$TEST_DIR/v1" "$TEST_DIR/v2"
echo "v1" > "$TEST_DIR/v1/test.txt"
echo "v2" > "$TEST_DIR/v2/test.txt"
ln -s "$TEST_DIR/v1" "$TEST_DIR/current"

if ln -sfn "$TEST_DIR/v2" "$TEST_DIR/tmp_link" && mv -Tf "$TEST_DIR/tmp_link" "$TEST_DIR/current" 2>/dev/null; then
    CURRENT_CONTENT=$(cat "$TEST_DIR/current/test.txt" 2>/dev/null || echo "")
    if [ "$CURRENT_CONTENT" = "v2" ]; then
        echo "✅ POSIX zero-window symlink swap (ln -sfn + mv -Tf): FULLY SUPPORTED"
    else
        echo "⚠️ Symlink swap executed but content mismatch"
    fi
else
    echo "⚠️ mv -Tf not supported by current coreutils version"
fi
rm -rf "$TEST_DIR"

echo ""
echo "--- 6. CURRENT BACKEND DISTRIBUTION STRUCTURE ---"
if [ -L "$BACKEND_DIR/dist" ]; then
    echo "Backend dist: SYMLINK -> $(readlink -f "$BACKEND_DIR/dist")"
elif [ -d "$BACKEND_DIR/dist" ]; then
    echo "Backend dist: PHYSICAL DIRECTORY (Will be smoothly converted to versioned release)"
else
    echo "Backend dist: NOT FOUND at $BACKEND_DIR/dist"
fi

echo ""
echo "--- 7. RUNNING PROCESSES (NODE / SUPERVISOR) ---"
if ps aux >/dev/null 2>&1; then
    ps aux | grep -E "main\.js|keep_backend|start_backend" | grep -v grep || echo "No active backend processes found."
elif ps -ef >/dev/null 2>&1; then
    ps -ef | grep -E "main\.js|keep_backend|start_backend" | grep -v grep || echo "No active backend processes found."
fi

echo ""
echo "--- 8. BACKEND SOCKET STATUS & ZERO-DB PROBE ---"
if [ -S "$SOCKET_FILE" ]; then
    echo "Socket file: $SOCKET_FILE (EXISTS, Socket Type)"
    ls -l "$SOCKET_FILE"
    echo "Testing zero-DB socket liveness probe..."
    if command -v curl >/dev/null 2>&1; then
        LIVENESS=$(curl -s --max-time 3 --unix-socket "$SOCKET_FILE" "http://localhost/api/v1/health/liveness" 2>/dev/null || echo "")
        echo "Probe Response: $LIVENESS"
    fi
elif [ -e "$SOCKET_FILE" ]; then
    echo "⚠️ Path exists but is NOT a Unix domain socket: $SOCKET_FILE"
    ls -l "$SOCKET_FILE"
else
    echo "ℹ️ Socket file does not currently exist at: $SOCKET_FILE"
fi

echo ""
echo "--- 9. DATABASE CONNECTIVITY & EXISTING SCHEMA AUDIT ---"
ENV_FILE="$PROJECT_ROOT/.env.production"
if [ ! -f "$ENV_FILE" ]; then
    ENV_FILE="$BACKEND_DIR/.env"
fi

if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a

    if [ -n "${DB_HOST:-}" ] && [ -n "${DB_USER:-}" ] && [ -n "${DB_NAME:-}" ]; then
        echo "Database Host: $DB_HOST | Database Name: $DB_NAME"
        if command -v mysql >/dev/null 2>&1; then
            CNF_INSPECT="$PROJECT_ROOT/.mysql_inspect_$$.cnf"
            cat << EOF > "$CNF_INSPECT"
[client]
host=${DB_HOST}
user=${DB_USER}
password="${DB_PASSWORD}"
EOF
            chmod 600 "$CNF_INSPECT"

            echo "Auditing existing indexes on target tables (read-only)..."
            mysql --defaults-extra-file="$CNF_INSPECT" "$DB_NAME" -e "
                SELECT TABLE_NAME, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS COLUMNS, NON_UNIQUE
                FROM information_schema.statistics
                WHERE table_schema = '$DB_NAME'
                  AND table_name IN ('matrimonial_profiles', 'verification_requests', 'match_interests', 'government_employments')
                GROUP BY TABLE_NAME, INDEX_NAME, NON_UNIQUE
                ORDER BY TABLE_NAME, INDEX_NAME;
            " 2>/dev/null || echo "❌ Failed to query database schema."
            rm -f "$CNF_INSPECT"
            CNF_INSPECT=""
        else
            echo "ℹ️ mysql CLI client not found in PATH."
        fi
    else
        echo "⚠️ Incomplete database credentials in configuration file."
    fi
else
    echo "❌ No production environment file found at $ENV_FILE"
fi

echo ""
echo "--- 10. DIRECTORY PERMISSIONS AUDIT ---"
for d in "$PROJECT_ROOT" "$BACKEND_DIR" "$PUBLIC_HTML"; do
    if [ -d "$d" ]; then
        ls -ld "$d"
    else
        echo "Directory not found: $d"
    fi
done

echo ""
echo "================================================================="
echo "  Preflight inspection complete. Zero modifications made.       "
echo "================================================================="
