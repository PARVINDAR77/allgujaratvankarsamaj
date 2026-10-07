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
git checkout -- keep_backend_alive.sh start_backend_daemon.sh 2>/dev/null || true
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

echo "Fixing candidate gender assignments in Database..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "
UPDATE matrimonial_profiles 
SET gender = 'FEMALE' 
WHERE LOWER(first_name) LIKE '%ben%' 
   OR LOWER(first_name) LIKE '%bahen%' 
   OR first_name LIKE '%બેન%' 
   OR first_name LIKE '%બહેન%'
   OR LOWER(first_name) IN ('dipika', 'sakshi', 'pooja', 'priya', 'neha', 'dula', 'dulaben', 'heena', 'kinjal', 'payal', 'kiran', 'sheetal', 'rekha');
UPDATE users 
SET gender = 'FEMALE' 
WHERE id IN (SELECT user_id FROM matrimonial_profiles WHERE gender = 'FEMALE');
ALTER TABLE matrimonial_profiles MODIFY COLUMN marital_status ENUM('NEVER_MARRIED', 'MARRIED', 'DIVORCED', 'WIDOWED', 'SEPARATED') NOT NULL DEFAULT 'NEVER_MARRIED';
" || true

echo "Applying required schema tables and columns via MySQL CLI..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "
CREATE TABLE IF NOT EXISTS \`samaj_super_stars\` (
  \`id\` varchar(191) NOT NULL,
  \`name\` varchar(191) NOT NULL,
  \`gujarati_name\` varchar(191) DEFAULT NULL,
  \`photo_url\` text DEFAULT NULL,
  \`description\` text DEFAULT NULL,
  \`designation\` varchar(191) DEFAULT NULL,
  \`year\` varchar(191) DEFAULT NULL,
  \`display_order\` int NOT NULL DEFAULT 0,
  \`is_active\` tinyint(1) NOT NULL DEFAULT 1,
  \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  \`updated_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (\`id\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS \`pavan_prernadata\` (
  \`id\` varchar(191) NOT NULL,
  \`name\` varchar(191) NOT NULL,
  \`gujarati_name\` varchar(191) DEFAULT NULL,
  \`photo_url\` text DEFAULT NULL,
  \`description\` text DEFAULT NULL,
  \`designation\` varchar(191) DEFAULT NULL,
  \`year\` varchar(191) DEFAULT NULL,
  \`display_order\` int NOT NULL DEFAULT 0,
  \`is_active\` tinyint(1) NOT NULL DEFAULT 1,
  \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  \`updated_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (\`id\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS \`samaj_ratnas\` (
  \`id\` varchar(191) NOT NULL,
  \`name\` varchar(191) NOT NULL,
  \`gujarati_name\` varchar(191) DEFAULT NULL,
  \`photo_url\` text DEFAULT NULL,
  \`description\` text DEFAULT NULL,
  \`designation\` varchar(191) DEFAULT NULL,
  \`year\` varchar(191) DEFAULT NULL,
  \`display_order\` int NOT NULL DEFAULT 0,
  \`is_active\` tinyint(1) NOT NULL DEFAULT 1,
  \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  \`updated_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (\`id\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS \`section_view_counts\` (
  \`id\` varchar(191) NOT NULL,
  \`section_name\` varchar(191) NOT NULL,
  \`view_count\` int NOT NULL DEFAULT 0,
  \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  \`updated_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (\`id\`),
  UNIQUE KEY \`section_view_counts_section_name_key\` (\`section_name\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS \`home_button_configs\` (
  \`id\` varchar(191) NOT NULL,
  \`button_id\` int NOT NULL,
  \`title\` varchar(191) DEFAULT NULL,
  \`subtitle\` varchar(191) DEFAULT NULL,
  \`icon\` varchar(191) DEFAULT NULL,
  \`route\` varchar(191) NOT NULL,
  \`is_active\` tinyint(1) NOT NULL DEFAULT 1,
  \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  \`updated_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (\`id\`),
  UNIQUE KEY \`home_button_configs_button_id_key\` (\`button_id\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS \`samaj_service_persons\` (
  \`id\` varchar(191) NOT NULL,
  \`service_id\` varchar(191) NOT NULL,
  \`user_id\` varchar(191) DEFAULT NULL,
  \`name\` varchar(191) NOT NULL,
  \`gujarati_name\` varchar(191) DEFAULT NULL,
  \`photo_url\` text DEFAULT NULL,
  \`phone\` varchar(191) NOT NULL,
  \`address\` text DEFAULT NULL,
  \`city\` varchar(191) DEFAULT NULL,
  \`description\` text DEFAULT NULL,
  \`experience\` varchar(191) DEFAULT NULL,
  \`district_id\` varchar(191) DEFAULT NULL,
  \`taluka_id\` varchar(191) DEFAULT NULL,
  \`village_id\` varchar(191) DEFAULT NULL,
  \`is_active\` tinyint(1) NOT NULL DEFAULT 1,
  \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  \`updated_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (\`id\`),
  KEY \`samaj_service_persons_service_id_idx\` (\`service_id\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS \`system_notifications\` (
  \`id\` varchar(191) NOT NULL,
  \`title\` varchar(191) NOT NULL,
  \`message\` text NOT NULL,
  \`target\` varchar(191) NOT NULL DEFAULT 'ALL',
  \`route\` varchar(191) DEFAULT NULL,
  \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (\`id\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE \`advertisements\` MODIFY COLUMN \`placement\` ENUM('HOME_BANNER', 'DIRECTORY_BANNER', 'POPUP', 'BUTTON_1', 'BUTTON_2', 'BUTTON_3', 'BUTTON_4', 'BUTTON_5', 'PAVAN_PRERNADATA', 'SAMAJ_SUPER_STARS', 'SAMAJ_RATNA') NOT NULL DEFAULT 'HOME_BANNER';

ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`is_physically_disabled\` tinyint(1) NOT NULL DEFAULT 0;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`pwbd_category\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`is_abroad\` tinyint(1) NOT NULL DEFAULT 0;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`abroad_country\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`business_industry\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`business_service\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`blood_group\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`is_vankar\` tinyint(1) NOT NULL DEFAULT 1;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`annual_income\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`father_name\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`father_occupation\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`father_contact\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`mother_name\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`mother_occupation\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`guardian_contact\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`siblings\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`mamas_village\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`address_line\` text DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`pincode\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`alt_phone\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`contact_email\` varchar(191) DEFAULT NULL;
ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`mother_tongue\` varchar(191) DEFAULT 'Gujarati (ગુજરાતી)';
" || true

echo "Skipping Database Migrations (Hostinger RAM limits)..."
# npx prisma migrate deploy
npm run build
cd "$PROJECT_ROOT"

echo "Pulling latest code from Git..."
git pull origin main

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

echo "Pulling latest code from Git..."
git pull origin main

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

# 1. NestJS (Background Process via Unix Socket)
# Since this Hostinger plan doesn't support Passenger, we run it in the background on a Unix Socket
echo "🔄 Starting Permanent Node.js Backend Supervisor..."
command -v pm2 > /dev/null 2>&1 && pm2 delete all 2>/dev/null || true
pkill -f "start_backend_daemon.sh" 2>/dev/null || true
pkill -f "dist/main.js" 2>/dev/null || true
sleep 1
rm -f /home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock
chmod +x "$PROJECT_ROOT/start_backend_daemon.sh" "$PROJECT_ROOT/keep_backend_alive.sh"
nohup "$PROJECT_ROOT/start_backend_daemon.sh" > /dev/null 2>&1 &
sleep 2

echo "⏰ Installing Keep-Alive Watchdog Cron Job (checks every minute)..."
(crontab -l 2>/dev/null | grep -v "keep_backend_alive.sh"; echo "* * * * * $PROJECT_ROOT/keep_backend_alive.sh >/dev/null 2>&1") | crontab - 2>/dev/null || true

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

# If file exists directly (e.g. static assets, images, etc.), serve it
RewriteCond %{REQUEST_FILENAME} -f
RewriteRule ^ - [L]

# If directory exists, let mod_dir serve directory index (index.html)
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]

# For clean URLs without trailing slashes, check if directory/index.html exists
RewriteCond %{DOCUMENT_ROOT}/admin/$1/index.html -f
RewriteRule ^(.*)$ $1/index.html [L]

# Return 404 for missing static assets to prevent HTML syntax errors in JS/CSS
RewriteCond %{REQUEST_URI} \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|map|json)$ [NC]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^ - [R=404,L]

# Stop the root Flutter .htaccess from intercepting /admin requests - fallback to admin index.html
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.html [L]
EOF

# 2b. Copy Flutter App (Overrides)
echo "Merging Flutter App..."
cp -r "$PROJECT_ROOT/application/build/web/"* "${APP_WEB_ROOT}_tmp/"
[ -d "$APP_WEB_ROOT/api" ] && cp -r "$APP_WEB_ROOT/api" "${APP_WEB_ROOT}_tmp/"

# Automatic cache-busting on every deploy to prevent stale browser caching
DEPLOY_TS=$(date +%s)
echo "Injecting cache-buster timestamp: $DEPLOY_TS ..."
sed -i "s/flutter_bootstrap\.js[^\"']*\"/flutter_bootstrap.js?v=$DEPLOY_TS\"/g" "${APP_WEB_ROOT}_tmp/index.html" || true
sed -i "s/main\.dart\.js[^\"']*/main.dart.js?v=$DEPLOY_TS/g" "${APP_WEB_ROOT}_tmp/flutter_bootstrap.js" || true
rm -f "${APP_WEB_ROOT}_tmp/flutter_service_worker.js"

# Generate robust root .htaccess
cat << 'EOF' > "${APP_WEB_ROOT}_tmp/.htaccess"
RewriteEngine On

# Correct MIME Types for WebAssembly, JS, and JSON
<IfModule mod_mime.c>
    AddType application/wasm .wasm
    AddType application/javascript .js .mjs
    AddType application/json .json
</IfModule>

# Disable caching for HTML and JS to ensure updates apply immediately
<IfModule mod_headers.c>
    <FilesMatch "\.(html|js|json)$">
        Header set Cache-Control "no-cache, no-store, must-revalidate, max-age=0"
        Header set Pragma "no-cache"
        Header set Expires "0"
    </FilesMatch>
</IfModule>

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

# Privacy Policy & Account Deletion URLs for Google Play Console compliance
RewriteRule ^privacy-policy/?$ privacy-policy.html [L]
RewriteRule ^privacy/?$ privacy-policy.html [L]
RewriteRule ^delete-account/?$ delete-account.html [L]
RewriteRule ^account-deletion/?$ delete-account.html [L]
RewriteRule ^delete-data/?$ delete-account.html [L]

# Normal Flutter/SPA routing (fallback to index.html for non-files)
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.html [QSA,L]
EOF

# Generate a robust self-healing api_proxy.php for Hostinger Unix socket support
cat << 'EOF' > "${APP_WEB_ROOT}_tmp/api_proxy.php"
<?php
// Enhanced Self-Healing API Proxy to NestJS Backend on Hostinger Unix Domain Socket
error_reporting(0);
ini_set('display_errors', 0);

$socket_file = '/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock';
$socket_path = 'unix://' . $socket_file;
$backend_dir = '/home/u796269890/domains/allgujaratvankarsamaj.com/project_source/next-nest/backend';
$main_script = $backend_dir . '/dist/main.js';
$log_file = $backend_dir . '/backend.log';
$lock_file = sys_get_temp_dir() . '/vankar_backend_spawn.lock';

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$uri = $_SERVER['REQUEST_URI'] ?? '/api/v1';

// Dynamic CORS handling compatible with withCredentials=true
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$reqHeaders = $_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS'] ?? 'Authorization, Content-Type, Accept, Origin, X-Requested-With, X-Request-ID, Cache-Control, Pragma';

if (!empty($origin)) {
    header("Access-Control-Allow-Origin: $origin");
    header("Access-Control-Allow-Credentials: true");
    header("Vary: Origin");
} else {
    header("Access-Control-Allow-Origin: *");
}

header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
header("Access-Control-Allow-Headers: $reqHeaders");
header('Access-Control-Max-Age: 86400');

// 1. Immediate CORS Preflight response
if ($method === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// 2. Direct handling for file upload if PHP received a multipart form file
if ((preg_match('#^/api/v1/storage/upload#', $uri) || preg_match('#^/storage/upload#', $uri)) && !empty($_FILES['file'])) {
    $file = $_FILES['file'];
    if ($file['error'] === UPLOAD_ERR_OK && is_uploaded_file($file['tmp_name'])) {
        $uploadDir = '/home/u796269890/domains/allgujaratvankarsamaj.com/uploads';
        if (!is_dir($uploadDir)) {
            @mkdir($uploadDir, 0755, true);
        }
        $origName = basename($file['name']);
        $ext = strtolower(pathinfo($origName, PATHINFO_EXTENSION) ?: 'jpg');
        $allowedExts = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'pdf'];
        if (in_array($ext, $allowedExts)) {
            $uniqueFilename = bin2hex(random_bytes(16)) . '.' . $ext;
            $destPath = $uploadDir . '/' . $uniqueFilename;
            if (move_uploaded_file($file['tmp_name'], $destPath)) {
                header('Content-Type: application/json');
                http_response_code(201);
                echo json_encode([
                    'success' => true,
                    'url' => '/uploads/' . $uniqueFilename
                ]);
                exit;
            }
        }
    }
}

// 3. Connect to backend socket with self-healing auto-restart
function try_connect_socket($path, $timeout = 2) {
    $errno = 0;
    $errstr = '';
    $fp = @stream_socket_client($path, $errno, $errstr, $timeout);
    return [$fp, $errno, $errstr];
}

list($fp, $errno, $errstr) = try_connect_socket($socket_path, 2);
if (!$fp) {
    list($tcp_fp, $tcp_errno, $tcp_errstr) = try_connect_socket('tcp://127.0.0.1:3000', 1);
    if ($tcp_fp) {
        $fp = $tcp_fp;
    }
}

// If socket connection failed, attempt automatic self-healing restart
if (!$fp) {
    $can_restart = true;
    if (file_exists($lock_file)) {
        if ((time() - filemtime($lock_file)) < 10) {
            $can_restart = false;
        }
    }

    if ($can_restart && (function_exists('shell_exec') || function_exists('exec'))) {
        @touch($lock_file);
        
        if (file_exists($socket_file)) {
            @unlink($socket_file);
        }

        $start_cmd = "cd " . escapeshellarg($backend_dir) . " && SOCKET_PATH=" . escapeshellarg($socket_file) . " NODE_ENV=production nohup node " . escapeshellarg($main_script) . " >> " . escapeshellarg($log_file) . " 2>&1 &";
        if (function_exists('shell_exec')) {
            @shell_exec($start_cmd);
        } else {
            @exec($start_cmd);
        }

        for ($i = 0; $i < 14; $i++) {
            usleep(250000); // 250ms
            list($retry_fp, $retry_errno, $retry_errstr) = try_connect_socket($socket_path, 1);
            if (!$retry_fp) {
                list($retry_fp, $retry_errno, $retry_errstr) = try_connect_socket('tcp://127.0.0.1:3000', 1);
            }
            if ($retry_fp) {
                $fp = $retry_fp;
                break;
            }
        }
    }

    // Final fallback check
    if (!$fp) {
        list($tcp_fp, $tcp_errno, $tcp_errstr) = try_connect_socket('tcp://127.0.0.1:3000', 1);
        if ($tcp_fp) {
            $fp = $tcp_fp;
        }
    }
}

// If STILL unreachable after auto-restart attempt
if (!$fp) {
    http_response_code(502);
    header('Content-Type: application/json');
    echo json_encode([
        "statusCode" => 502,
        "message" => "Bad Gateway: Backend socket is unreachable ($errstr). Backend auto-recovery in progress.",
        "restartUrl" => "https://allgujaratvankarsamaj.com/restart_backend.php"
    ]);
    exit;
}

// 4. Build HTTP request to send over Unix socket
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
if ($body !== false && strlen($body) > 0) {
    $headers[] = "Content-Length: " . strlen($body);
}

$request = "$method $uri HTTP/1.1\r\n" . implode("\r\n", $headers) . "\r\n\r\n" . ($body !== false ? $body : '');

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

// 5. Parse response and send to client
$parts = explode("\r\n\r\n", $response, 2);
$header_text = $parts[0];
$body_text = isset($parts[1]) ? $parts[1] : '';

$header_lines = explode("\r\n", $header_text);
foreach ($header_lines as $line) {
    if (empty(trim($line))) continue;
    
    if (preg_match('/^HTTP\/\d\.\d\s+(\d+)/', $line, $matches)) {
        http_response_code((int)$matches[1]);
    } else {
        $trimLine = trim($line);
        if (stripos($trimLine, 'Transfer-Encoding:') === 0) continue;
        if (stripos($trimLine, 'Access-Control-') === 0) continue;
        header($line, true);
    }
}

echo $body_text;
?>
EOF

# Copy restart_backend.php to web root
[ -f "$PROJECT_ROOT/application/build/web/restart_backend.php" ] && cp "$PROJECT_ROOT/application/build/web/restart_backend.php" "${APP_WEB_ROOT}_tmp/"
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

