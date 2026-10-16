#!/usr/bin/env bash
# ==============================================================================
# All Gujarat Vankar Samaj Matrimony — Read-Only Staging Preflight Inspector
# Execution Context: Non-destructive, read-only preflight verification on VPS
# Guarantees:
# 1. Zero writes to production and staging web roots or directories.
# 2. Zero database mutations, user creations, grant changes, or schema alterations.
# 3. Zero PM2 daemon spawns, process starts, restarts, or stops (verified no-spawn).
# 4. Strictly tracks and auto-cleans transient scratch directory in /tmp via EXIT/INT/TERM traps.
# 5. Performs pure read-only inspection of system capacity, document roots, archive
#    authenticity, Python AST structural containment, clean database state, and listener state.
# 6. Fails closed (Status: NOT VERIFIED) on any inconclusive, unavailable, or failed check.
# ==============================================================================

set -Eeuo pipefail
set +x

echo "======================================================================"
echo "  All Gujarat Vankar Samaj Matrimony — Read-Only Staging Preflight    "
echo "======================================================================"
echo "Execution Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "User: $(whoami 2>/dev/null || echo 'u796269890')"
echo "Host: $(hostname 2>/dev/null || echo 'Hostinger-VPS')"
echo ""

MANDATORY_CHECKS_TOTAL=6
MANDATORY_CHECKS_PASSED=0
PREFLIGHT_FAILURES=0

# Dedicated private scratch directory in the parent shell process
SCRATCH_DIR=""
CLEANUP_FAILED=0

cleanup() {
  local orig_exit=$?
  if [ -n "${SCRATCH_DIR:-}" ] && [ -d "$SCRATCH_DIR" ]; then
    if ! rm -rf "$SCRATCH_DIR" 2>/dev/null; then
      echo -e "\e[31m[CLEANUP ERROR]\e[0m Failed to remove scratch directory: $SCRATCH_DIR" >&2
      CLEANUP_FAILED=1
    else
      echo "[CLEANUP] Scratch directory successfully removed: $SCRATCH_DIR" >&2
    fi
  fi
  if [ "$orig_exit" -ne 0 ]; then
    exit "$orig_exit"
  elif [ "$CLEANUP_FAILED" -ne 0 ]; then
    exit 1
  fi
  exit 0
}
trap cleanup EXIT
trap 'echo -e "\n[CLEANUP] Received SIGINT. Terminating preflight..." >&2; exit 130' INT
trap 'echo -e "\n[CLEANUP] Received SIGTERM. Terminating preflight..." >&2; exit 143' TERM

SCRATCH_DIR=$(mktemp -d /tmp/vankar_preflight_XXXXXX)
chmod 0700 "$SCRATCH_DIR"

fail() {
  echo -e "\e[31m[PREFLIGHT FAIL]\e[0m $1"
  PREFLIGHT_FAILURES=$((PREFLIGHT_FAILURES + 1))
}

pass() {
  echo -e "\e[32m[PREFLIGHT PASS]\e[0m $1"
}

info() {
  echo -e "\e[34m[INFO]\e[0m $1"
}

# ==============================================================================
# --- 1. System Resources Inspection (Read-Only) ---
# ==============================================================================
info "Mandatory Check 1/6: Inspecting filesystem available capacity (POSIX df -Pk)..."
DISK_OUT="$SCRATCH_DIR/disk_out.txt"
DISK_ERR="$SCRATCH_DIR/disk_err.txt"
CHECK_1_OK=0

if ! df -Pk /home/u796269890 > "$DISK_OUT" 2> "$DISK_ERR"; then
  fail "Disk capacity inspection failed: $(cat "$DISK_ERR") [Status: NOT VERIFIED]"
else
  # POSIX -P guarantees single-line output per filesystem: column 4 is available KB
  DISK_AVAIL_KB=$(awk 'NR==2 {print $4}' "$DISK_OUT" | tr -d '[:space:]')
  if ! [[ "$DISK_AVAIL_KB" =~ ^[0-9]+$ ]]; then
    fail "Non-numeric disk capacity response from df: '$DISK_AVAIL_KB' [Status: NOT VERIFIED]"
  elif [ "$DISK_AVAIL_KB" -lt 500000 ]; then
    fail "Disk capacity low: $((DISK_AVAIL_KB / 1024)) MB (< 500 MB required) [Status: NOT VERIFIED]"
  else
    pass "Disk capacity sufficient: $((DISK_AVAIL_KB / 1024)) MB available."
    CHECK_1_OK=1
  fi
fi
[ "$CHECK_1_OK" -eq 1 ] && MANDATORY_CHECKS_PASSED=$((MANDATORY_CHECKS_PASSED + 1))

# ==============================================================================
# --- 2. Canonical Document Root Separation & File Type Verification (Read-Only) ---
# ==============================================================================
info "Mandatory Check 2/6: Resolving and verifying canonical document roots and directory file types..."
PROD_PARENT="/home/u796269890/domains/allgujaratvankarsamaj.com"
STAGING_PARENT="/home/u796269890/domains/staging.allgujaratvankarsamaj.com"
CHECK_2_OK=0

PROD_CANONICAL=""
if [ ! -d "$PROD_PARENT/public_html" ]; then
  fail "Production web root does not exist: $PROD_PARENT/public_html [Status: NOT VERIFIED]"
else
  CANON_PROD_OUT="$SCRATCH_DIR/canon_prod_out.txt"
  CANON_PROD_ERR="$SCRATCH_DIR/canon_prod_err.txt"
  if ! readlink -f "$PROD_PARENT/public_html" > "$CANON_PROD_OUT" 2> "$CANON_PROD_ERR"; then
    fail "Canonical resolution of production web root failed: $(cat "$CANON_PROD_ERR") [Status: NOT VERIFIED]"
  else
    PROD_CANONICAL=$(tr -d '[:space:]' < "$CANON_PROD_OUT")
    if [ -z "$PROD_CANONICAL" ] || [ ! -d "$PROD_CANONICAL" ]; then
      fail "Canonical resolution returned invalid or empty production path: '$PROD_CANONICAL' [Status: NOT VERIFIED]"
      PROD_CANONICAL=""
    else
      pass "Production web root resolved: $PROD_CANONICAL"
    fi
  fi
fi

STAGING_CANONICAL=""
if [ ! -d "$STAGING_PARENT/public_html" ]; then
  fail "Staging web root does not exist: $STAGING_PARENT/public_html [Status: NOT VERIFIED]"
else
  CANON_STG_OUT="$SCRATCH_DIR/canon_stg_out.txt"
  CANON_STG_ERR="$SCRATCH_DIR/canon_stg_err.txt"
  if ! readlink -f "$STAGING_PARENT/public_html" > "$CANON_STG_OUT" 2> "$CANON_STG_ERR"; then
    fail "Canonical resolution of staging web root failed: $(cat "$CANON_STG_ERR") [Status: NOT VERIFIED]"
  else
    STAGING_CANONICAL=$(tr -d '[:space:]' < "$CANON_STG_OUT")
    if [ -z "$STAGING_CANONICAL" ] || [ ! -d "$STAGING_CANONICAL" ]; then
      fail "Canonical resolution returned invalid or empty staging path: '$STAGING_CANONICAL' [Status: NOT VERIFIED]"
      STAGING_CANONICAL=""
    else
      pass "Staging web root resolved: $STAGING_CANONICAL"
    fi
  fi
fi

ROOTS_DISJOINT=0
if [ -z "$PROD_CANONICAL" ] || [ -z "$STAGING_CANONICAL" ]; then
  fail "Cannot verify root separation because one or both canonical paths failed to resolve [Status: NOT VERIFIED]."
else
  if [ "$PROD_CANONICAL" = "$STAGING_CANONICAL" ]; then
    fail "CRITICAL: Staging canonical root is IDENTICAL to production!"
  elif [[ "$STAGING_CANONICAL/" == "$PROD_CANONICAL"/* ]]; then
    fail "CRITICAL: Staging canonical root is nested INSIDE production!"
  elif [[ "$PROD_CANONICAL/" == "$STAGING_CANONICAL"/* ]]; then
    fail "CRITICAL: Production canonical root is nested INSIDE staging!"
  else
    pass "Path separation strictly verified: roots are mutually disjoint."
    ROOTS_DISJOINT=1
  fi
fi

# Inspect staging API directory state (Finding D Remediation)
STAGING_API_DIR="${STAGING_CANONICAL:+${STAGING_CANONICAL}/api}"
API_DIR_OK=0
if [ -z "$STAGING_API_DIR" ]; then
  fail "Cannot verify staging API directory because staging web root failed to resolve [Status: NOT VERIFIED]."
elif [ ! -d "$STAGING_API_DIR" ]; then
  # Finding D Remediation: Treat missing API directory as distinct, explicitly reviewed deployment prerequisite.
  # Preflight reports NOT VERIFIED. Does not create the directory or accept writable parent as substitute.
  fail "Staging API directory does not exist: $STAGING_API_DIR [Status: NOT VERIFIED]. Explicit directory provisioning with verified ownership, permissions, and approved contents is required prior to preflight approval."
elif [ -L "$STAGING_API_DIR" ]; then
  fail "Staging API directory is an illegal symbolic link: $STAGING_API_DIR [Status: NOT VERIFIED]."
else
  pass "Staging API directory is a genuine directory (not a symlink)."
  API_CHECK_OUT="$SCRATCH_DIR/api_check_out.txt"
  API_CHECK_ERR="$SCRATCH_DIR/api_check_err.txt"

  if ! python3 -c '
import os, sys, stat

api_dir = sys.argv[1]
approved_names = {"index.php", ".htaccess", "api_proxy_staging.php"}
violations = []
checked = 0
expected_uid = os.getuid()

try:
    st_dir = os.stat(api_dir)
    dir_mode = stat.S_IMODE(st_dir.st_mode)

    # 1. Enforce exact ownership
    if st_dir.st_uid != expected_uid:
        violations.append(f"API directory owner UID {st_dir.st_uid} does not match expected {expected_uid}")

    # 2. Enforce exact directory permissions: mode <= 0755, neither group-writable nor world-writable, no setuid/setgid
    if (dir_mode & 0o7022) != 0 or dir_mode > 0o755:
        violations.append(f"API directory mode {oct(dir_mode)} exceeds maximum allowed 0755 or contains special/group/world-write bits")

    with os.scandir(api_dir) as it:
        for entry in it:
            checked += 1
            name = entry.name

            # Reject control characters or newlines in filenames
            if any(ord(c) < 32 or ord(c) == 127 for c in name):
                violations.append(f"Control characters/newline in entry name: {repr(name)}")
                continue

            # Reject symbolic links
            if entry.is_symlink():
                target = os.readlink(entry.path)
                violations.append(f"Symlink detected in staging API directory: {repr(name)} -> {target}")
                continue

            # Require entry to be a regular file (reject directories, FIFOs, sockets, devices)
            if not entry.is_file(follow_symlinks=False):
                violations.append(f"Entry {repr(name)} is not a regular file (directory or special entry)")
                continue

            # Must match approved allowlist names
            if name not in approved_names:
                violations.append(f"Unapproved file in staging API directory: {repr(name)}")
                continue

            st_file = entry.stat(follow_symlinks=False)
            file_mode = stat.S_IMODE(st_file.st_mode)

            # Enforce exact file ownership
            if st_file.st_uid != expected_uid:
                violations.append(f"File {repr(name)} owner UID {st_file.st_uid} does not match expected {expected_uid}")

            # Enforce exact file permissions: mode <= 0644, non-executable, neither group-writable nor world-writable
            if (file_mode & 0o7133) != 0 or file_mode > 0o644:
                violations.append(f"File {repr(name)} mode {oct(file_mode)} exceeds maximum allowed 0644 or contains exec/group/world-write bits")

    if violations:
        sys.stderr.write(f"Staging API directory validation failed with {len(violations)} violation(s):\n")
        for v in violations:
            sys.stderr.write(f"  - {v}\n")
        sys.exit(1)

    print(f"Staging API directory verified: mode {oct(dir_mode)}, owner UID {expected_uid}, {checked} approved regular file(s), 0 symlinks, 0 subdirectories, 0 unapproved entries.")
    sys.exit(0)

except Exception as e:
    sys.stderr.write(f"Failed to inspect staging API directory: {e}\n")
    sys.exit(2)
' "$STAGING_API_DIR" > "$API_CHECK_OUT" 2> "$API_CHECK_ERR"; then
    fail "Staging API directory inspection failed: $(cat "$API_CHECK_ERR") [Status: NOT VERIFIED]"
  else
    pass "$(cat "$API_CHECK_OUT")"
    API_DIR_OK=1
  fi
fi

# Uploads directory audit (Finding C Remediation & Checklist Requirement)
UPLOADS_TREE_OK=0
STAGING_UPLOADS_DIR="${STAGING_CANONICAL:+${STAGING_CANONICAL}/uploads}"
if [ -z "$STAGING_UPLOADS_DIR" ]; then
  fail "Cannot verify uploads directory because staging web root failed to resolve [Status: NOT VERIFIED]."
elif [ ! -d "$STAGING_UPLOADS_DIR" ]; then
  fail "Public uploads directory does not exist: $STAGING_UPLOADS_DIR [Status: NOT VERIFIED]. Explicit directory provisioning is required."
elif [ -L "$STAGING_UPLOADS_DIR" ]; then
  fail "Public uploads root is an illegal symbolic link: $STAGING_UPLOADS_DIR [Status: NOT VERIFIED]."
else
  UPLOADS_OUT="$SCRATCH_DIR/uploads_check_out.txt"
  UPLOADS_ERR="$SCRATCH_DIR/uploads_check_err.txt"

  CORE_CHECKER="$SCRIPT_DIR/permission_checker_core.py"
  if [ ! -f "$CORE_CHECKER" ]; then
    CORE_CHECKER="$(dirname "$0")/permission_checker_core.py"
  fi

  if ! python3 "$CORE_CHECKER" --audit-uploads "$STAGING_UPLOADS_DIR" > "$UPLOADS_OUT" 2> "$UPLOADS_ERR"; then
    fail "Public uploads directory symlink audit failed: $(cat "$UPLOADS_ERR") [Status: NOT VERIFIED]"
  else
    pass "$(cat "$UPLOADS_OUT")"
    UPLOADS_TREE_OK=1
  fi
fi

# Private document storage audit (Finding C & Auditor Review Item C)
# Verification documents must be stored outside public web roots and protected with strict permissions.
STAGING_PRIVATE_UPLOADS="/home/u796269890/staging/backend/private_uploads"
PRIVATE_UPLOADS_OK=0
PRIV_CHECK_OUT="$SCRATCH_DIR/priv_check_out.txt"
PRIV_CHECK_ERR="$SCRATCH_DIR/priv_check_err.txt"

if ! python3 "$CORE_CHECKER" --audit-private "$STAGING_PRIVATE_UPLOADS" --prod-root "$PROD_CANONICAL" --stg-root "$STAGING_CANONICAL" > "$PRIV_CHECK_OUT" 2> "$PRIV_CHECK_ERR"; then
  fail "Private document storage audit failed: $(cat "$PRIV_CHECK_ERR") [Status: NOT VERIFIED]"
else
  pass "$(cat "$PRIV_CHECK_OUT")"
  PRIVATE_UPLOADS_OK=1
fi

if [ "$ROOTS_DISJOINT" -eq 1 ] && [ "$API_DIR_OK" -eq 1 ] && [ "$UPLOADS_TREE_OK" -eq 1 ] && [ "$PRIVATE_UPLOADS_OK" -eq 1 ]; then
  CHECK_2_OK=1
fi
[ "$CHECK_2_OK" -eq 1 ] && MANDATORY_CHECKS_PASSED=$((MANDATORY_CHECKS_PASSED + 1))

# ==============================================================================
# --- 3. Artifact Authenticity & Structural Integrity (Read-Only) ---
# ==============================================================================
info "Mandatory Check 3/6: Verifying staging archive authenticity and Python AST structure..."
ARCHIVE_PATH="/home/u796269890/staging/staging-backend-patch.tar.gz"
CHECK_3_OK=0

if [ ! -f "$ARCHIVE_PATH" ]; then
  fail "Staging archive not found at: $ARCHIVE_PATH [Status: NOT VERIFIED]"
else
  ACTUAL_SIZE=$(wc -c < "$ARCHIVE_PATH")
  info "Archive Size: $ACTUAL_SIZE bytes"

  # Validate sha256sum exit code and 64-char hexadecimal format
  SHA_OUT="$SCRATCH_DIR/sha_out.txt"
  SHA_ERR="$SCRATCH_DIR/sha_err.txt"
  if ! sha256sum "$ARCHIVE_PATH" > "$SHA_OUT" 2> "$SHA_ERR"; then
    fail "sha256sum execution failed on $ARCHIVE_PATH: $(cat "$SHA_ERR") [Status: NOT VERIFIED]"
    ACTUAL_SHA=""
  else
    RAW_SHA=$(awk '{print $1}' "$SHA_OUT" | tr -d '[:space:]')
    ACTUAL_SHA=$(echo "$RAW_SHA" | tr '[:lower:]' '[:upper:]')
    if ! [[ "$ACTUAL_SHA" =~ ^[0-9A-F]{64}$ ]]; then
      fail "sha256sum returned invalid or non-hexadecimal digest: '$ACTUAL_SHA' [Status: NOT VERIFIED]"
      ACTUAL_SHA=""
    else
      info "Archive SHA-256: $ACTUAL_SHA"
    fi
  fi

  HASH_MATCH_OK=0
  if [ -z "${EXPECTED_SHA:-}" ]; then
    fail "EXPECTED_SHA environment variable is not set. An independent trusted digest is required [Status: NOT VERIFIED]."
  elif ! [[ "$EXPECTED_SHA" =~ ^[0-9A-Fa-f]{64}$ ]]; then
    fail "EXPECTED_SHA has invalid format (must be 64-char hex digest): '$EXPECTED_SHA' [Status: NOT VERIFIED]"
  elif [ -z "$ACTUAL_SHA" ]; then
    fail "Cannot compare checksum because actual archive digest computation failed [Status: NOT VERIFIED]."
  elif [ "$ACTUAL_SHA" = "$(echo "$EXPECTED_SHA" | tr '[:lower:]' '[:upper:]')" ]; then
    pass "Archive SHA-256 matches independent trusted digest ($EXPECTED_SHA)."
    HASH_MATCH_OK=1
  else
    fail "CHECKSUM MISMATCH: Expected $EXPECTED_SHA, got $ACTUAL_SHA"
  fi

  # Robust Python AST structural validation: inspects raw TarInfo members directly
  AST_CHECK_OK=0
  if ! command -v python3 >/dev/null 2>&1; then
    fail "Python 3 is required for unambiguous AST archive inspection but is not installed [Status: NOT VERIFIED]."
  else
    PY_CHECK_OUT="$SCRATCH_DIR/py_check_out.txt"
    PY_CHECK_ERR="$SCRATCH_DIR/py_check_err.txt"

    VERIFIER_AST="$SCRIPT_DIR/verify_archive_ast.py"
    if [ ! -f "$VERIFIER_AST" ]; then
      VERIFIER_AST="$(dirname "$0")/verify_archive_ast.py"
    fi

    if python3 "$VERIFIER_AST" "$ARCHIVE_PATH" > "$PY_CHECK_OUT" 2> "$PY_CHECK_ERR"; then
      pass "$(cat "$PY_CHECK_OUT")"
      AST_CHECK_OK=1
    else
      fail "Archive structural validation failure: $(cat "$PY_CHECK_ERR") [Status: NOT VERIFIED]"
    fi
  fi

  if [ "$HASH_MATCH_OK" -eq 1 ] && [ "$AST_CHECK_OK" -eq 1 ]; then
    CHECK_3_OK=1
  fi
fi
[ "$CHECK_3_OK" -eq 1 ] && MANDATORY_CHECKS_PASSED=$((MANDATORY_CHECKS_PASSED + 1))

# ==============================================================================
# --- 4. Database Preflight (Read-Only, Server Identity & Clean-State Policy) ---
# ==============================================================================
info "Mandatory Check 4/6: Inspecting database connectivity, confirming server identity, and enforcing clean-state policy (Read-Only)..."
MYSQL_ADMIN_CNF="${MYSQL_ADMIN_CNF:-/home/u796269890/staging/.my_admin.cnf}"
if [ -f "$MYSQL_ADMIN_CNF" ]; then
  MYSQL_CMD=(mysql --defaults-extra-file="$MYSQL_ADMIN_CNF")
  pass "Using admin option file: $MYSQL_ADMIN_CNF"
else
  MYSQL_CMD=(mysql -u root)
  info "Using system root socket connection."
fi

CHECK_4_OK=0
DB_ERR="$SCRATCH_DIR/db_err.txt"

# 4.1 Server Identity Confirmation & Architecture Policy
# Staging database ('vankar_matrimony_staging') runs on the local MySQL server instance.
# Logical isolation is strictly enforced via dedicated credentials, schema boundaries,
# and verified absence of any privileges on foreign schemas.
EXPECTED_DB_PORT="${EXPECTED_DB_PORT:-3306}"
EXPECTED_DB_SOCKET="${EXPECTED_DB_SOCKET:-/var/run/mysqld/mysqld.sock}"
EXPECTED_DB_HOST="${EXPECTED_DB_HOST:-localhost}"
EXPECTED_DB_SERVER_ID="${EXPECTED_DB_SERVER_ID:-}"
EXPECTED_DB_SERVER_UUID="${EXPECTED_DB_SERVER_UUID:-}"

# Load independent trusted server configuration file if present
EXPECTED_DB_CONFIG="${EXPECTED_DB_CONFIG:-/home/u796269890/staging/expected_db.conf}"
if [ -f "$EXPECTED_DB_CONFIG" ]; then
  info "Loading independently configured expected database identity from $EXPECTED_DB_CONFIG"
  while IFS='=' read -r key val || [ -n "$key" ]; do
    key=$(echo "$key" | tr -d '[:space:]')
    val=$(echo "$val" | tr -d '[:space:]')
    [[ "$key" =~ ^#.* ]] && continue
    [ -z "$key" ] && continue
    case "$key" in
      EXPECTED_DB_PORT) EXPECTED_DB_PORT="$val" ;;
      EXPECTED_DB_SOCKET) EXPECTED_DB_SOCKET="$val" ;;
      EXPECTED_DB_HOST) EXPECTED_DB_HOST="$val" ;;
      EXPECTED_DB_SERVER_ID) EXPECTED_DB_SERVER_ID="$val" ;;
      EXPECTED_DB_SERVER_UUID) EXPECTED_DB_SERVER_UUID="$val" ;;
    esac
  done < "$EXPECTED_DB_CONFIG"
fi

SERVER_IDENT_OUT="$SCRATCH_DIR/server_ident_out.txt"
if ! "${MYSQL_CMD[@]}" -N -s -e "
  SELECT 
    CONCAT('Host: ', @@hostname, ' | Port: ', @@port, ' | Socket: ', IFNULL(@@socket, 'N/A'), ' | Version: ', @@version, ' | ConnID: ', CONNECTION_ID(), ' | DB: ', IFNULL(DATABASE(), 'none'));
" > "$SERVER_IDENT_OUT" 2> "$DB_ERR"; then
  fail "Cannot connect to MySQL or retrieve server identity (fail-closed): $(cat "$DB_ERR") [Status: NOT VERIFIED]"
else
  SERVER_IDENT=$(cat "$SERVER_IDENT_OUT" | xargs)
  pass "Database server identity retrieved: $SERVER_IDENT"

  # Validate connection strictly against independently configured expected server identity
  LOCAL_SERVER_OK=0
  DB_SERVER_QUERY_OUT="$SCRATCH_DIR/db_server_query_out.txt"
  if ! "${MYSQL_CMD[@]}" -N -s -e "
    SELECT CONCAT_WS('|', IFNULL(@@port, ''), IFNULL(@@socket, ''), IFNULL(@@hostname, ''), IFNULL(@@server_id, ''), IFNULL(@@server_uuid, ''));
  " > "$DB_SERVER_QUERY_OUT" 2> "$DB_ERR"; then
    fail "Failed to query database server identity variables (fail-closed): $(cat "$DB_ERR") [Status: NOT VERIFIED]"
  else
    DB_SERVER_INFO=$(cat "$DB_SERVER_QUERY_OUT" | tr -d '\r\n')
    IFS='|' read -r ACTUAL_PORT ACTUAL_SOCKET ACTUAL_HOST ACTUAL_SERVER_ID ACTUAL_SERVER_UUID <<< "$DB_SERVER_INFO"

    if [ "$ACTUAL_PORT" != "$EXPECTED_DB_PORT" ]; then
      fail "Database server port mismatch: expected '$EXPECTED_DB_PORT', got '$ACTUAL_PORT' [Status: NOT VERIFIED]"
    elif [ -n "$ACTUAL_SOCKET" ] && [ -n "$EXPECTED_DB_SOCKET" ] && [ "$ACTUAL_SOCKET" != "$EXPECTED_DB_SOCKET" ]; then
      fail "Database unix socket mismatch: expected '$EXPECTED_DB_SOCKET', got '$ACTUAL_SOCKET' [Status: NOT VERIFIED]"
    elif [ -z "$ACTUAL_SOCKET" ] && [ -n "$EXPECTED_DB_HOST" ] && [ "$ACTUAL_HOST" != "$EXPECTED_DB_HOST" ] && [ "$ACTUAL_HOST" != "127.0.0.1" ]; then
      fail "Database host mismatch: expected '$EXPECTED_DB_HOST', got '$ACTUAL_HOST' [Status: NOT VERIFIED]"
    elif [ -n "$EXPECTED_DB_SERVER_ID" ] && [ "$ACTUAL_SERVER_ID" != "$EXPECTED_DB_SERVER_ID" ]; then
      fail "Database server_id mismatch: expected '$EXPECTED_DB_SERVER_ID', got '$ACTUAL_SERVER_ID' [Status: NOT VERIFIED]"
    elif [ -n "$EXPECTED_DB_SERVER_UUID" ] && [ "$ACTUAL_SERVER_UUID" != "$EXPECTED_DB_SERVER_UUID" ]; then
      fail "Database server_uuid mismatch: expected '$EXPECTED_DB_SERVER_UUID', got '$ACTUAL_SERVER_UUID' [Status: NOT VERIFIED]"
    else
      pass "Database server identity confirmed against expected configuration: port=$ACTUAL_PORT, socket=${ACTUAL_SOCKET:-N/A}, host=$ACTUAL_HOST, server_id=$ACTUAL_SERVER_ID."
      LOCAL_SERVER_OK=1
    fi
  fi

  # 4.2 Require staging database schema to exist (vankar_matrimony_staging)
  SCHEMAS_OUT="$SCRATCH_DIR/schemas_out.txt"
  SCHEMAS_EXIST_OK=0
  if ! "${MYSQL_CMD[@]}" -N -s -e "
    SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = 'vankar_matrimony_staging';
  " > "$SCHEMAS_OUT" 2> "$DB_ERR"; then
    fail "Failed to query information_schema.SCHEMATA (fail-closed): $(cat "$DB_ERR") [Status: NOT VERIFIED]"
  else
    SCHEMA_COUNT=$(wc -l < "$SCHEMAS_OUT" | tr -d '[:space:]')
    FOUND_SCHEMAS=$(tr '\n' ' ' < "$SCHEMAS_OUT" | xargs)
    if [ "$SCHEMA_COUNT" -ne 1 ]; then
      fail "Database schema verification failed: Staging schema 'vankar_matrimony_staging' not found [Status: NOT VERIFIED]."
    else
      pass "Verified required staging schema existence: 'vankar_matrimony_staging' exists."
      SCHEMAS_EXIST_OK=1
    fi
  fi

  # 4.3 Require an explicitly verified staging database context (not merely non-production)
  STAGING_DB_CTX_OK=0
  ACTIVE_DB_OUT="$SCRATCH_DIR/active_db_out.txt"
  if ! "${MYSQL_CMD[@]}" -N -s -e "USE vankar_matrimony_staging; SELECT DATABASE();" > "$ACTIVE_DB_OUT" 2> "$DB_ERR"; then
    fail "Failed to bind and verify staging database context 'vankar_matrimony_staging' (fail-closed): $(cat "$DB_ERR") [Status: NOT VERIFIED]"
  else
    ACTIVE_DB=$(tr -d '[:space:]' < "$ACTIVE_DB_OUT")
    if [ "$ACTIVE_DB" != "vankar_matrimony_staging" ]; then
      fail "Active database context mismatch: expected 'vankar_matrimony_staging', got '$ACTIVE_DB' [Status: NOT VERIFIED]"
    else
      pass "Active database context explicitly verified: bound to 'vankar_matrimony_staging'."
      STAGING_DB_CTX_OK=1
    fi
  fi

  # 4.4 Fail-Closed Staging Privilege Isolation Check (vankar_staging must have zero grants on foreign databases)
  PRIV_ISOLATION_OK=0
  ROLE_CLEAN_OK=0

  USER_HOSTS_OUT="$SCRATCH_DIR/user_hosts_out.txt"
  if ! "${MYSQL_CMD[@]}" -N -s -e "SELECT Host FROM mysql.user WHERE User = 'vankar_staging' ORDER BY Host;" > "$USER_HOSTS_OUT" 2> "$DB_ERR"; then
    fail "Failed to query mysql.user for staging user 'vankar_staging' (fail-closed): $(cat "$DB_ERR") [Status: NOT VERIFIED]"
  else
    STAGING_HOSTS=$(tr '\n' ' ' < "$USER_HOSTS_OUT" | xargs)
    USER_EXISTS=$(wc -w <<< "$STAGING_HOSTS" | tr -d '[:space:]')
    if [ "$USER_EXISTS" -eq 0 ]; then
      pass "Staging database user 'vankar_staging' does not exist yet (clean pre-provisioning state; zero privileges verified across all hosts)."
      PRIV_ISOLATION_OK=1
      ROLE_CLEAN_OK=1
    else
      info "Staging database accounts detected for 'vankar_staging' across host(s): $STAGING_HOSTS"
      # Staging user exists; verify complete privilege isolation
      ISOLATION_FAILED=0

      # 1. Global privileges check: vankar_staging must have ZERO administrative privileges (only USAGE)
      GLOBAL_PRIVS_OUT="$SCRATCH_DIR/global_privs_out.txt"
      if ! "${MYSQL_CMD[@]}" -N -s -e "
        SELECT COUNT(*) FROM information_schema.USER_PRIVILEGES 
        WHERE GRANTEE LIKE \"'vankar_staging'@%\" AND PRIVILEGE_TYPE != 'USAGE';
      " > "$GLOBAL_PRIVS_OUT" 2> "$DB_ERR"; then
        fail "Failed to query information_schema.USER_PRIVILEGES for 'vankar_staging' (fail-closed): $(cat "$DB_ERR") [Status: NOT VERIFIED]"
        ISOLATION_FAILED=1
      else
        GLOBAL_PRIVS=$(tr -d '[:space:]' < "$GLOBAL_PRIVS_OUT")
        if ! [[ "$GLOBAL_PRIVS" =~ ^[0-9]+$ ]]; then
          fail "Non-numeric response querying global privileges for 'vankar_staging': '$GLOBAL_PRIVS' [Status: NOT VERIFIED]"
          ISOLATION_FAILED=1
        elif [ "$GLOBAL_PRIVS" -ne 0 ]; then
          fail "Global privilege violation: 'vankar_staging' has $GLOBAL_PRIVS global non-USAGE privilege(s) (administrative leak) [Status: NOT VERIFIED]"
          ISOLATION_FAILED=1
        else
          pass "Global privilege isolation verified: 'vankar_staging' has 0 global administrative privileges."
        fi
      fi

      # 2. Schema-level isolation: vankar_staging must have ZERO grants on any foreign database
      if [ "$ISOLATION_FAILED" -eq 0 ]; then
        CROSS_PRIVS_OUT="$SCRATCH_DIR/cross_privs_out.txt"
        if ! "${MYSQL_CMD[@]}" -N -s -e "
          SELECT COUNT(*) FROM information_schema.SCHEMA_PRIVILEGES 
          WHERE GRANTEE LIKE \"'vankar_staging'@%\" AND TABLE_SCHEMA != 'vankar_matrimony_staging';
        " > "$CROSS_PRIVS_OUT" 2> "$DB_ERR"; then
          fail "Failed to query foreign schema privileges for staging user (fail-closed): $(cat "$DB_ERR") [Status: NOT VERIFIED]"
          ISOLATION_FAILED=1
        else
          CROSS_PRIVS=$(tr -d '[:space:]' < "$CROSS_PRIVS_OUT")
          if ! [[ "$CROSS_PRIVS" =~ ^[0-9]+$ ]]; then
            fail "Non-numeric response querying foreign schema privileges: '$CROSS_PRIVS' [Status: NOT VERIFIED]"
            ISOLATION_FAILED=1
          elif [ "$CROSS_PRIVS" -ne 0 ]; then
            fail "Privilege leak detected: staging identity 'vankar_staging' has $CROSS_PRIVS foreign schema grant(s) outside 'vankar_matrimony_staging'! [Status: NOT VERIFIED]"
            ISOLATION_FAILED=1
          fi
        fi
      fi

      # 3. Table-level isolation: vankar_staging must have ZERO table grants on foreign databases
      if [ "$ISOLATION_FAILED" -eq 0 ]; then
        TABLE_PRIVS_OUT="$SCRATCH_DIR/table_privs_out.txt"
        if ! "${MYSQL_CMD[@]}" -N -s -e "
          SELECT COUNT(*) FROM information_schema.TABLE_PRIVILEGES 
          WHERE GRANTEE LIKE \"'vankar_staging'@%\" AND TABLE_SCHEMA != 'vankar_matrimony_staging';
        " > "$TABLE_PRIVS_OUT" 2> "$DB_ERR"; then
          fail "Failed to query foreign table privileges for staging user (fail-closed): $(cat "$DB_ERR") [Status: NOT VERIFIED]"
          ISOLATION_FAILED=1
        else
          TABLE_PRIVS=$(tr -d '[:space:]' < "$TABLE_PRIVS_OUT")
          if ! [[ "$TABLE_PRIVS" =~ ^[0-9]+$ ]]; then
            fail "Non-numeric response querying foreign table privileges: '$TABLE_PRIVS' [Status: NOT VERIFIED]"
            ISOLATION_FAILED=1
          elif [ "$TABLE_PRIVS" -ne 0 ]; then
            fail "Privilege leak detected: staging identity 'vankar_staging' has $TABLE_PRIVS foreign table grant(s) outside 'vankar_matrimony_staging'! [Status: NOT VERIFIED]"
            ISOLATION_FAILED=1
          fi
        fi
      fi

      # 4. Column-level isolation: vankar_staging must have ZERO column grants on foreign databases
      if [ "$ISOLATION_FAILED" -eq 0 ]; then
        COL_PRIVS_OUT="$SCRATCH_DIR/col_privs_out.txt"
        if ! "${MYSQL_CMD[@]}" -N -s -e "
          SELECT COUNT(*) FROM information_schema.COLUMN_PRIVILEGES 
          WHERE GRANTEE LIKE \"'vankar_staging'@%\" AND TABLE_SCHEMA != 'vankar_matrimony_staging';
        " > "$COL_PRIVS_OUT" 2> "$DB_ERR"; then
          fail "Failed to query foreign column privileges for staging user (fail-closed): $(cat "$DB_ERR") [Status: NOT VERIFIED]"
          ISOLATION_FAILED=1
        else
          COL_PRIVS=$(tr -d '[:space:]' < "$COL_PRIVS_OUT")
          if ! [[ "$COL_PRIVS" =~ ^[0-9]+$ ]]; then
            fail "Non-numeric response querying foreign column privileges: '$COL_PRIVS' [Status: NOT VERIFIED]"
            ISOLATION_FAILED=1
          elif [ "$COL_PRIVS" -ne 0 ]; then
            fail "Privilege leak detected: staging identity 'vankar_staging' has $COL_PRIVS foreign column grant(s) outside 'vankar_matrimony_staging'! [Status: NOT VERIFIED]"
            ISOLATION_FAILED=1
          fi
        fi
      fi

      # 5. Routine-level isolation: vankar_staging must have ZERO routine grants on foreign databases
      if [ "$ISOLATION_FAILED" -eq 0 ]; then
        ROUTINE_PRIVS_OUT="$SCRATCH_DIR/routine_privs_out.txt"
        if ! "${MYSQL_CMD[@]}" -N -s -e "
          SELECT COUNT(*) FROM information_schema.ROUTINE_PRIVILEGES 
          WHERE GRANTEE LIKE \"'vankar_staging'@%\" AND ROUTINE_SCHEMA != 'vankar_matrimony_staging';
        " > "$ROUTINE_PRIVS_OUT" 2> "$DB_ERR"; then
          fail "Failed to query foreign routine privileges for staging user (fail-closed): $(cat "$DB_ERR") [Status: NOT VERIFIED]"
          ISOLATION_FAILED=1
        else
          ROUTINE_PRIVS=$(tr -d '[:space:]' < "$ROUTINE_PRIVS_OUT")
          if ! [[ "$ROUTINE_PRIVS" =~ ^[0-9]+$ ]]; then
            fail "Non-numeric response querying foreign routine privileges: '$ROUTINE_PRIVS' [Status: NOT VERIFIED]"
            ISOLATION_FAILED=1
          elif [ "$ROUTINE_PRIVS" -ne 0 ]; then
            fail "Privilege leak detected: staging identity 'vankar_staging' has $ROUTINE_PRIVS foreign routine grant(s) outside 'vankar_matrimony_staging'! [Status: NOT VERIFIED]"
            ISOLATION_FAILED=1
          fi
        fi
      fi

      if [ "$ISOLATION_FAILED" -eq 0 ]; then
        pass "Staging privilege isolation verified: 'vankar_staging' has 0 global privileges and 0 schema, table, column, and routine grants on foreign databases."
        PRIV_ISOLATION_OK=1
      fi

      # 4.5 Fail-Closed MySQL Role Inspection (vankar_staging must have zero inherited roles)
      ROLE_OUT="$SCRATCH_DIR/role_out.txt"
      if ! "${MYSQL_CMD[@]}" -N -s -e "SELECT COUNT(*) FROM mysql.role_edges WHERE to_user = 'vankar_staging';" > "$ROLE_OUT" 2> "$DB_ERR"; then
        fail "Failed to query mysql.role_edges for staging user (fail-closed): $(cat "$DB_ERR") [Status: NOT VERIFIED]"
      else
        ROLE_EDGES=$(tr -d '[:space:]' < "$ROLE_OUT")
        if ! [[ "$ROLE_EDGES" =~ ^[0-9]+$ ]]; then
          fail "Non-numeric response querying role edges: '$ROLE_EDGES' [Status: NOT VERIFIED]"
        elif [ "$ROLE_EDGES" -ne 0 ]; then
          fail "Clean role violation: 'vankar_staging' has $ROLE_EDGES inherited role edge(s) in mysql.role_edges [Status: FAILED]"
        else
          pass "Clean role state verified: 'vankar_staging' has 0 inherited MySQL roles."
          ROLE_CLEAN_OK=1
        fi
      fi
    fi
  fi

  # 4.6 Enforce Clean Table State (vankar_matrimony_staging must have 0 existing tables)
  TABLES_OUT="$SCRATCH_DIR/tables_out.txt"
  TABLE_CLEAN_OK=0
  if ! "${MYSQL_CMD[@]}" -N -s -e "
    SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'vankar_matrimony_staging';
  " > "$TABLES_OUT" 2> "$DB_ERR"; then
    fail "Failed to query table count in vankar_matrimony_staging: $(cat "$DB_ERR") [Status: NOT VERIFIED]"
  else
    TABLE_COUNT=$(tr -d '[:space:]' < "$TABLES_OUT")
    if ! [[ "$TABLE_COUNT" =~ ^[0-9]+$ ]]; then
      fail "Non-numeric response checking table count: '$TABLE_COUNT' [Status: NOT VERIFIED]"
    elif [ "$TABLE_COUNT" -eq 0 ]; then
      pass "Clean database state verified: vankar_matrimony_staging has 0 existing tables."
      TABLE_CLEAN_OK=1
    else
      fail "Clean database violation: vankar_matrimony_staging contains $TABLE_COUNT existing tables. Clean empty state (0 tables) is required before provisioning [Status: FAILED]."
    fi
  fi

  if [ "$LOCAL_SERVER_OK" -eq 1 ] && [ "$SCHEMAS_EXIST_OK" -eq 1 ] && [ "$STAGING_DB_CTX_OK" -eq 1 ] && [ "$PRIV_ISOLATION_OK" -eq 1 ] && [ "$ROLE_CLEAN_OK" -eq 1 ] && [ "$TABLE_CLEAN_OK" -eq 1 ]; then
    CHECK_4_OK=1
  fi
fi
[ "$CHECK_4_OK" -eq 1 ] && MANDATORY_CHECKS_PASSED=$((MANDATORY_CHECKS_PASSED + 1))

# ==============================================================================
# --- 5. Existing Process & Port Listener State (Read-Only) ---
# ==============================================================================
info "Mandatory Check 5/6: Inspecting port 3001 listener state across IPv4 and IPv6 (Read-Only)..."
PROBE_TOOL=""
if command -v ss >/dev/null 2>&1; then
  PROBE_TOOL="ss"
elif command -v netstat >/dev/null 2>&1; then
  PROBE_TOOL="netstat"
elif command -v lsof >/dev/null 2>&1; then
  PROBE_TOOL="lsof"
fi

CHECK_5_OK=0
if [ -z "$PROBE_TOOL" ]; then
  fail "Listener inspection tool unavailable: neither ss, netstat, nor lsof found on system [Status: NOT VERIFIED]."
else
  LISTEN_OUT="$SCRATCH_DIR/listen_out.txt"
  LISTEN_ERR="$SCRATCH_DIR/listen_err.txt"
  LISTEN_STATUS=0

  if [ "$PROBE_TOOL" = "ss" ]; then
    ss -tlpn 'sport = :3001' > "$LISTEN_OUT" 2> "$LISTEN_ERR" || LISTEN_STATUS=$?
    if [ "$LISTEN_STATUS" -ne 0 ] || [ -s "$LISTEN_ERR" ]; then
      fail "Listener probe failed using ss (exit $LISTEN_STATUS): $(cat "$LISTEN_ERR") [Status: NOT VERIFIED]"
    else
      MATCHED_LISTEN=$(awk 'NR>1 {print $0}' "$LISTEN_OUT" | tr '\n' ' ' | xargs)
      if [ -z "$MATCHED_LISTEN" ]; then
        pass "Port 3001 is confirmed free (0 active listeners across IPv4/IPv6 verified via ss)."
        CHECK_5_OK=1
      else
        info "Active listener detected on port 3001 (ss): $MATCHED_LISTEN (Flagged for operational review)."
        pass "Port 3001 listener inspection conclusive via ss (listener details reported for review)."
        CHECK_5_OK=1
      fi
    fi
  elif [ "$PROBE_TOOL" = "netstat" ]; then
    netstat -tlpn > "$LISTEN_OUT" 2> "$LISTEN_ERR" || LISTEN_STATUS=$?
    if [ "$LISTEN_STATUS" -ne 0 ] || [ -s "$LISTEN_ERR" ]; then
      fail "Listener probe failed using netstat (exit $LISTEN_STATUS): $(cat "$LISTEN_ERR") [Status: NOT VERIFIED]"
    else
      MATCHED_LISTEN=$(grep -E '(:|\])3001[[:space:]]' "$LISTEN_OUT" | tr '\n' ' ' | xargs || true)
      if [ -z "$MATCHED_LISTEN" ]; then
        pass "Port 3001 is confirmed free (0 active listeners across IPv4/IPv6 verified via netstat)."
        CHECK_5_OK=1
      else
        info "Active listener detected on port 3001 (netstat): $MATCHED_LISTEN (Flagged for operational review)."
        pass "Port 3001 listener inspection conclusive via netstat (listener details reported for review)."
        CHECK_5_OK=1
      fi
    fi
  elif [ "$PROBE_TOOL" = "lsof" ]; then
    lsof -iTCP:3001 -sTCP:LISTEN -P -n > "$LISTEN_OUT" 2> "$LISTEN_ERR" || LISTEN_STATUS=$?
    # lsof returns 0 when matches are found, and 1 when 0 matches are found.
    if [ "$LISTEN_STATUS" -eq 1 ] && [ ! -s "$LISTEN_ERR" ] && [ ! -s "$LISTEN_OUT" ]; then
      pass "Port 3001 is confirmed free (0 active listeners across IPv4/IPv6 verified via lsof)."
      CHECK_5_OK=1
    elif [ "$LISTEN_STATUS" -eq 0 ] && [ -s "$LISTEN_OUT" ]; then
      MATCHED_LISTEN=$(awk 'NR>1 {print $0}' "$LISTEN_OUT" | tr '\n' ' ' | xargs)
      info "Active listener detected on port 3001 (lsof): $MATCHED_LISTEN (Flagged for operational review)."
      pass "Port 3001 listener inspection conclusive via lsof (listener details reported for review)."
      CHECK_5_OK=1
    else
      fail "Listener probe failed using lsof (exit $LISTEN_STATUS): $(cat "$LISTEN_ERR") [Status: NOT VERIFIED]"
    fi
  fi
fi
[ "$CHECK_5_OK" -eq 1 ] && MANDATORY_CHECKS_PASSED=$((MANDATORY_CHECKS_PASSED + 1))

# ==============================================================================
# --- 6. PM2 Process Supervisor State (Pure Read-Only, Zero Daemon Spawn) ---
# ==============================================================================
info "Mandatory Check 6/6: Inspecting PM2 supervisor status (Pure Read-Only, Zero Daemon Spawn)..."
CHECK_6_OK=0

if ! command -v pm2 >/dev/null 2>&1; then
  fail "PM2 CLI is not installed or not in PATH [Status: NOT VERIFIED]. PM2 is required to manage staging backend."
else
  PM2_DIR="${PM2_HOME:-$HOME/.pm2}"
  PM2_PID_FILE="$PM2_DIR/pm2.pid"
  PM2_SOCK_FILE="$PM2_DIR/rpc.sock"

  # Finding A Remediation — Step 1: Verify PID file and RPC socket file existence
  if [ ! -f "$PM2_PID_FILE" ] || [ ! -S "$PM2_SOCK_FILE" ]; then
    fail "PM2 daemon is not active (missing $PM2_PID_FILE or $PM2_SOCK_FILE) [Status: NOT VERIFIED]. Zero-mutation preflight strictly refuses to spawn PM2 daemon."
  else
    PM2_PID=$(tr -d '[:space:]' < "$PM2_PID_FILE")

    # Step 2: Validate PID format and test process liveness
    if ! [[ "$PM2_PID" =~ ^[0-9]+$ ]] || ! kill -0 "$PM2_PID" 2>/dev/null; then
      fail "Stale PM2 PID file detected (process $PM2_PID is not running) [Status: NOT VERIFIED]. Zero-mutation preflight strictly refuses to spawn PM2 daemon."
    else
      # Step 3: Verify Process Identity to defeat PID reuse attacks/collisions
      PM2_IDENT_OK=0
      if [ -f "/proc/$PM2_PID/cmdline" ]; then
        PROC_CMDLINE=$(tr '\0' ' ' < "/proc/$PM2_PID/cmdline")
        if [[ "$PROC_CMDLINE" =~ (pm2|God\ Daemon|Daemon\.js) ]]; then
          PM2_IDENT_OK=1
        fi
      elif command -v ps >/dev/null 2>&1; then
        PS_CMDLINE=$(ps -p "$PM2_PID" -o args= 2>/dev/null || true)
        if [[ "$PS_CMDLINE" =~ (pm2|God\ Daemon|Daemon\.js) ]]; then
          PM2_IDENT_OK=1
        fi
      fi

      if [ "$PM2_IDENT_OK" -eq 0 ]; then
        fail "PID $PM2_PID does not belong to PM2 daemon (PID was reused or cmdline unverified) [Status: NOT VERIFIED]."
      else
        pass "PM2 daemon process identity verified (PID $PM2_PID belongs to PM2 God Daemon)."

        # Step 4: Verify Socket Responsiveness using dedicated Python 3 probe (zero CLI spawn risk)
        PM2_PROBE_OUT="$SCRATCH_DIR/pm2_probe_out.txt"
        PM2_PROBE_ERR="$SCRATCH_DIR/pm2_probe_err.txt"

        if ! python3 -c '
import socket, sys

sock_path = sys.argv[1]
try:
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.settimeout(2.0)
    s.connect(sock_path)
    s.close()
    print("PM2 RPC socket is active and responsive.")
    sys.exit(0)
except Exception as e:
    sys.stderr.write(f"PM2 socket connection failed or timed out: {e}\n")
    sys.exit(1)
' "$PM2_SOCK_FILE" > "$PM2_PROBE_OUT" 2> "$PM2_PROBE_ERR"; then
          fail "PM2 RPC socket unresponsive or stale: $(cat "$PM2_PROBE_ERR") [Status: NOT VERIFIED]. Zero-mutation preflight strictly refuses to spawn PM2 daemon."
        else
          pass "$(cat "$PM2_PROBE_OUT")"

          # Step 5: Pure Passive Registry Inspection (Zero PM2 Client Invocation Invariant)
          # Finding A Remediation: The preflight strictly DOES NOT invoke the PM2 client (CLI or Node module).
          # It inspects the daemon process state passively:
          # If the static process dump file exists ($PM2_DIR/dump.pm2), it is parsed passively as read-only JSON.
          # CRITICAL AUDIT DISTINCTION: This check validates PM2 supervisor daemon infrastructure readiness
          # (daemon alive, socket responsive, dump registry readable). A missing "vankar-backend-staging"
          # entry represents a clean pre-deployment state ready for registration; it is NOT interpreted
          # as proof that a live staging application process is running or healthy.
          PM2_DUMP_FILE="$PM2_DIR/dump.pm2"
          if [ -f "$PM2_DUMP_FILE" ]; then
            DUMP_OUT="$SCRATCH_DIR/dump_out.txt"
            DUMP_ERR="$SCRATCH_DIR/dump_err.txt"
            if ! python3 -c '
import json, sys

dump_path = sys.argv[1]
try:
    with open(dump_path, "r", encoding="utf-8") as f:
        procs = json.load(f)
    if not isinstance(procs, list):
        sys.stderr.write(f"PM2 dump file root is not a list (got {type(procs).__name__})\n")
        sys.exit(1)

    matching_procs = []
    for idx, entry in enumerate(procs):
        if not isinstance(entry, dict):
            sys.stderr.write(f"Registry entry at index {idx} is malformed (expected dict, got {type(entry).__name__})\n")
            sys.exit(1)
        proc_name = entry.get("name")
        if isinstance(proc_name, str) and proc_name == "vankar-backend-staging":
            matching_procs.append(entry)

    if matching_procs:
        p = matching_procs[0]
        status = p.get("pm2_env", {}).get("status", "unknown") if isinstance(p.get("pm2_env"), dict) else "unknown"
        print(f"PM2 REGISTRY STATE: \"vankar-backend-staging\" is previously registered (dump status: {status}). Note: Staging process already exists in registry; deploy_staging.sh will perform a controlled reload. Live process health cannot be inferred from passive dump data.")
    else:
        print("PM2 REGISTRY STATE: \"vankar-backend-staging\" is NOT registered (clean pre-deployment state). Note: This confirms no prior or conflicting registration exists; deploy_staging.sh will register the application. This does not indicate a running application.")
    sys.exit(0)
except Exception as e:
    sys.stderr.write(f"Failed to parse PM2 dump file passively: {e}\n")
    sys.exit(1)
' "$PM2_DUMP_FILE" > "$DUMP_OUT" 2> "$DUMP_ERR"; then
              fail "Passive PM2 dump inspection failed (unreadable or invalid JSON): $(cat "$DUMP_ERR") [Status: NOT VERIFIED]"
            else
              pass "PM2 supervisor daemon infrastructure readiness verified (CHECK_6_OK=1). Note: Confirms supervisor availability only; does NOT assert that the staging application process is running or healthy."
              info "$(cat "$DUMP_OUT")"
              CHECK_6_OK=1
            fi
          else
            fail "PM2 static dump file not present at $PM2_DUMP_FILE. Daemon registry cannot be passively verified without invoking PM2 client [Status: NOT VERIFIED]. Zero-mutation preflight strictly refuses to invoke PM2 client or spawn daemons."
          fi
        fi
      fi
    fi
  fi
fi
[ "$CHECK_6_OK" -eq 1 ] && MANDATORY_CHECKS_PASSED=$((MANDATORY_CHECKS_PASSED + 1))

echo ""
echo "======================================================================"
if [ "$PREFLIGHT_FAILURES" -eq 0 ] && [ "$MANDATORY_CHECKS_PASSED" -eq "$MANDATORY_CHECKS_TOTAL" ]; then
  echo -e "\e[32m  ALL DEFINED READ-ONLY PREFLIGHT CHECKS PASSED ($MANDATORY_CHECKS_PASSED/$MANDATORY_CHECKS_TOTAL MANDATORY CHECKS VERIFIED)  \e[0m"
  echo "  Preflight verification complete. Independent audit review required before deployment."
  echo "======================================================================"
  exit 0
else
  echo -e "\e[31m  PREFLIGHT NOT VERIFIED / FAILED ($PREFLIGHT_FAILURES FAILURE(S), $MANDATORY_CHECKS_PASSED/$MANDATORY_CHECKS_TOTAL PASSED)  \e[0m"
  echo "  One or more mandatory preflight checks were inconclusive or failed."
  echo "  Resolve all reported issues before requesting deployment authorization."
  echo "======================================================================"
  exit 1
fi
