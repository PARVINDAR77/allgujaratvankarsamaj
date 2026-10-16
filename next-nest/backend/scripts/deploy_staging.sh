#!/usr/bin/env bash
# ==============================================================================
# All Gujarat Vankar Samaj Matrimony — Hardened Staging Deployment Script
# Execution Context: Isolated Staging Environment on Hostinger VPS
# Safety Guarantees:
# 1. Zero production paths, zero queries to vankar_matrimony, zero production traffic.
# 2. Preflight database inspection strictly fails closed on error, non-numeric output, or non-zero tables.
# 3. Inherited MySQL roles audited and explicitly revoked from host-specific accounts.
# 4. Rigorous path validation: both staging and production paths must exist and resolve before comparing.
# 5. Safe, clean extraction into isolated temporary directory; rejects any path traversal.
# 6. Option files (mode 600) prevent password exposure in process arguments.
# 7. Static syntax check (node --check) post-prune without bootstrapping NestJS.
# ==============================================================================

set -Eeuo pipefail
set +x

# Trap unexpected errors and print line number
trap 'echo "[ERROR] Staging deployment failed at line $LINENO with exit code $?"' ERR

echo "=== Stage 1: Read-Only Preflight & Path Validation ==="

# 1.1 Verify system resources
DISK_AVAIL_KB=$(df /home/u796269890 | awk 'NR==2 {print $4}')
if [ "$DISK_AVAIL_KB" -lt 500000 ]; then
  echo "FATAL: Insufficient disk space (< 500MB available)."
  exit 1
fi

# 1.2 Inspect and prove both canonical paths exist independently
PROD_PARENT="/home/u796269890/domains/allgujaratvankarsamaj.com"
if [ ! -d "$PROD_PARENT/public_html" ]; then
  echo "FATAL: Production web root directory $PROD_PARENT/public_html does not exist."
  exit 1
fi
PROD_CANONICAL=$(readlink -f "$PROD_PARENT/public_html")
if [ -z "$PROD_CANONICAL" ] || [ ! -d "$PROD_CANONICAL" ]; then
  echo "FATAL: Unable to resolve canonical path for production document root."
  exit 1
fi

STAGING_DOMAIN_DIR="/home/u796269890/domains/staging.allgujaratvankarsamaj.com"
if [ ! -d "$STAGING_DOMAIN_DIR/public_html" ]; then
  echo "FATAL: Staging web root directory $STAGING_DOMAIN_DIR/public_html does not exist. Provision staging subdomain first."
  exit 1
fi
STAGING_CANONICAL=$(readlink -f "$STAGING_DOMAIN_DIR/public_html")
if [ -z "$STAGING_CANONICAL" ] || [ ! -d "$STAGING_CANONICAL" ]; then
  echo "FATAL: Unable to resolve canonical path for staging document root."
  exit 1
fi

echo "Verified Production Canonical: $PROD_CANONICAL"
echo "Verified Staging Canonical:    $STAGING_CANONICAL"

# 1.3 Assert strict path separation and non-overlap
if [ "$PROD_CANONICAL" = "$STAGING_CANONICAL" ]; then
  echo "FATAL: Staging path is identical to production document root!"
  exit 1
fi

if [[ "$STAGING_CANONICAL/" == "$PROD_CANONICAL"/* ]]; then
  echo "FATAL: Staging is configured inside the production directory tree!"
  exit 1
fi

if [[ "$PROD_CANONICAL/" == "$STAGING_CANONICAL"/* ]]; then
  echo "FATAL: Production is configured inside the staging directory tree!"
  exit 1
fi

# 1.4 Fail-closed check: inspect staging API target directory contents against strict allowlist
STAGING_API_DIR="$STAGING_CANONICAL/api"
if [ -d "$STAGING_API_DIR" ]; then
  if [ -L "$STAGING_API_DIR" ]; then
    echo "FATAL: Staging API directory ($STAGING_API_DIR) is a symlink! Halting deployment."
    exit 1
  fi
  while IFS= read -r item; do
    [ -z "$item" ] && continue
    if [ -L "$item" ]; then
      echo "FATAL: Symlink detected in staging API target directory: $item -> $(readlink "$item")"
      exit 1
    fi
    base_item=$(basename "$item")
    case "$base_item" in
      "index.php"|".htaccess"|"api_proxy_staging.php")
        echo "  [OK] Approved regular file in staging API: $base_item"
        ;;
      *)
        echo "FATAL: Unapproved file or directory detected in staging API target: $base_item"
        echo "Staging API directory must not contain unverified files. Halting deployment."
        exit 1
        ;;
    esac
  done < <(find "$STAGING_API_DIR" -mindepth 1 -maxdepth 1)
fi

# Prepare staging operational directories
mkdir -p /home/u796269890/staging/backend
mkdir -p /home/u796269890/staging/logs
mkdir -p /home/u796269890/staging/evidence
chmod 755 /home/u796269890/staging
chmod 700 /home/u796269890/staging/evidence

echo "=== Stage 2: Artifact Checksum Gate & Clean Extraction ==="
cd /home/u796269890/staging

if [ ! -f "staging-backend-patch.tar.gz" ]; then
  echo "FATAL: staging-backend-patch.tar.gz not found in /home/u796269890/staging/"
  exit 1
fi

# Checksum validation: Require independently communicated EXPECTED_SHA
if [ -z "${EXPECTED_SHA:-}" ]; then
  echo "FATAL: EXPECTED_SHA is not set. Deployment requires an independently communicated trusted digest."
  echo "Example: EXPECTED_SHA=\"9975F9B829054D44A122106F25CC5EB900011151E5F98696C42D2675E81C881D\" bash deploy_staging.sh"
  exit 1
fi

SHA_OUT=$(mktemp)
SHA_ERR=$(mktemp)
if ! sha256sum staging-backend-patch.tar.gz > "$SHA_OUT" 2> "$SHA_ERR"; then
  echo "FATAL: sha256sum execution failed: $(cat "$SHA_ERR")"
  rm -f "$SHA_OUT" "$SHA_ERR"
  exit 1
fi
RAW_SHA=$(awk '{print $1}' "$SHA_OUT" | tr -d '[:space:]')
ACTUAL_SHA=$(echo "$RAW_SHA" | tr '[:lower:]' '[:upper:]')
rm -f "$SHA_OUT" "$SHA_ERR"

if ! [[ "$ACTUAL_SHA" =~ ^[0-9A-F]{64}$ ]]; then
  echo "FATAL: sha256sum returned invalid digest format: '$ACTUAL_SHA'"
  exit 1
fi

# If companion checksum file is present, verify it also matches the independent trusted digest
if [ -f "staging-backend-patch.tar.gz.sha256" ]; then
  COMPANION_SHA=$(awk '{print $1}' staging-backend-patch.tar.gz.sha256 | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
  if ! [[ "$COMPANION_SHA" =~ ^[0-9A-F]{64}$ ]]; then
    echo "FATAL: Companion staging-backend-patch.tar.gz.sha256 has invalid format: '$COMPANION_SHA'"
    exit 1
  fi
  if [ "$COMPANION_SHA" != "$EXPECTED_SHA" ]; then
    echo "FATAL: Companion staging-backend-patch.tar.gz.sha256 does not match independently provided EXPECTED_SHA!"
    echo "Companion SHA: $COMPANION_SHA"
    echo "Expected SHA:  $EXPECTED_SHA"
    exit 1
  fi
fi

if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
  echo "FATAL CHECKSUM MISMATCH!"
  echo "Expected Trusted: $EXPECTED_SHA"
  echo "Calculated:       $ACTUAL_SHA"
  exit 1
fi
echo "SUCCESS: Archive integrity verified against independently supplied trusted digest ($ACTUAL_SHA)."

# 2.2 Archive Entry, Structural & Path Verification
TAR_LIST_OUT=$(mktemp)
TAR_LIST_ERR=$(mktemp)
if ! tar -ztf staging-backend-patch.tar.gz > "$TAR_LIST_OUT" 2> "$TAR_LIST_ERR"; then
  echo "FATAL: Archive read failure: 'tar -ztf' failed: $(cat "$TAR_LIST_ERR")"
  rm -f "$TAR_LIST_OUT" "$TAR_LIST_ERR"
  exit 1
fi

if [ ! -s "$TAR_LIST_OUT" ]; then
  echo "FATAL: Archive is empty or produced 0 entries."
  rm -f "$TAR_LIST_OUT" "$TAR_LIST_ERR"
  exit 1
fi

# Assert all entries reside strictly within expected 'backend/' root directory
UNEXPECTED_MEMBERS=$(grep -vE '^backend(/|$)' "$TAR_LIST_OUT" || true)
if [ -n "$UNEXPECTED_MEMBERS" ]; then
  echo "FATAL: Archive contains members outside the expected 'backend/' root directory:"
  echo "$UNEXPECTED_MEMBERS"
  rm -f "$TAR_LIST_OUT" "$TAR_LIST_ERR"
  exit 1
fi

# Reject path traversal (..), root paths (^/), and sensitive .env files
SUSPICIOUS_PATHS=$(grep -E '(^/|/\.\./|\.\./|\.\.$|/\.\.$|\.env)' "$TAR_LIST_OUT" || true)
if [ -n "$SUSPICIOUS_PATHS" ]; then
  echo "FATAL: Archive contains suspicious traversal, absolute, or sensitive paths:"
  echo "$SUSPICIOUS_PATHS"
  rm -f "$TAR_LIST_OUT" "$TAR_LIST_ERR"
  exit 1
fi
rm -f "$TAR_LIST_OUT" "$TAR_LIST_ERR"

# Detailed entry types validation: assert tar -ztvf succeeds and only regular files/dirs exist
TAR_VLIST_OUT=$(mktemp)
TAR_VLIST_ERR=$(mktemp)
if ! tar -ztvf staging-backend-patch.tar.gz > "$TAR_VLIST_OUT" 2> "$TAR_VLIST_ERR"; then
  echo "FATAL: Archive detailed read failure: 'tar -ztvf' failed: $(cat "$TAR_VLIST_ERR")"
  rm -f "$TAR_VLIST_OUT" "$TAR_VLIST_ERR"
  exit 1
fi

DISALLOWED_ENTRIES=$(grep -vE '^[d-]' "$TAR_VLIST_OUT" || true)
if [ -n "$DISALLOWED_ENTRIES" ]; then
  echo "FATAL: Archive contains non-regular files (symlinks, hard links, or devices):"
  echo "$DISALLOWED_ENTRIES"
  rm -f "$TAR_VLIST_OUT" "$TAR_VLIST_ERR"
  exit 1
fi
rm -f "$TAR_VLIST_OUT" "$TAR_VLIST_ERR"

# 2.3 Safe, Clean Extraction and Verified Directory Replacement
EXTRACT_TMP=$(mktemp -d /home/u796269890/staging/backend_extract_XXXXXX)
chmod 700 "$EXTRACT_TMP"
tar -xzf staging-backend-patch.tar.gz -C "$EXTRACT_TMP" --strip-components=1

# Verify critical files exist in extracted payload
test -f "$EXTRACT_TMP/ecosystem.staging.config.js" || { echo "FATAL: ecosystem.staging.config.js missing from archive"; exit 1; }
test -f "$EXTRACT_TMP/dist/main.js" || { echo "FATAL: dist/main.js missing from archive"; exit 1; }
test -f "$EXTRACT_TMP/prisma/schema.prisma" || { echo "FATAL: prisma/schema.prisma missing from archive"; exit 1; }

# Verify no symlinks exist in extracted payload
EXTRACTED_SYMLINKS=$(find "$EXTRACT_TMP" -type l || true)
if [ -n "$EXTRACTED_SYMLINKS" ]; then
  echo "FATAL: Symlinks detected in extracted payload: $EXTRACTED_SYMLINKS"
  rm -rf "$EXTRACT_TMP"
  exit 1
fi

# Validate staging backend target directory canonical path
STAGING_TARGET_BACKEND="/home/u796269890/staging/backend"
if [ -d "$STAGING_TARGET_BACKEND" ]; then
  CANONICAL_TARGET=$(readlink -f "$STAGING_TARGET_BACKEND" || true)
  if [ "$CANONICAL_TARGET" != "$STAGING_TARGET_BACKEND" ]; then
    echo "FATAL: Staging backend target path ($STAGING_TARGET_BACKEND) resolves to unexpected location: $CANONICAL_TARGET"
    rm -rf "$EXTRACT_TMP"
    exit 1
  fi
  # Cleanly remove old staging backend directory completely (eliminates dotfile or wildcard omission)
  rm -rf "$STAGING_TARGET_BACKEND"
fi

# Move verified extracted tree into target location
mv "$EXTRACT_TMP" "$STAGING_TARGET_BACKEND"
chmod 700 "$STAGING_TARGET_BACKEND"
echo "SUCCESS: Clean extraction and directory replacement verified."

echo "=== Stage 3: Database Preflight, Provisioning & Role Cleanup ==="

# 3.0 Establish single, non-interactive, verified admin connection method
MYSQL_ADMIN_CNF="${MYSQL_ADMIN_CNF:-/home/u796269890/staging/.my_admin.cnf}"
if [ -f "$MYSQL_ADMIN_CNF" ]; then
  chmod 600 "$MYSQL_ADMIN_CNF" 2>/dev/null || true
  MYSQL_ADMIN_CMD=(mysql --defaults-extra-file="$MYSQL_ADMIN_CNF")
else
  # Default to non-interactive root socket connection (e.g. system root)
  MYSQL_ADMIN_CMD=(mysql -u root)
fi

# Verify admin connection immediately
ADMIN_CHECK_ERR=$(mktemp)
if ! "${MYSQL_ADMIN_CMD[@]}" -N -s -e "SELECT 1;" >/dev/null 2>"$ADMIN_CHECK_ERR"; then
  echo "FATAL: MySQL admin connection failed. Please ensure $MYSQL_ADMIN_CNF exists with valid [client] credentials, or root socket authentication is configured."
  cat "$ADMIN_CHECK_ERR"
  rm -f "$ADMIN_CHECK_ERR"
  exit 1
fi
rm -f "$ADMIN_CHECK_ERR"
echo "SUCCESS: MySQL admin connection verified."

# 3.1 FAIL-CLOSED Database Preflight
QUERY_OUT=$(mktemp)
QUERY_ERR=$(mktemp)

if ! "${MYSQL_ADMIN_CMD[@]}" -N -s -e "
  SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'vankar_matrimony_staging';
" > "$QUERY_OUT" 2> "$QUERY_ERR"; then
  echo "FATAL: Database connectivity or authentication failed during preflight inspection:"
  cat "$QUERY_ERR"
  rm -f "$QUERY_OUT" "$QUERY_ERR"
  exit 1
fi

EXISTING_TABLES_COUNT=$(tr -d '[:space:]' < "$QUERY_OUT")
rm -f "$QUERY_OUT" "$QUERY_ERR"

if ! [[ "$EXISTING_TABLES_COUNT" =~ ^[0-9]+$ ]]; then
  echo "FATAL: Non-numeric response from database preflight inspection: '$EXISTING_TABLES_COUNT'"
  exit 1
fi

if [ "$EXISTING_TABLES_COUNT" -ne 0 ]; then
  echo "FATAL: Database vankar_matrimony_staging is not empty ($EXISTING_TABLES_COUNT tables found)."
  echo "Clean staging database required for deterministic migration. Halting."
  exit 1
fi
echo "SUCCESS: Verified vankar_matrimony_staging contains 0 existing tables."

# 3.2 Audit and Revoke Inherited MySQL Roles for vankar_staging
ROLE_QUERY_OUT=$(mktemp)
ROLE_QUERY_ERR=$(mktemp)

if ! "${MYSQL_ADMIN_CMD[@]}" -N -s -e "
  SELECT CONCAT('REVOKE \`', from_user, '\`@\`', from_host, '\` FROM \`', to_user, '\`@\`', to_host, '\`;')
  FROM mysql.role_edges
  WHERE to_user = 'vankar_staging';
" > "$ROLE_QUERY_OUT" 2> "$ROLE_QUERY_ERR"; then
  echo "FATAL: Failed to query mysql.role_edges for vankar_staging:"
  cat "$ROLE_QUERY_ERR"
  rm -f "$ROLE_QUERY_OUT" "$ROLE_QUERY_ERR"
  exit 1
fi

ROLE_EDGES=$(cat "$ROLE_QUERY_OUT")
rm -f "$ROLE_QUERY_OUT" "$ROLE_QUERY_ERR"

if [ -n "$ROLE_EDGES" ]; then
  echo "Notice: Detected existing role edges for vankar_staging. Revoking roles explicitly..."
  REVOKE_SQL=$(mktemp)
  chmod 600 "$REVOKE_SQL"
  cat <<EOF > "$REVOKE_SQL"
$ROLE_EDGES
SET DEFAULT ROLE NONE TO 'vankar_staging'@'127.0.0.1';
SET DEFAULT ROLE NONE TO 'vankar_staging'@'localhost';
FLUSH PRIVILEGES;
EOF
  if ! "${MYSQL_ADMIN_CMD[@]}" < "$REVOKE_SQL"; then
    echo "FATAL: Failed to execute role revocation SQL."
    rm -f "$REVOKE_SQL"
    exit 1
  fi
  rm -f "$REVOKE_SQL"
fi

# Hard assertion: Confirm role-edge count is strictly zero
ROLE_VERIFY_OUT=$(mktemp)
ROLE_VERIFY_ERR=$(mktemp)
if ! "${MYSQL_ADMIN_CMD[@]}" -N -s -e "
  SELECT COUNT(*) FROM mysql.role_edges WHERE to_user = 'vankar_staging';
" > "$ROLE_VERIFY_OUT" 2> "$ROLE_VERIFY_ERR"; then
  echo "FATAL: Failed to verify role cleanup in mysql.role_edges:"
  cat "$ROLE_VERIFY_ERR"
  rm -f "$ROLE_VERIFY_OUT" "$ROLE_VERIFY_ERR"
  exit 1
fi

REMAINING_ROLES=$(tr -d '[:space:]' < "$ROLE_VERIFY_OUT")
rm -f "$ROLE_VERIFY_OUT" "$ROLE_VERIFY_ERR"

if ! [[ "$REMAINING_ROLES" =~ ^[0-9]+$ ]] || [ "$REMAINING_ROLES" -ne 0 ]; then
  echo "FATAL: Role cleanup verification failed! vankar_staging still has $REMAINING_ROLES inherited role edges."
  exit 1
fi
echo "SUCCESS: Verified vankar_staging has exactly 0 inherited role edges."

# Generate fresh random secrets directly without SIGPIPE risk
STAGING_DB_PASS=$(openssl rand -hex 16)
STAGING_JWT_SECRET=$(openssl rand -hex 32)
[[ ${#STAGING_DB_PASS} -eq 32 ]] || { echo "Password generation error"; exit 1; }
[[ ${#STAGING_JWT_SECRET} -eq 64 ]] || { echo "JWT generation error"; exit 1; }

# Write temporary provisioning SQL file with mode 600 (prevents password in process arguments)
PROVISION_SQL=$(mktemp /home/u796269890/staging/.provision_XXXXXX.sql)
chmod 600 "$PROVISION_SQL"
cat <<EOF > "$PROVISION_SQL"
CREATE DATABASE IF NOT EXISTS vankar_matrimony_staging CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'vankar_staging'@'127.0.0.1' IDENTIFIED BY '${STAGING_DB_PASS}';
ALTER USER 'vankar_staging'@'127.0.0.1' IDENTIFIED BY '${STAGING_DB_PASS}';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'vankar_staging'@'127.0.0.1';
GRANT ALL PRIVILEGES ON vankar_matrimony_staging.* TO 'vankar_staging'@'127.0.0.1';

CREATE USER IF NOT EXISTS 'vankar_staging'@'localhost' IDENTIFIED BY '${STAGING_DB_PASS}';
ALTER USER 'vankar_staging'@'localhost' IDENTIFIED BY '${STAGING_DB_PASS}';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'vankar_staging'@'localhost';
GRANT ALL PRIVILEGES ON vankar_matrimony_staging.* TO 'vankar_staging'@'localhost';

FLUSH PRIVILEGES;
EOF

"${MYSQL_ADMIN_CMD[@]}" < "$PROVISION_SQL"
shred -u "$PROVISION_SQL" 2>/dev/null || rm -f "$PROVISION_SQL"

# 3.4 Hard assertion: Verify and assert user privileges strictly
assert_staging_grants() {
  local target_host="$1"
  local grants_out=$(mktemp)
  local grants_err=$(mktemp)

  if ! "${MYSQL_ADMIN_CMD[@]}" -N -s -e "SHOW GRANTS FOR 'vankar_staging'@'$target_host';" > "$grants_out" 2> "$grants_err"; then
    echo "FATAL: Failed to retrieve SHOW GRANTS for 'vankar_staging'@'$target_host':"
    cat "$grants_err"
    rm -f "$grants_out" "$grants_err"
    exit 1
  fi
  rm -f "$grants_err"

  # Reject GRANT OPTION
  if grep -qi "WITH GRANT OPTION" "$grants_out"; then
    echo "FATAL SECURITY FLAW: 'vankar_staging'@'$target_host' possesses WITH GRANT OPTION!"
    cat "$grants_out"
    rm -f "$grants_out"
    exit 1
  fi

  # Reject privileges on production database vankar_matrimony
  if grep -qi "ON \`vankar_matrimony\`\." "$grants_out" || grep -qi "ON vankar_matrimony\." "$grants_out"; then
    echo "FATAL SECURITY FLAW: 'vankar_staging'@'$target_host' has privileges on production database (vankar_matrimony)!"
    cat "$grants_out"
    rm -f "$grants_out"
    exit 1
  fi

  # Reject global privileges beyond USAGE
  while IFS= read -r grant_line; do
    [ -z "$grant_line" ] && continue
    if [[ "$grant_line" =~ ON\ \*\.\* ]]; then
      if ! [[ "$grant_line" =~ GRANT\ USAGE\ ON\ \*\.\* ]]; then
        echo "FATAL SECURITY FLAW: 'vankar_staging'@'$target_host' has global privileges beyond USAGE: $grant_line"
        rm -f "$grants_out"
        exit 1
      fi
    elif [[ "$grant_line" =~ ON\ \`?([a-zA-Z0-9_-]+)\`?\.\* ]]; then
      db_target="${BASH_REMATCH[1]}"
      if [ "$db_target" != "vankar_matrimony_staging" ]; then
        echo "FATAL SECURITY FLAW: 'vankar_staging'@'$target_host' has privileges on unexpected database '$db_target': $grant_line"
        rm -f "$grants_out"
        exit 1
      fi
    fi
  done < "$grants_out"

  # Confirm exact grant on vankar_matrimony_staging.*
  if ! grep -qi "ON \`vankar_matrimony_staging\`\." "$grants_out" && ! grep -qi "ON vankar_matrimony_staging\." "$grants_out"; then
    echo "FATAL: 'vankar_staging'@'$target_host' is missing required privileges on vankar_matrimony_staging.*!"
    cat "$grants_out"
    rm -f "$grants_out"
    exit 1
  fi

  echo "SUCCESS: Hard assertion passed for 'vankar_staging'@'$target_host' (Zero global rights, zero production DB rights, zero GRANT OPTION)."
  rm -f "$grants_out"
}

assert_staging_grants "127.0.0.1"
assert_staging_grants "localhost"

# Create restrictive MySQL client option file FIRST (mode 600)
cat <<EOF > /home/u796269890/staging/.my_staging.cnf
[client]
host=127.0.0.1
port=3306
user=vankar_staging
password=${STAGING_DB_PASS}
EOF
chmod 600 /home/u796269890/staging/.my_staging.cnf

# Test TCP loopback connection using option file (Zero passwords on CLI)
mysql --defaults-extra-file=/home/u796269890/staging/.my_staging.cnf \
  vankar_matrimony_staging -e "SELECT CURRENT_USER(), @@hostname, DATABASE();"

# Write staging .env file
cat <<EOF > /home/u796269890/staging/backend/.env
NODE_ENV=staging
PORT=3001
DATABASE_URL="mysql://vankar_staging:${STAGING_DB_PASS}@127.0.0.1:3306/vankar_matrimony_staging"
JWT_SECRET="${STAGING_JWT_SECRET}"
JWT_EXPIRES_IN="1d"
ALLOWED_ORIGINS="https://staging.allgujaratvankarsamaj.com"
ENABLE_REAL_NOTIFICATIONS=false
SMS_PROVIDER=mock
EMAIL_PROVIDER=mock
ENABLE_STAGING_TEST_ROUTES=true
STAGING_CREDENTIALS_FILE="/home/u796269890/staging/.staging_test_credentials.json"
EOF
chmod 600 /home/u796269890/staging/backend/.env

echo "=== Stage 4: Controlled Dependencies, Migration & Native Seeding ==="
cd /home/u796269890/staging/backend

# Install complete locked dependency tree (including Prisma build tools)
npm ci

# Generate Prisma Client using pinned binary
./node_modules/.bin/prisma generate

# FAIL-CLOSED: Check for failed or interrupted migrations from previous runs
MIGRATIONS_TABLE_OUT=$(mktemp)
MIGRATIONS_TABLE_ERR=$(mktemp)

if ! mysql --defaults-extra-file=/home/u796269890/staging/.my_staging.cnf \
  vankar_matrimony_staging -N -s -e "
    SELECT COUNT(*) FROM information_schema.TABLES 
    WHERE TABLE_SCHEMA = 'vankar_matrimony_staging' AND TABLE_NAME = '_prisma_migrations';
  " > "$MIGRATIONS_TABLE_OUT" 2> "$MIGRATIONS_TABLE_ERR"; then
  echo "FATAL: Failed to inspect information_schema for _prisma_migrations:"
  cat "$MIGRATIONS_TABLE_ERR"
  rm -f "$MIGRATIONS_TABLE_OUT" "$MIGRATIONS_TABLE_ERR"
  exit 1
fi

HAS_MIGRATIONS_TABLE=$(tr -d '[:space:]' < "$MIGRATIONS_TABLE_OUT")
rm -f "$MIGRATIONS_TABLE_OUT" "$MIGRATIONS_TABLE_ERR"

if ! [[ "$HAS_MIGRATIONS_TABLE" =~ ^[0-9]+$ ]]; then
  echo "FATAL: Non-numeric response checking _prisma_migrations table: '$HAS_MIGRATIONS_TABLE'"
  exit 1
fi

if [ "$HAS_MIGRATIONS_TABLE" -gt 0 ]; then
  FAILED_MIGRATIONS_OUT=$(mktemp)
  FAILED_MIGRATIONS_ERR=$(mktemp)
  if ! mysql --defaults-extra-file=/home/u796269890/staging/.my_staging.cnf \
    vankar_matrimony_staging -N -s -e "
      SELECT COUNT(*) FROM _prisma_migrations WHERE rolled_back_at IS NULL AND finished_at IS NULL;
    " > "$FAILED_MIGRATIONS_OUT" 2> "$FAILED_MIGRATIONS_ERR"; then
    echo "FATAL: Failed to query _prisma_migrations for interrupted migrations:"
    cat "$FAILED_MIGRATIONS_ERR"
    rm -f "$FAILED_MIGRATIONS_OUT" "$FAILED_MIGRATIONS_ERR"
    exit 1
  fi

  FAILED_MIGRATIONS=$(tr -d '[:space:]' < "$FAILED_MIGRATIONS_OUT")
  rm -f "$FAILED_MIGRATIONS_OUT" "$FAILED_MIGRATIONS_ERR"

  if ! [[ "$FAILED_MIGRATIONS" =~ ^[0-9]+$ ]]; then
    echo "FATAL: Non-numeric response checking failed migrations: '$FAILED_MIGRATIONS'"
    exit 1
  fi

  if [ "$FAILED_MIGRATIONS" -gt 0 ]; then
    echo "FATAL: Inconsistent database state: $FAILED_MIGRATIONS failed or interrupted migration(s) detected in _prisma_migrations!"
    exit 1
  fi
fi

# Deploy reviewed migration history (20260924053044_mysql_baseline and 20261014120000_schema_alignment)
./node_modules/.bin/prisma migrate deploy

# Verify migration status post-deployment (Must confirm database schema is fully up to date)
./node_modules/.bin/prisma migrate status

# Seed synthetic staging test fixtures natively via CommonJS with dynamic credentials
node prisma/seed_staging.js

# Prune development dependencies post-migration
npm prune --omit=dev

# Post-prune sanity check (Static syntax check; does NOT bootstrap NestJS or bind port)
test -s dist/main.js
node --check dist/main.js
echo "SUCCESS: dist/main.js syntax verified post-prune without execution."

echo "=== Stage 5: Reverse Proxy Deployment & Staging PM2 Startup ==="

# Re-verify destination before copying
mkdir -p "$STAGING_API_DIR"
if [ -L "$STAGING_API_DIR" ]; then
  echo "FATAL: Staging API directory ($STAGING_API_DIR) is a symlink! Refusing to copy proxy."
  exit 1
fi
if [ -L "$STAGING_API_DIR/index.php" ]; then
  echo "FATAL: Staging API index ($STAGING_API_DIR/index.php) is a symlink! Refusing to overwrite."
  exit 1
fi
cp -v api_proxy_staging.php "$STAGING_API_DIR/index.php"
chmod 644 "$STAGING_API_DIR/index.php"

# Start isolated PM2 staging process
pm2 start ecosystem.staging.config.js
pm2 show vankar-backend-staging

# Verify local loopback listener
curl -fsS http://127.0.0.1:3001/api/v1/health

# Hard assertion: Verify listener is strictly bound to 127.0.0.1:3001 (NOT 0.0.0.0 or public interface)
sleep 2
LISTENER_OUTPUT=$(ss -tlpn 'sport = :3001' 2>/dev/null || netstat -tlpn 2>/dev/null | grep ':3001' || true)
echo "Listener probe output: $LISTENER_OUTPUT"

if ! echo "$LISTENER_OUTPUT" | grep -q '127\.0\.0\.1:3001'; then
  echo "FATAL: Backend listener is NOT bound to 127.0.0.1:3001!"
  exit 1
fi

if echo "$LISTENER_OUTPUT" | grep -E '(0\.0\.0\.0:3001|:::3001|\*:3001)'; then
  echo "FATAL SECURITY VIOLATION: Backend listener is bound to a wildcard or public interface!"
  exit 1
fi
echo "SUCCESS: Verified backend is bound exclusively to loopback (127.0.0.1:3001)."

echo "=== Staging Deployment Completed Successfully ==="
