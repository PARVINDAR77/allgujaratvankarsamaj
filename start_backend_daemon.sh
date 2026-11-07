#!/usr/bin/env bash
# ========================================================
# All Gujarat Vankar Samaj - Permanent Backend Supervisor
# Keeps Node.js NestJS backend running 24/7 on Hostinger
# Safe Process Lifecycle: Precise Child PID Tracking
# ========================================================

ulimit -v unlimited 2>/dev/null || true
ulimit -m unlimited 2>/dev/null || true
ulimit -s 8192 2>/dev/null || true

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null || true
export PATH="/home/u796269890/.nvm/versions/node/v20.20.2/bin:/usr/local/bin:/usr/bin:/bin:$HOME/bin:$PATH"
export UV_THREADPOOL_SIZE=2
export PRISMA_CLIENT_ENGINE_TYPE="library"
export NODE_OPTIONS="--max-old-space-size=256"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/next-nest/backend"
SOCKET_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock"
LOG_FILE="$BACKEND_DIR/backend.log"
PID_FILE="$SCRIPT_DIR/backend_daemon.pid"
NODE_PID_FILE="$SCRIPT_DIR/backend_node.pid"
LOCK_FILE="$SCRIPT_DIR/backend_daemon.lock"

# 1. Acquire exclusive supervisor lock to prevent duplicate while-true loops
if command -v flock >/dev/null 2>&1; then
    exec 9>"$LOCK_FILE"
    if ! flock -n 9; then
        echo "[$(date)] Supervisor daemon is already active (locked via flock). Exiting duplicate process $$." >> "$LOG_FILE"
        exit 0
    fi
fi

# 2. Strict PID validation fallback
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE" 2>/dev/null || echo "")
    if [ -n "$OLD_PID" ] && [ "$OLD_PID" != "$$" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        if [ -f "/proc/$OLD_PID/cmdline" ] && grep -qa "start_backend_daemon" "/proc/$OLD_PID/cmdline" 2>/dev/null; then
            echo "[$(date)] Supervisor daemon already active (PID: $OLD_PID). Exiting duplicate process $$." >> "$LOG_FILE"
            exit 0
        elif ps -p "$OLD_PID" -o args= 2>/dev/null | grep -q "start_backend_daemon"; then
            echo "[$(date)] Supervisor daemon already active (PID: $OLD_PID). Exiting duplicate process $$." >> "$LOG_FILE"
            exit 0
        fi
    fi
fi

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
# Terminate any stray orphaned node processes to guarantee strict single-process operation
pkill -9 -f "dist/main\.js" 2>/dev/null || true
rm -f "$SOCKET_FILE"

echo "[$(date)] Supervisor daemon started (PID: $$)" >> "$LOG_FILE"


cleanup() {
    echo "[$(date)] Supervisor daemon exiting..." >> "$LOG_FILE"
    rm -f "$PID_FILE"
    rm -f "$LOCK_FILE"
    if [ -f "$NODE_PID_FILE" ]; then
        local npid
        npid=$(cat "$NODE_PID_FILE" 2>/dev/null || echo "")
        if is_backend_node_process "$npid"; then
            kill -TERM "$npid" 2>/dev/null || true
            sleep 1
        fi
        rm -f "$NODE_PID_FILE"
    fi
    pkill -9 -f "dist/main\.js" 2>/dev/null || true
    rm -f "$SOCKET_FILE"
    exit 0
}
trap '' HUP
trap cleanup SIGTERM SIGINT

FAST_CRASH_COUNT=0
while true; do
    START_TIME=$(date +%s)
    # Ensure no duplicate/rogue Node process is lingering before launch
    OTHER_PIDS=$(pgrep -f "dist/main\.js" 2>/dev/null || echo "")
    if [ -n "$OTHER_PIDS" ]; then
        for opid in $OTHER_PIDS; do
            kill -9 "$opid" 2>/dev/null || true
        done
        sleep 1
    fi
    rm -f "$SOCKET_FILE"

    echo "[$(date)] Starting NestJS backend with --disable-wasm-trap-handler --max-semi-space-size=2 --max-old-space-size=256 --expose-gc, and PORT=3000..." >> "$LOG_FILE"
    ALLOWED_ORIGINS="https://allgujaratvankarsamaj.com,https://www.allgujaratvankarsamaj.com" \
    SOCKET_PATH="$SOCKET_FILE" \
    PORT=3000 \
    NODE_ENV=production \
    node --disable-wasm-trap-handler --max-semi-space-size=2 --max-old-space-size=256 --expose-gc dist/main.js >> "$LOG_FILE" 2>&1 &
    
    NODE_PID=$!
    echo "$NODE_PID" > "$NODE_PID_FILE"
    wait "$NODE_PID" 2>/dev/null
    EXIT_CODE=$?
    rm -f "$NODE_PID_FILE"
    rm -f "$SOCKET_FILE"
    
    UPTIME=$(( $(date +%s) - START_TIME ))
    if [ "$UPTIME" -lt 10 ]; then
        FAST_CRASH_COUNT=$((FAST_CRASH_COUNT + 1))
    else
        FAST_CRASH_COUNT=0
    fi
    
    if [ "$FAST_CRASH_COUNT" -ge 3 ]; then
        echo "[$(date)] Backend crashed $FAST_CRASH_COUNT times rapidly. Backing off for 20 seconds..." >> "$LOG_FILE"
        sleep 20
        FAST_CRASH_COUNT=0
    else
        echo "[$(date)] Backend process ($NODE_PID) stopped with exit code $EXIT_CODE (uptime: ${UPTIME}s). Restarting in 4 seconds..." >> "$LOG_FILE"
        sleep 4
    fi
done
