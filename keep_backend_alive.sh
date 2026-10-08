#!/usr/bin/env bash
# ========================================================
# All Gujarat Vankar Samaj - Permanent Watchdog & Recovery
# Can be called via Cron, CLI, or Web to guarantee 100% uptime
# ========================================================

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null || true
export PATH="/home/u796269890/bin:$HOME/.nvm/versions/node/v20.20.2/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/next-nest/backend"
SOCKET_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock"
TRIGGER_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/restart_trigger.txt"
LOG_FILE="$SCRIPT_DIR/keep_alive.log"

# Keep log file small (< 500 KB)
if [ -f "$LOG_FILE" ] && [ $(wc -c < "$LOG_FILE") -gt 500000 ]; then
    tail -n 200 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# 1. Check if restart trigger was requested
if [ -f "$TRIGGER_FILE" ]; then
    rm -f "$TRIGGER_FILE"
    log "🔔 Watchdog detected restart trigger file. Restarting backend via PM2..."
    rm -f "$SOCKET_FILE"
    cd "$BACKEND_DIR"
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
    # Check if watchdog PM2 process is running too
    if ! pm2 describe vankar-watchdog >/dev/null 2>&1; then
        cd "$BACKEND_DIR" && pm2 start ecosystem.config.js --only vankar-watchdog --env production >> "$LOG_FILE" 2>&1
        pm2 save >> "$LOG_FILE" 2>&1
    fi
    exit 0
fi

# 4. If Unhealthy, perform automatic recovery
log "⚠️ Backend unhealthy (Socket exists: $([ -S "$SOCKET_FILE" ] && echo YES || echo NO)). Initiating PM2 recovery..."

# Clean up stale socket file
rm -f "$SOCKET_FILE"

cd "$BACKEND_DIR"

# Check if PM2 daemon is running
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
pm2 status >> "$LOG_FILE" 2>&1
exit 1
