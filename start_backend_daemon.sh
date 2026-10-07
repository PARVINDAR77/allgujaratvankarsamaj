#!/usr/bin/env bash
# ========================================================
# All Gujarat Vankar Samaj - Permanent Backend Supervisor
# Keeps Node.js NestJS backend running 24/7 on Hostinger
# ========================================================

export PATH="/usr/local/bin:/usr/bin:/bin:$HOME/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/next-nest/backend"
SOCKET_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock"
LOG_FILE="$BACKEND_DIR/backend.log"
PID_FILE="$SCRIPT_DIR/backend_daemon.pid"

echo "$$" > "$PID_FILE"

cd "$BACKEND_DIR" || exit 1

# Clean up any orphan node processes
pkill -f "dist/main.js" 2>/dev/null || true
sleep 1
rm -f "$SOCKET_FILE"

echo "[$(date)] Supervisor daemon started (PID: $$)" >> "$LOG_FILE"

cleanup() {
    echo "[$(date)] Supervisor daemon exiting..." >> "$LOG_FILE"
    rm -f "$PID_FILE"
    pkill -f "dist/main.js" 2>/dev/null || true
    rm -f "$SOCKET_FILE"
    exit 0
}
trap cleanup SIGTERM SIGINT

while true; do
    echo "[$(date)] Starting NestJS backend with --max-old-space-size=256..." >> "$LOG_FILE"
    SOCKET_PATH="$SOCKET_FILE" NODE_ENV=production node --max-old-space-size=256 dist/main.js >> "$LOG_FILE" 2>&1
    EXIT_CODE=$?
    echo "[$(date)] Backend process stopped with exit code $EXIT_CODE. Restarting in 2 seconds..." >> "$LOG_FILE"
    rm -f "$SOCKET_FILE"
    sleep 2
done
