#!/usr/bin/env bash
# ========================================================
# All Gujarat Vankar Samaj - Permanent Backend Supervisor
# Keeps Node.js NestJS backend running 24/7 on Hostinger
# Safe Process Lifecycle: Precise Child PID Tracking
# ========================================================

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null || true
export PATH="/home/u796269890/.nvm/versions/node/v20.20.2/bin:/usr/local/bin:/usr/bin:/bin:$HOME/bin:$PATH"
export UV_THREADPOOL_SIZE=2
export NODE_OPTIONS="--max-old-space-size=256"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/next-nest/backend"
SOCKET_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock"
LOG_FILE="$BACKEND_DIR/backend.log"
PID_FILE="$SCRIPT_DIR/backend_daemon.pid"
NODE_PID_FILE="$SCRIPT_DIR/backend_node.pid"

echo "$$" > "$PID_FILE"

cd "$BACKEND_DIR" || exit 1

# Load production environment variables
if [ -f "$SCRIPT_DIR/.env.production" ]; then
    set -a
    source "$SCRIPT_DIR/.env.production"
    set +a
fi
if [ -f "$BACKEND_DIR/.env" ]; then
    set -a
    source "$BACKEND_DIR/.env"
    set +a
fi

# Helper: verify whether a PID belongs to this specific backend application
is_backend_node_process() {
    local pid="$1"
    [ -n "$pid" ] || return 1
    kill -0 "$pid" 2>/dev/null || return 1
    if [ -f "/proc/$pid/cmdline" ]; then
        if grep -qa "dist/main\.js" "/proc/$pid/cmdline" 2>/dev/null; then
            return 0
        fi
        return 1
    fi
    if ps -p "$pid" -o args= 2>/dev/null | grep -q "dist/main\.js"; then
        return 0
    fi
    return 1
}

# Clean up verified stale child process on supervisor startup
if [ -f "$NODE_PID_FILE" ]; then
    OLD_NODE_PID=$(cat "$NODE_PID_FILE" 2>/dev/null || echo "")
    if is_backend_node_process "$OLD_NODE_PID"; then
        kill -TERM "$OLD_NODE_PID" 2>/dev/null || true
        sleep 1
    fi
    rm -f "$NODE_PID_FILE"
fi
rm -f "$SOCKET_FILE"

echo "[$(date)] Supervisor daemon started (PID: $$)" >> "$LOG_FILE"

# Auto-install missing @google/generative-ai package in background if absent
if [ ! -d "$BACKEND_DIR/node_modules/@google/generative-ai" ]; then
    echo "[$(date)] Installing missing @google/generative-ai package in background..." >> "$LOG_FILE"
    (cd "$BACKEND_DIR" && npm install --no-audit --no-fund --omit=dev @google/generative-ai >> "$LOG_FILE" 2>&1) &
fi

cleanup() {
    echo "[$(date)] Supervisor daemon exiting..." >> "$LOG_FILE"
    rm -f "$PID_FILE"
    if [ -f "$NODE_PID_FILE" ]; then
        local npid
        npid=$(cat "$NODE_PID_FILE" 2>/dev/null || echo "")
        if is_backend_node_process "$npid"; then
            kill -TERM "$npid" 2>/dev/null || true
            sleep 1
        fi
        rm -f "$NODE_PID_FILE"
    fi
    rm -f "$SOCKET_FILE"
    exit 0
}
trap '' HUP
trap cleanup SIGTERM SIGINT

while true; do
    echo "[$(date)] Starting NestJS backend with --max-old-space-size=256..." >> "$LOG_FILE"
    ALLOWED_ORIGINS="https://allgujaratvankarsamaj.com,https://www.allgujaratvankarsamaj.com" \
    SOCKET_PATH="$SOCKET_FILE" \
    NODE_ENV=production \
    node --max-old-space-size=256 dist/main.js >> "$LOG_FILE" 2>&1 &
    
    NODE_PID=$!
    echo "$NODE_PID" > "$NODE_PID_FILE"
    wait "$NODE_PID" 2>/dev/null
    EXIT_CODE=$?
    rm -f "$NODE_PID_FILE"
    echo "[$(date)] Backend process ($NODE_PID) stopped with exit code $EXIT_CODE. Restarting in 2 seconds..." >> "$LOG_FILE"
    rm -f "$SOCKET_FILE"
    sleep 2
done
