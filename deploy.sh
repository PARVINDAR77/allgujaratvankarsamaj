#!/usr/bin/env bash

set -Eeuo pipefail

# =========================================================
# Hostinger Shared Hosting Deployment Script
# =========================================================

# Resolve project root regardless of where script is run from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
cd "$PROJECT_ROOT"

echo "Pulling latest code from Git..."
git pull origin main

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
        echo "ΓÜá∩╕Å Another deployment is currently running (PID: $LOCK_PID)!"
        exit 1
    else
        echo "≡ƒº╣ Removing stale lock file..."
        rm -f "$LOCK_FILE"
    fi
fi

echo $$ > "$LOCK_FILE"

cleanup() {
    rm -f "$LOCK_FILE"
    rm -f "$PROJECT_ROOT/mysql-backup.cnf"
    echo "≡ƒº╣ Cleanup complete."
}
trap cleanup EXIT
trap 'echo "Γ¥î Deployment failed at line $LINENO"; exit 1' ERR

echo "=========================================="
echo "≡ƒÜÇ Starting Hostinger Production Deployment"
echo "=========================================="

# ---------------------------------------------------------
# Validations
# ---------------------------------------------------------
echo "≡ƒöì Validating requirements..."

# Removed 'pm2' and 'flutter' from strict requirements.
# On shared hosting, compiling Flutter is often impossible due to lack of Android SDK/memory.
# We highly recommend compiling Flutter LOCALLY and pushing the 'build/web' folder to Git!
REQUIRED_CMDS=("git" "node" "npm" "npx" "mysql" "mysqldump" "curl" "gzip")
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" > /dev/null 2>&1; then
        echo "Γ¥î Required command '$cmd' is not installed in this shared hosting environment."
        exit 1
    fi
done

if [ ! -f ".env.production" ]; then
    echo "Γ¥î Error: .env.production file missing in project root!"
    exit 1
fi

echo "≡ƒôª Loading production environment..."
set -a; source .env.production; set +a

if [ -z "${DB_HOST:-}" ] || [ -z "${DB_USER:-}" ] || [ -z "${DB_PASSWORD:-}" ] || [ -z "${DB_NAME:-}" ]; then
    echo "Γ¥î Error: Database credentials must be in .env.production"
    exit 1
fi

# ---------------------------------------------------------
# Database Backup
# ---------------------------------------------------------
DATE=$(date +'%Y-%m-%d_%H-%M-%S')
BACKUP_DIR="$PROJECT_ROOT/deploy/backups"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/db_backup_$DATE.sql.gz"

echo "≡ƒÆ╛ Backing up Hostinger database before pulling code..."
cat << EOF > "$PROJECT_ROOT/mysql-backup.cnf"
[client]
host=${DB_HOST}
user=${DB_USER}
password="${DB_PASSWORD}"
EOF
chmod 600 "$PROJECT_ROOT/mysql-backup.cnf"

mysqldump --defaults-extra-file="$PROJECT_ROOT/mysql-backup.cnf" "$DB_NAME" | gzip > "$BACKUP_FILE"
rm -f "$PROJECT_ROOT/mysql-backup.cnf"

echo "Γ£à Backup created at $BACKUP_FILE"

# ---------------------------------------------------------
# Git Sync
# ---------------------------------------------------------
echo "≡ƒôÑ Pulling latest code from git..."
git pull origin main

CURRENT_COMMIT=$(git rev-parse --short HEAD)
echo "≡ƒôî Target Commit: $CURRENT_COMMIT"

# ---------------------------------------------------------
# Build & Deploy: NestJS Backend
# ---------------------------------------------------------
echo "ΓÜÖ∩╕Å Building NestJS Backend..."
cd "$PROJECT_ROOT/next-nest/backend"

# On shared hosting, memory is limited. If 'npm ci' crashes, try 'npm install --production'
npm ci
npx prisma generate

echo "Syncing Admin Roles in Database via MySQL CLI..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "UPDATE users SET role = 'SUPER_ADMIN', status = 'ACTIVE' WHERE email IN ('admin@vankarsamaj.org', 'admin@vankarsamaj.com');" || true

echo "Skipping Database Migrations (Hostinger RAM limits)..."
# npx prisma migrate deploy
npm run build
cd "$PROJECT_ROOT"

echo "Pulling latest code from Git..."
git pull origin main

# ---------------------------------------------------------
# Next.js Admin (Pre-built)
# ---------------------------------------------------------
echo "≡ƒûÑ∩╕Å Using pre-built Next.js Admin Panel (built locally)..."
# Hostinger shared hosting kills the Next.js build worker due to process limits.
# Build Next.js locally with 'npm run build' and push the 'out/' folder to Git.
if [ ! -d "$PROJECT_ROOT/next-nest/frontend/out" ]; then
    echo "Γ¥î ERROR: next-nest/frontend/out/ not found!"
    echo "ΓÜá∩╕Å Build Next.js locally and push the 'out/' folder to Git first:"
    echo "   cd next-nest/frontend && npm run build && git add out && git commit && git push"
    exit 1
fi
echo "Γ£à Found pre-built Next.js output."
cd "$PROJECT_ROOT"

echo "Pulling latest code from Git..."
git pull origin main

# ---------------------------------------------------------
# Build: Flutter Web (WARNING)
# ---------------------------------------------------------
echo "≡ƒô▒ Preparing Flutter Web Application..."
# We skip 'flutter build web' because Hostinger Business does not support the Flutter SDK.
# The script assumes you ran 'flutter build web' LOCALLY and pushed the 'application/build/web' folder to Git.
if [ ! -d "$PROJECT_ROOT/application/build/web" ]; then
    echo "Γ¥î Error: application/build/web directory not found!"
    echo "ΓÜá∩╕Å You must build Flutter locally and push the build/web folder to Git when using shared hosting."
    exit 1
fi

# ---------------------------------------------------------
# Pre-rollback Snapshot (App State)
# ---------------------------------------------------------
echo "≡ƒô╕ Preparing rollback artifacts..."
PREV_ADMIN_DIR="${ADMIN_WEB_ROOT}_prev"
PREV_APP_DIR="${APP_WEB_ROOT}_prev"

[ -d "$ADMIN_WEB_ROOT" ] && cp -r "$ADMIN_WEB_ROOT" "$PREV_ADMIN_DIR"
[ -d "$APP_WEB_ROOT" ] && cp -r "$APP_WEB_ROOT" "$PREV_APP_DIR"

# ---------------------------------------------------------
# Atomic Replacements & Reloads
# ---------------------------------------------------------
echo "≡ƒöä Executing atomic deployments..."

# 1. NestJS (Background Process via Unix Socket)
# Since this Hostinger plan doesn't support Passenger, we run it in the background on a Unix Socket
echo "≡ƒöä Restarting Node.js Backend..."
pkill -f node || true
rm -f /home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock
SOCKET_PATH=/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock NODE_ENV=production nohup node "$PROJECT_ROOT/next-nest/backend/dist/main.js" > "$PROJECT_ROOT/next-nest/backend/backend.log" 2>&1 &

# 2. Deploy Application (Atomic Merge: Next.js + Flutter)
echo "Deploying Application..."
mkdir -p "$(dirname "$APP_WEB_ROOT")"
rm -rf "${APP_WEB_ROOT}_tmp"
mkdir -p "${APP_WEB_ROOT}_tmp"

# Ensure persistent uploads folder across deployments
PERSISTENT_UPLOADS="/home/u796269890/domains/allgujaratvankarsamaj.com/uploads"
mkdir -p "$PERSISTENT_UPLOADS"
mkdir -p "$PROJECT_ROOT/next-nest/backend/uploads"
ln -sfn "$PERSISTENT_UPLOADS" "$PROJECT_ROOT/next-nest/backend/uploads"
ln -sfn "$PERSISTENT_UPLOADS" "${APP_WEB_ROOT}_tmp/uploads"

# 2a. Copy Next.js Admin Panel (Base)
echo "Merging Next.js Admin Panel..."
cp -r "$PROJECT_ROOT/next-nest/frontend/out/"* "${APP_WEB_ROOT}_tmp/" || true
# Remove Next.js index.html so it doesn't conflict with Flutter's main entry point
rm -f "${APP_WEB_ROOT}_tmp/index.html"

# Inject Next.js Apache .htaccess into the admin folder for static exports
mkdir -p "${APP_WEB_ROOT}_tmp/admin"
cat << 'EOF' > "${APP_WEB_ROOT}_tmp/admin/.htaccess"
RewriteEngine On
RewriteBase /admin/

# Strip trailing slash if present: e.g. /admin/users/ -> /admin/users
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)/$ $1 [R=301,L]

# If the request is for the root of /admin/, serve the root admin.html
RewriteRule ^$ ../admin.html [L]

# If file exists directly (e.g. users.html), serve it
RewriteCond %{REQUEST_FILENAME} -f
RewriteRule ^ - [L]

# If the requested file has no extension, and a corresponding .html exists, serve it
RewriteCond %{REQUEST_FILENAME}.html -f
RewriteRule ^(.*)$ $1.html [L]

# Also check directly in admin folder
RewriteCond %{DOCUMENT_ROOT}/admin/$1.html -f
RewriteRule ^(.*)$ $1.html [L]

# Return 404 for missing static assets to prevent HTML syntax errors in JS/CSS
RewriteCond %{REQUEST_URI} \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|map|json)$ [NC]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^ - [R=404,L]

# Stop the root Flutter .htaccess from intercepting /admin requests - fallback to admin.html
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ ../admin.html [L]
EOF

# 2b. Copy Flutter App (Overrides)
echo "Merging Flutter App..."
cp -r "$PROJECT_ROOT/application/build/web/"* "${APP_WEB_ROOT}_tmp/"
[ -d "$APP_WEB_ROOT/api" ] && cp -r "$APP_WEB_ROOT/api" "${APP_WEB_ROOT}_tmp/"

# Generate robust root .htaccess
cat << 'EOF' > "${APP_WEB_ROOT}_tmp/.htaccess"
RewriteEngine On

# Allow direct file access for existing files and directories
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]

# Return real 404 for missing static assets (js, css, images) so they never serve index.html
RewriteCond %{REQUEST_URI} \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|map)$ [NC]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^ - [R=404,L]

# Route /api/ to api_proxy.php
RewriteRule ^api/(.*)$ api_proxy.php [QSA,L]

# Route /uploads/ to api_proxy.php as fallback
RewriteRule ^uploads/(.*)$ api_proxy.php [QSA,L]

# Normal Flutter/SPA routing (fallback to index.html for non-files)
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.html [QSA,L]
EOF

# Generate a robust api_proxy.php for Hostinger Unix socket support
cat << 'EOF' > "${APP_WEB_ROOT}_tmp/api_proxy.php"
<?php
// Enhanced API Proxy to Unix Socket with Error Reporting
error_reporting(E_ALL);
ini_set('display_errors', 0); // Don't output PHP errors to the client to prevent breaking JSON

$socket_path = 'unix:///home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock';

$method = $_SERVER['REQUEST_METHOD'];
// Get the original URI requested, fallback to /api/v1 if missing
$uri = $_SERVER['REQUEST_URI'];
if (empty($uri)) {
    $uri = '/api/v1';
}

$headers = [];
foreach (getallheaders() as $name => $value) {
    $lowerName = strtolower($name);
    if ($lowerName !== 'host' && $lowerName !== 'connection' && $lowerName !== 'content-length') {
        $headers[] = "$name: $value";
    }
}
$headers[] = "Host: localhost";
$headers[] = "Connection: close";

$body = file_get_contents('php://input');
if ($body !== false) {
    $headers[] = "Content-Length: " . strlen($body);
}

$request = "$method $uri HTTP/1.1\r\n" . implode("\r\n", $headers) . "\r\n\r\n" . $body;

$fp = stream_socket_client($socket_path, $errno, $errstr, 5);

if (!$fp) {
    http_response_code(502);
    header('Content-Type: application/json');
    echo json_encode(["statusCode" => 502, "message" => "Bad Gateway: Backend socket is unreachable ($errstr)"]);
    exit;
}

fwrite($fp, $request);

$response = '';
while (!feof($fp)) {
    $response .= fread($fp, 8192);
}
fclose($fp);

if (empty($response)) {
    http_response_code(502);
    header('Content-Type: application/json');
    echo json_encode(["statusCode" => 502, "message" => "Bad Gateway: Backend returned empty response"]);
    exit;
}

$parts = explode("\r\n\r\n", $response, 2);
$header_text = $parts[0];
$body_text = isset($parts[1]) ? $parts[1] : '';

$header_lines = explode("\r\n", $header_text);
foreach ($header_lines as $line) {
    if (empty(trim($line))) continue;
    
    if (preg_match('/^HTTP\/\d\.\d\s+(\d+)/', $line, $matches)) {
        http_response_code((int)$matches[1]);
    } else {
        // Do not pass Transfer-Encoding, let Hostinger/PHP handle it
        if (stripos(trim($line), 'Transfer-Encoding:') === 0) continue;
        header($line, true);
    }
}

echo $body_text;
?>
EOF
[ -f "$APP_WEB_ROOT/index.php" ] && cp "$APP_WEB_ROOT/index.php" "${APP_WEB_ROOT}_tmp/"

# Swap atomic directories
mv "${APP_WEB_ROOT}" "${APP_WEB_ROOT}_old" 2>/dev/null || true
mv "${APP_WEB_ROOT}_tmp" "${APP_WEB_ROOT}"
rm -rf "${APP_WEB_ROOT}_old"

# ---------------------------------------------------------
# Health Checks with Retry
# ---------------------------------------------------------
echo "≡ƒ⌐║ Running Health Checks..."

# Give Hostinger Passenger time to spin up the Node app
sleep 5 

check_health() {
    local url=$1
    local retries=15
    local wait=3
    while [ $retries -gt 0 ]; do
        BODY=$(curl -s "$url"); HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$url"); echo "URL: $url | CODE: $HTTP_CODE | BODY: $BODY"
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

if ! check_health "$API_DOMAIN/admin/health"; then
    echo "Γ¥î Backend health check failed!"
    HEALTH_FAIL=1
fi

if ! check_health "$API_DOMAIN/advertisements"; then
    echo "Γ¥î Public Advertisements API check failed!"
    HEALTH_FAIL=1
fi

# ---------------------------------------------------------
# Rollback Logic
# ---------------------------------------------------------
if [ $HEALTH_FAIL -eq 1 ]; then
    echo "≡ƒÜ¿ Health checks failed. Initiating application rollback..."
    
    if [ -d "$PREV_ADMIN_DIR" ]; then
        rm -rf "$ADMIN_WEB_ROOT"
        mv "$PREV_ADMIN_DIR" "$ADMIN_WEB_ROOT"
        echo "ΓÅ¬ Admin Panel static assets rolled back."
    fi
    
    if [ -d "$PREV_APP_DIR" ]; then
        rm -rf "$APP_WEB_ROOT"
        mv "$PREV_APP_DIR" "$APP_WEB_ROOT"
        echo "ΓÅ¬ Flutter Web static assets rolled back."
    fi

    # Trigger restart again to load the old backend if Node was reverted
    touch "$PROJECT_ROOT/next-nest/backend/tmp/restart.txt"

    echo "ΓÜá∩╕Å Backend automatic rollback requires manual verification."
    echo "ΓÜá∩╕Å Please check Hostinger Node.js error logs and restore manually using backup: $BACKUP_FILE"
    exit 1
fi

rm -rf "$PREV_ADMIN_DIR" "$PREV_APP_DIR"

echo "=========================================="
echo "Γ£à DEPLOYMENT SUCCESSFUL!"
echo "Date: $(date)"



echo "Target Commit: $CURRENT_COMMIT"
echo "=========================================="

