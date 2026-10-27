#!/usr/bin/env bash
# ========================================================
# All Gujarat Vankar Samaj - Permanent Watchdog & Recovery
# Can be called via Cron, CLI, or Web to guarantee 100% uptime
# Lightweight CloudLinux LVE compliant (Thread pool = 2)
# ========================================================

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null || true
export PATH="/home/u796269890/bin:$HOME/.nvm/versions/node/v20.20.2/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
if [ -z "$SCRIPT_DIR" ] || [ "$SCRIPT_DIR" = "/" ] || [ ! -d "$SCRIPT_DIR/next-nest/backend" ]; then
    SCRIPT_DIR="/home/u796269890/domains/allgujaratvankarsamaj.com/project_source"
fi

BACKEND_DIR="$SCRIPT_DIR/next-nest/backend"
SOCKET_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock"
TRIGGER_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/restart_trigger.txt"
LOG_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/keep_alive.log"
LOCK_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/keep_alive.lock"
DAEMON_PID_FILE="$SCRIPT_DIR/backend_daemon.pid"

# Single-instance lock to prevent process table exhaustion
if [ -f "$LOCK_FILE" ]; then
    OLD_PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        exit 0
    fi
fi
echo $$ > "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT INT TERM

# Keep log file small (< 300 KB)
if [ -f "$LOG_FILE" ] && [ $(wc -c < "$LOG_FILE" 2>/dev/null || echo 0) -gt 300000 ]; then
    tail -n 200 "$LOG_FILE" > "$LOG_FILE.tmp" 2>/dev/null && mv -f "$LOG_FILE.tmp" "$LOG_FILE" 2>/dev/null || true
fi

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE" 2>/dev/null || true
}

# 1. Check if restart trigger was requested
if [ -f "$TRIGGER_FILE" ]; then
    rm -f "$TRIGGER_FILE"
    log "🔔 Watchdog detected restart trigger file. Restarting backend process..."
    pkill -f "dist/main.js" 2>/dev/null || true
    sleep 2
fi

# 2. Test Socket Health with curl
IS_HEALTHY=0
if [ -S "$SOCKET_FILE" ]; then
    HEALTH_RESP=$(curl -s --max-time 3 --unix-socket "$SOCKET_FILE" http://localhost/api/v1/health 2>/dev/null || echo "")
    if echo "$HEALTH_RESP" | grep -q '"status"'; then
        IS_HEALTHY=1
    fi
fi

# 3. If Healthy, ensure socket permissions and exit
if [ "$IS_HEALTHY" -eq 1 ]; then
    chmod 777 "$SOCKET_FILE" 2>/dev/null || true
    exit 0
fi

# 4. If Unhealthy, check if daemon supervisor is alive
log "⚠️ Backend unhealthy (Socket exists: $([ -S "$SOCKET_FILE" ] && echo YES || echo NO)). Initiating lightweight daemon recovery..."

DAEMON_RUNNING=0
if [ -f "$DAEMON_PID_FILE" ]; then
    DPID=$(cat "$DAEMON_PID_FILE" 2>/dev/null || echo "")
    if [ -n "$DPID" ] && kill -0 "$DPID" 2>/dev/null; then
        DAEMON_RUNNING=1
    fi
fi

if [ "$DAEMON_RUNNING" -eq 1 ]; then
    log "ℹ️ Daemon loop is alive (PID: $DPID). Restarting backend child..."
    pkill -f "dist/main.js" 2>/dev/null || true
else
    log "ℹ️ Daemon loop not running. Starting new supervisor daemon..."
    pkill -f "start_backend_daemon.sh" 2>/dev/null || true
    pkill -f "dist/main.js" 2>/dev/null || true
    rm -f "$SOCKET_FILE"
    nohup bash "$SCRIPT_DIR/start_backend_daemon.sh" >> "$BACKEND_DIR/backend.log" 2>&1 &
fi

# Wait up to 6 seconds for socket initialization
for i in {1..6}; do
    if [ -S "$SOCKET_FILE" ]; then
        chmod 777 "$SOCKET_FILE" 2>/dev/null || true
        log "✅ Socket initialized and permissions set to 0777."
        exit 0
    fi
    sleep 1
done

log "⚠️ Socket not detected after 6s. Checking logs..."
tail -n 20 "$BACKEND_DIR/backend.log" >> "$LOG_FILE" 2>&1 || true
exit 1
