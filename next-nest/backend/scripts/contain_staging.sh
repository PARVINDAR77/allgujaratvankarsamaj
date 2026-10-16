#!/usr/bin/env bash
# ==============================================================================
# All Gujarat Vankar Samaj Matrimony — Failure Containment Script
# Execution Context: Invoked on test failure or manual containment
# Safety Guarantees:
# 1. Stops strictly vankar-backend-staging PM2 process.
# 2. Never guesses paths; fails closed if staging canonical path is unverified.
# 3. Validates path separation against production before touching any files.
# 4. Verifies completeness of evidence operations explicitly.
# 5. Redacts connection strings, bearer tokens, and secrets before saving logs.
# ==============================================================================

set -Eeuo pipefail
set +x

echo "=== Executing Staging Failure Containment ==="

# 1. Stop PM2 staging process only
echo "Stopping PM2 staging process: vankar-backend-staging..."
if pm2 stop vankar-backend-staging; then
  echo "[CONTAIN-PM2] SUCCESS: vankar-backend-staging stopped."
else
  echo "[CONTAIN-PM2] WARNING: vankar-backend-staging stop command failed or process was not running."
fi

# 2. Safely resolve both staging and production document roots fail-closed
STAGING_DOMAIN_DIR="/home/u796269890/domains/staging.allgujaratvankarsamaj.com"
PROD_DOMAIN_DIR="/home/u796269890/domains/allgujaratvankarsamaj.com"

if [ ! -d "$PROD_DOMAIN_DIR/public_html" ]; then
  echo "FATAL CONTAINMENT ERROR: Production document root $PROD_DOMAIN_DIR/public_html does not exist. Halting containment to prevent ambiguous operations."
  exit 1
fi

PROD_CANONICAL=$(readlink -f "$PROD_DOMAIN_DIR/public_html" || true)
if [ -z "$PROD_CANONICAL" ] || [ ! -d "$PROD_CANONICAL" ]; then
  echo "FATAL CONTAINMENT ERROR: Cannot resolve canonical production document root. Halting."
  exit 1
fi

if [ ! -d "$STAGING_DOMAIN_DIR/public_html" ]; then
  echo "FATAL CONTAINMENT ERROR: Staging domain directory $STAGING_DOMAIN_DIR/public_html does not exist. Halting proxy operation."
  exit 1
fi

STAGING_CANONICAL=$(readlink -f "$STAGING_DOMAIN_DIR/public_html" || true)
if [ -z "$STAGING_CANONICAL" ] || [ ! -d "$STAGING_CANONICAL" ]; then
  echo "FATAL CONTAINMENT ERROR: Cannot verify canonical staging document root ($STAGING_DOMAIN_DIR/public_html). Halting proxy modification."
  exit 1
fi

# Hard assertion: both roots must exist, be non-empty, and strictly separate
if [ "$STAGING_CANONICAL" = "$PROD_CANONICAL" ] || \
   [[ "$STAGING_CANONICAL/" == "$PROD_CANONICAL"/* ]] || \
   [[ "$PROD_CANONICAL/" == "$STAGING_CANONICAL"/* ]]; then
  echo "CRITICAL OVERLAP DETECTED: Staging document root overlaps production! Refusing to modify files."
  exit 1
fi

# 3. Disable staging API ingress fail-closed (503 Service Unavailable)
# Refuse to write through symlinks on directory or target file
STAGING_API_DIR="$STAGING_CANONICAL/api"
if [ -d "$STAGING_API_DIR" ]; then
  if [ -L "$STAGING_API_DIR" ]; then
    echo "FATAL CONTAINMENT ERROR: $STAGING_API_DIR is a symbolic link! Refusing to write through symlink."
    exit 1
  fi
  TARGET_INDEX="$STAGING_API_DIR/index.php"
  if [ -L "$TARGET_INDEX" ]; then
    echo "FATAL CONTAINMENT ERROR: $TARGET_INDEX is a symbolic link! Refusing to write through symlink."
    exit 1
  fi

  echo '<?php http_response_code(503); header("Content-Type: application/json"); echo json_encode(["status" => 503, "message" => "Staging Ingress Disabled for Investigation"]); ?>' \
    > "$TARGET_INDEX"
  chmod 644 "$TARGET_INDEX"
  echo "[CONTAIN-INGRESS] SUCCESS: 503 Service Unavailable written to $TARGET_INDEX."
else
  echo "[CONTAIN-INGRESS] SKIPPED: Staging API directory $STAGING_API_DIR does not exist."
fi

# 4. Prepare Evidence Directory
EVIDENCE_DIR="/home/u796269890/staging/evidence"
mkdir -p "$EVIDENCE_DIR"
chmod 700 "$EVIDENCE_DIR"

# 5. Database state preservation using restrictive option file
CNF_FILE="/home/u796269890/staging/.my_staging.cnf"
DB_DUMP_FILE="$EVIDENCE_DIR/staging_failure_dump.sql"
DUMP_STATUS="NOT_ATTEMPTED"

if [ -f "$CNF_FILE" ]; then
  echo "Preserving staging database schema and state..."
  if mysqldump --defaults-extra-file="$CNF_FILE" --single-transaction --routines --triggers \
       vankar_matrimony_staging > "$DB_DUMP_FILE" 2>/dev/null && [ -s "$DB_DUMP_FILE" ]; then
    DUMP_BYTES=$(wc -c < "$DB_DUMP_FILE")
    DUMP_STATUS="COMPLETE"
    echo "[EVIDENCE-DB] SUCCESS: Database dump verified ($DUMP_BYTES bytes in $DB_DUMP_FILE)."
  else
    DUMP_STATUS="FAILED_INCOMPLETE"
    rm -f "$DB_DUMP_FILE"
    echo "[EVIDENCE-DB] FAILED: mysqldump exited with error or produced empty file. Incomplete dump removed."
  fi
else
  DUMP_STATUS="SKIPPED_NO_CNF"
  echo "[EVIDENCE-DB] SKIPPED: Option file $CNF_FILE does not exist."
fi

# 6. Preserve and Redact Forensic Logs
LOG_DIR="/home/u796269890/staging/logs"
LOGS_PRESERVED=0

if [ -d "$LOG_DIR" ]; then
  for log_file in "$LOG_DIR"/*.log; do
    [ -f "$log_file" ] || continue
    base_name=$(basename "$log_file")
    out_target="$EVIDENCE_DIR/redacted_${base_name}"

    # Comprehensive redaction: DATABASE_URL, passwords, bcrypt hashes, JWTs, Bearer tokens
    sed -E \
      -e 's/(DATABASE_URL="?mysql:\/\/[^:]+:)[^@]+(@)/\1[REDACTED]\2/g' \
      -e 's/(password[=:][ ]*)[^ &;]+/\1[REDACTED]/gi' \
      -e 's/(JWT_SECRET="?)[^"]+("?)/\1[REDACTED]\2/g' \
      -e 's/Bearer [A-Za-z0-9._-]+/Bearer [REDACTED]/g' \
      -e 's/\$2[aby]\$[0-9]{2}\$[A-Za-z0-9.\/]{53}/[BCRYPT_HASH_REDACTED]/g' \
      "$log_file" > "$out_target"

    if [ -s "$out_target" ]; then
      LOGS_PRESERVED=$((LOGS_PRESERVED + 1))
      chmod 600 "$out_target"
    else
      rm -f "$out_target"
    fi
  done
  echo "[EVIDENCE-LOGS] SUCCESS: $LOGS_PRESERVED log files preserved and redacted in $EVIDENCE_DIR/."
else
  echo "[EVIDENCE-LOGS] NOTICE: Log directory $LOG_DIR does not exist."
fi

# 7. Write Evidence Status Manifest & Enforce Restrictive Mode 600
cat <<EOF > "$EVIDENCE_DIR/EVIDENCE_STATUS.txt"
CONTAINMENT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATABASE_DUMP_STATUS=$DUMP_STATUS
LOGS_PRESERVED_COUNT=$LOGS_PRESERVED
CLASSIFICATION=STAGING_INTERNAL_FORENSIC_ONLY
WARNING=Do not publish evidence directory or logs to public document roots or artifacts.
EOF
chmod 600 "$EVIDENCE_DIR/EVIDENCE_STATUS.txt"

# Clean any transient credential files from evidence
rm -f "$EVIDENCE_DIR"/.env* "$EVIDENCE_DIR"/*credentials* 2>/dev/null || true
chmod 600 "$EVIDENCE_DIR"/* 2>/dev/null || true

echo "=== Containment Verification Complete. Evidence status: $DUMP_STATUS. ==="
