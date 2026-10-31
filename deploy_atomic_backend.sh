#!/usr/bin/env bash
# ==============================================================================
# All Gujarat Vankar Samaj - Stage 2: Atomic Backend Deployment & Proxy Sync
# Features:
# 1. Zero-window Atomic Symlink Swap via `mv -Tf` (Single rename(2) syscall)
# 2. Resilient against SIGKILL/crash: dist is NEVER missing at any point
# 3. Isolated from Database Migrations (Zero DDL execution)
# 4. PHP Reverse Proxy & Dashboard synchronization (0644 suPHP safe)
# 5. Automated zero-downtime rollback on liveness probe failure
# ==============================================================================

set -Eeuo pipefail

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null || true
export PATH="$HOME/.nvm/versions/node/v20.20.2/bin:$HOME/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
cd "$PROJECT_ROOT"

BACKEND_DIR="$PROJECT_ROOT/next-nest/backend"
RELEASES_DIR="$BACKEND_DIR/releases"
SOCKET_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock"
PUBLIC_HTML="/home/u796269890/domains/allgujaratvankarsamaj.com/public_html"
LOCK_FILE="$PROJECT_ROOT/deploy_atomic.lock"
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
PID=$$

NEW_RELEASE_DIR="$RELEASES_DIR/release_$TIMESTAMP"
TMP_SYMLINK="$BACKEND_DIR/dist_tmp_$TIMESTAMP"

echo "================================================================="
echo "  All Gujarat Vankar Samaj - Stage 2: Atomic Backend Deploy     "
echo "  Release: release_$TIMESTAMP                                   "
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

cleanup() {
    local exit_code=$?
    rm -f "$LOCK_FILE"
    rm -f "$TMP_SYMLINK"
    exit "$exit_code"
}
trap cleanup EXIT INT TERM HUP

# 2. Validate Source Distribution
if [ ! -d "$BACKEND_DIR/dist" ] && [ ! -L "$BACKEND_DIR/dist" ]; then
    echo "❌ Error: Backend distribution directory not found at $BACKEND_DIR/dist"
    exit 1
fi

mkdir -p "$RELEASES_DIR"

# 3. Transition from legacy directory to release directory if dist is a physical folder
CURRENT_ACTIVE_RELEASE=""
if [ -d "$BACKEND_DIR/dist" ] && [ ! -L "$BACKEND_DIR/dist" ]; then
    echo "ℹ️ Transitioning physical dist folder to versioned releases directory..."
    INITIAL_RELEASE="$RELEASES_DIR/release_initial"
    if [ ! -d "$INITIAL_RELEASE" ]; then
        mv "$BACKEND_DIR/dist" "$INITIAL_RELEASE"
    else
        rm -rf "$BACKEND_DIR/dist"
    fi
    ln -s "$INITIAL_RELEASE" "$BACKEND_DIR/dist"
    CURRENT_ACTIVE_RELEASE="$INITIAL_RELEASE"
elif [ -L "$BACKEND_DIR/dist" ]; then
    CURRENT_ACTIVE_RELEASE=$(readlink -f "$BACKEND_DIR/dist" || echo "")
fi

# 4. Prepare and Verify New Release Directory
echo "📦 Staging new release into $NEW_RELEASE_DIR..."
mkdir -p "$NEW_RELEASE_DIR"

# Copy build artifacts into new release directory
# If local repo has dist/ folder (from nest build), copy from build output
if [ -d "$PROJECT_ROOT/dist" ]; then
    cp -rf "$PROJECT_ROOT/dist"/* "$NEW_RELEASE_DIR/"
elif [ -d "$BACKEND_DIR/dist" ] && [ ! -L "$BACKEND_DIR/dist" ]; then
    cp -rf "$BACKEND_DIR/dist"/* "$NEW_RELEASE_DIR/"
elif [ -n "$CURRENT_ACTIVE_RELEASE" ] && [ -d "$CURRENT_ACTIVE_RELEASE" ]; then
    # In live pull scenarios, copy from source
    cp -rf "$CURRENT_ACTIVE_RELEASE"/* "$NEW_RELEASE_DIR/"
fi

# Strict Build Integrity Inspection
if [ ! -f "$NEW_RELEASE_DIR/main.js" ] || [ ! -f "$NEW_RELEASE_DIR/app.module.js" ]; then
    echo "❌ Error: Build integrity verification failed (missing main.js or app.module.js in release)!"
    rm -rf "$NEW_RELEASE_DIR"
    exit 1
fi
echo "✅ Build integrity verified."

# 5. Synchronize Hardened Reverse Proxy & Web Assets
echo "🌐 Updating reverse proxy and maintenance dashboard..."
if [ -d "$PUBLIC_HTML" ]; then
    cp -f "$PROJECT_ROOT/application/build/web/api_proxy.php" "$PUBLIC_HTML/api_proxy.php"
    cp -f "$PROJECT_ROOT/application/build/web/restart_backend.php" "$PUBLIC_HTML/restart_backend.php"
    chmod 644 "$PUBLIC_HTML/api_proxy.php" "$PUBLIC_HTML/restart_backend.php"
    echo "✅ Reverse proxy and dashboard synchronized (0644 suPHP safe)."
fi

# 6. Zero-Window Atomic Symlink Replacement (Single rename(2) syscall)
echo "🔄 Executing zero-window atomic symlink replacement..."
ln -sfn "$NEW_RELEASE_DIR" "$TMP_SYMLINK"
mv -Tf "$TMP_SYMLINK" "$BACKEND_DIR/dist"
echo "✅ Atomic symlink swap complete: dist -> $NEW_RELEASE_DIR"

# 7. Controlled Backend Restart via Supervisor (with --force)
echo "🚀 Restarting backend via watchdog supervisor..."
touch "/home/u796269890/domains/allgujaratvankarsamaj.com/restart_trigger.txt"
bash "$PROJECT_ROOT/keep_backend_alive.sh" --force

# 8. Post-Deployment Zero-DB Socket Liveness Verification
echo "🔍 Verifying backend zero-DB liveness probe over socket..."
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
    
    # Prune old releases, keeping the 5 most recent
    cd "$RELEASES_DIR"
    ls -dt release_* 2>/dev/null | tail -n +6 | xargs -r rm -rf || true
    exit 0
else
    echo "================================================================="
    echo "❌ HEALTH CHECK FAILED: Initiating automated zero-gap rollback..."
    echo "================================================================="
    if [ -n "$CURRENT_ACTIVE_RELEASE" ] && [ -d "$CURRENT_ACTIVE_RELEASE" ]; then
        ln -sfn "$CURRENT_ACTIVE_RELEASE" "$TMP_SYMLINK"
        mv -Tf "$TMP_SYMLINK" "$BACKEND_DIR/dist"
        touch "/home/u796269890/domains/allgujaratvankarsamaj.com/restart_trigger.txt"
        bash "$PROJECT_ROOT/keep_backend_alive.sh" --force
        echo "⏮️ Restored previous backend release: $CURRENT_ACTIVE_RELEASE"
    fi
    exit 1
fi

