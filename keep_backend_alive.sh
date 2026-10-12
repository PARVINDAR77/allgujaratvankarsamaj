#!/usr/bin/env bash
# ========================================================
# All Gujarat Vankar Samaj - Permanent Watchdog & Recovery
# Can be called via Cron, CLI, or Web to guarantee 100% uptime
# ========================================================

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null || true
export PATH="/home/u796269890/bin:$HOME/.nvm/versions/node/v20.20.2/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Safe resolution of script and project directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
if [ -z "$SCRIPT_DIR" ] || [ "$SCRIPT_DIR" = "/" ] || [ ! -d "$SCRIPT_DIR/next-nest/backend" ]; then
    SCRIPT_DIR="/home/u796269890/domains/allgujaratvankarsamaj.com/project_source"
fi

BACKEND_DIR="$SCRIPT_DIR/next-nest/backend"
SOCKET_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock"
TRIGGER_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/restart_trigger.txt"
LOG_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/keep_alive.log"
LOCK_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/keep_alive.lock"

# Single-instance lock to prevent process table exhaustion (max user processes)
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
    log "🔔 Watchdog detected restart trigger file. Restarting backend via PM2..."
    rm -f "$SOCKET_FILE"
    cd "$BACKEND_DIR" 2>/dev/null || true
    pm2 restart ecosystem.config.js --env production >> "$LOG_FILE" 2>&1 || pm2 start ecosystem.config.js --env production >> "$LOG_FILE" 2>&1
    pm2 save >> "$LOG_FILE" 2>&1
    sleep 2
fi

# 2. Test Socket Health with curl
IS_HEALTHY=0
if [ -S "$SOCKET_FILE" ]; then
    HEALTH_RESP=$(curl -s --max-time 3 --unix-socket "$SOCKET_FILE" http://localhost/api/v1/admin/health 2>/dev/null || echo "")
    if echo "$HEALTH_RESP" | grep -q '"status":"ok"'; then
        IS_HEALTHY=1
    fi
fi

# 3. If Healthy, ensure socket permissions and exit
if [ "$IS_HEALTHY" -eq 1 ]; then
    chmod 777 "$SOCKET_FILE" 2>/dev/null || true
    if ! pm2 describe vankar-watchdog >/dev/null 2>&1; then
        cd "$BACKEND_DIR" 2>/dev/null && pm2 start ecosystem.config.js --only vankar-watchdog --env production >> "$LOG_FILE" 2>&1 || true
        pm2 save >> "$LOG_FILE" 2>&1 || true
    fi
    exit 0
fi

# 4. If Unhealthy, perform automatic recovery
log "⚠️ Backend unhealthy (Socket exists: $([ -S "$SOCKET_FILE" ] && echo YES || echo NO)). Initiating PM2 recovery..."

rm -f "$SOCKET_FILE"
cd "$BACKEND_DIR" 2>/dev/null || exit 1

if ! pm2 ping >/dev/null 2>&1; then
    log "ℹ️ PM2 daemon not running. Spawning PM2 daemon..."
    pm2 resurrect >> "$LOG_FILE" 2>&1 || pm2 start ecosystem.config.js --env production >> "$LOG_FILE" 2>&1
else
    log "ℹ️ Restarting all apps in ecosystem.config.js..."
    pm2 restart ecosystem.config.js --env production >> "$LOG_FILE" 2>&1 || pm2 start ecosystem.config.js --env production >> "$LOG_FILE" 2>&1
fi

pm2 save >> "$LOG_FILE" 2>&1

# Wait up to 6 seconds for socket initialization
for i in {1..6}; do
    if [ -S "$SOCKET_FILE" ]; then
        chmod 777 "$SOCKET_FILE" 2>/dev/null || true
        log "✅ Socket initialized and permissions set to 0777."
        exit 0
    fi
    sleep 1
done

log "⚠️ Socket not detected after 6s. Checking PM2 status..."
pm2 status >> "$LOG_FILE" 2>&1 || true
exit 1
