#!/usr/bin/env bash
# ========================================================
# All Gujarat Vankar Samaj - Watchdog Cron Script
# Checks health every minute and restarts daemon if down
# ========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/next-nest/backend"
SOCKET_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock"
TRIGGER_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/restart_trigger.txt"
LOG_FILE="$BACKEND_DIR/backend.log"
PID_FILE="$SCRIPT_DIR/backend_daemon.pid"

# 1. If restart triggered via web/admin, restart everything
if [ -f "$TRIGGER_FILE" ]; then
    rm -f "$TRIGGER_FILE"
    echo "[$(date)] Watchdog detected restart trigger. Restarting backend..." >> "$LOG_FILE"
    pkill -f "start_backend_daemon.sh" 2>/dev/null || true
    pkill -f "dist/main.js" 2>/dev/null || true
    rm -f "$SOCKET_FILE" "$PID_FILE"
    sleep 1
fi

# 2. Check if supervisor daemon is running
DAEMON_RUNNING=0
if [ -f "$PID_FILE" ]; then
    DAEMON_PID=$(cat "$PID_FILE")
    if ps -p "$DAEMON_PID" > /dev/null 2>&1; then
        DAEMON_RUNNING=1
    fi
fi

# 3. Check if node process is running
NODE_PID=$(pgrep -f "dist/main.js" | head -n 1)

# 4. Check if socket exists
SOCKET_EXISTS=0
if [ -S "$SOCKET_FILE" ]; then
    SOCKET_EXISTS=1
fi

# If supervisor or node or socket is missing, restart supervisor
if [ "$DAEMON_RUNNING" -eq 0 ] || [ -z "$NODE_PID" ] || [ "$SOCKET_EXISTS" -eq 0 ]; then
    echo "[$(date)] Watchdog: Backend down (daemon=$DAEMON_RUNNING, node=$NODE_PID, socket=$SOCKET_EXISTS). Starting supervisor..." >> "$LOG_FILE"
    pkill -f "start_backend_daemon.sh" 2>/dev/null || true
    pkill -f "dist/main.js" 2>/dev/null || true
    rm -f "$SOCKET_FILE" "$PID_FILE"
    sleep 1
    chmod +x "$SCRIPT_DIR/start_backend_daemon.sh"
    nohup "$SCRIPT_DIR/start_backend_daemon.sh" > /dev/null 2>&1 &
    sleep 3
    [ -S "$SOCKET_FILE" ] && chmod 777 "$SOCKET_FILE" 2>/dev/null || true
    echo "[$(date)] Watchdog: Supervisor started." >> "$LOG_FILE"
fi
