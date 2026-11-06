#!/usr/bin/env bash
# ========================================================
# All Gujarat Vankar Samaj - Permanent Watchdog & Recovery
# Can be called via Cron, CLI, or Web to guarantee 100% uptime
# Safe SRE Watchdog: Anti-Flapping, Verified PIDs, Liveness
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
NODE_PID_FILE="$SCRIPT_DIR/backend_node.pid"
RESTART_STATE_FILE="/home/u796269890/domains/allgujaratvankarsamaj.com/last_restart.time"

# Single-instance lock with PID command line validation and max 120s timeout
if [ -f "$LOCK_FILE" ]; then
    LOCK_AGE=$(( $(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || stat -f %m "$LOCK_FILE" 2>/dev/null || echo 0) ))
    if [ "$LOCK_AGE" -gt 120 ]; then
        rm -f "$LOCK_FILE"
    else
        OLD_PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
            if [ -f "/proc/$OLD_PID/cmdline" ]; then
                if grep -qa "keep_backend_alive" "/proc/$OLD_PID/cmdline" 2>/dev/null; then
                    exit 0
                fi
            elif ps -p "$OLD_PID" -o args= 2>/dev/null | grep -q "keep_backend_alive"; then
                exit 0
            fi
        fi
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

# Anti-Flapping: Minimum interval (in seconds) between watchdog-initiated restarts
COOLDOWN_SECONDS=45
FORCE_RESTART="${FORCE_RESTART:-0}"
for arg in "$@"; do
    if [ "$arg" = "--force" ]; then
        FORCE_RESTART=1
    fi
done

can_restart() {
    if [ -f "$RESTART_STATE_FILE" ]; then
        local last_restart
        last_restart=$(cat "$RESTART_STATE_FILE" 2>/dev/null || echo 0)
        local now
        now=$(date +%s)
        local elapsed=$((now - last_restart))
        local min_wait=$COOLDOWN_SECONDS
        if [ "$FORCE_RESTART" = "1" ]; then
            min_wait=20
        fi
        if [ "$elapsed" -lt "$min_wait" ]; then
            log "⏳ Restart suppressed: within cooldown window (${elapsed}s elapsed, min ${min_wait}s)."
            return 1
        fi
    fi
    return 0
}

record_restart() {
    date +%s > "$RESTART_STATE_FILE" 2>/dev/null || true
}

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

# Terminate only the verified Node process without using broad unverified pkill
stop_backend_node() {
    local stopped=0
    # 1. Target verified PID from NODE_PID_FILE
    if [ -f "$NODE_PID_FILE" ]; then
        local npid
        npid=$(cat "$NODE_PID_FILE" 2>/dev/null || echo "")
        if is_backend_node_process "$npid"; then
            log "Terminating verified backend Node process (PID: $npid) with SIGTERM..."
            kill -TERM "$npid" 2>/dev/null || true
            for _ in {1..5}; do
                if ! kill -0 "$npid" 2>/dev/null; then
                    stopped=1
                    break
                fi
                sleep 1
            done
            if [ "$stopped" -eq 0 ]; then
                log "Process $npid did not exit after 5s. Sending SIGKILL..."
                kill -9 "$npid" 2>/dev/null || true
                stopped=1
            fi
        fi
        rm -f "$NODE_PID_FILE"
    fi

    # 2. Targeted fallback: check if a process is bound to the Unix socket
    if [ "$stopped" -eq 0 ] && [ -S "$SOCKET_FILE" ]; then
        local sock_pid=""
        if command -v fuser >/dev/null 2>&1; then
            sock_pid=$(fuser "$SOCKET_FILE" 2>/dev/null | tr -d ' ' || echo "")
        elif command -v lsof >/dev/null 2>&1; then
            sock_pid=$(lsof -t "$SOCKET_FILE" 2>/dev/null | head -n 1 || echo "")
        fi
        if [ -n "$sock_pid" ] && is_backend_node_process "$sock_pid"; then
            log "Terminating verified process bound to socket (PID: $sock_pid)..."
            kill -TERM "$sock_pid" 2>/dev/null || true
            sleep 2
            kill -9 "$sock_pid" 2>/dev/null || true
        fi
    fi

    rm -f "$SOCKET_FILE"
}

# Clean up any runaway npm / npx processes that exhaust Hostinger CloudLinux LVE limits
pkill -f "npx prisma" 2>/dev/null || true
pkill -f "npm install" 2>/dev/null || true

# 1. Git Deployment Check (rate limited to once every 300s, or immediate on TRIGGER_FILE)
SYNC_ASSETS=0
LAST_GIT_CHECK_FILE="$SCRIPT_DIR/last_git_check.time"
NOW_SEC=$(date +%s)
LAST_GIT_CHECK=$(cat "$LAST_GIT_CHECK_FILE" 2>/dev/null || echo 0)

if [ $((NOW_SEC - LAST_GIT_CHECK)) -gt 300 ] || [ -f "$TRIGGER_FILE" ]; then
    echo "$NOW_SEC" > "$LAST_GIT_CHECK_FILE" 2>/dev/null || true
    if [ -f "$TRIGGER_FILE" ]; then
        rm -f "$TRIGGER_FILE"
        FORCE_RESTART=1
        SYNC_ASSETS=1
        log "🔔 Explicit restart trigger file detected."
    fi
    UPSTREAM_COMMIT=$(cd "$SCRIPT_DIR" && git ls-remote origin main 2>/dev/null | awk '{print $1}')
    LOCAL_COMMIT=$(cd "$SCRIPT_DIR" && git rev-parse HEAD 2>/dev/null)
    if [ -n "$UPSTREAM_COMMIT" ] && [ "$UPSTREAM_COMMIT" != "$LOCAL_COMMIT" ]; then
        log "🚀 New commit detected on main ($UPSTREAM_COMMIT vs $LOCAL_COMMIT). Auto-pulling..."
        (cd "$SCRIPT_DIR" && git fetch origin main 2>&1 && git reset --hard origin/main 2>&1) >> "$LOG_FILE" 2>&1 || true
        chmod +x "$SCRIPT_DIR/keep_backend_alive.sh" "$SCRIPT_DIR/start_backend_daemon.sh" 2>/dev/null || true
        FORCE_RESTART=1
        SYNC_ASSETS=1
    fi
fi

# Ensure web proxy, .htaccess, and management scripts are synced to public_html only on explicit deployment/trigger
if [ "$SYNC_ASSETS" -eq 1 ] && [ -d "/home/u796269890/domains/allgujaratvankarsamaj.com/public_html" ]; then
    log "📦 Syncing web assets and scripts to public_html..."
    [ -f "$SCRIPT_DIR/application/build/web/restart_backend.php" ] && cp -f "$SCRIPT_DIR/application/build/web/restart_backend.php" /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/restart_backend.php 2>/dev/null || true
    [ -f "$SCRIPT_DIR/application/build/web/api_proxy.php" ] && cp -f "$SCRIPT_DIR/application/build/web/api_proxy.php" /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/api_proxy.php 2>/dev/null || true
    [ -f "$SCRIPT_DIR/application/build/web/.htaccess" ] && cp -f "$SCRIPT_DIR/application/build/web/.htaccess" /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/.htaccess 2>/dev/null || true
    [ -f "$SCRIPT_DIR/application/build/web/index.html" ] && cp -f "$SCRIPT_DIR/application/build/web/index.html" /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/index.html 2>/dev/null || true
    [ -f "$SCRIPT_DIR/application/build/web/main.dart.js" ] && cp -f "$SCRIPT_DIR/application/build/web/main.dart.js" /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/main.dart.js 2>/dev/null || true
    [ -f "$SCRIPT_DIR/application/build/web/flutter_bootstrap.js" ] && cp -f "$SCRIPT_DIR/application/build/web/flutter_bootstrap.js" /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/flutter_bootstrap.js 2>/dev/null || true
    [ -f "$SCRIPT_DIR/application/build/web/flutter.js" ] && cp -f "$SCRIPT_DIR/application/build/web/flutter.js" /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/flutter.js 2>/dev/null || true
    [ -d "$SCRIPT_DIR/application/build/web/assets" ] && cp -rf "$SCRIPT_DIR/application/build/web/assets" /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/ 2>/dev/null || true
    [ -d "$SCRIPT_DIR/application/build/web/canvaskit" ] && cp -rf "$SCRIPT_DIR/application/build/web/canvaskit" /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/ 2>/dev/null || true
    mkdir -p /home/u796269890/domains/allgujaratvankarsamaj.com/uploads 2>/dev/null || true
    ln -sfn /home/u796269890/domains/allgujaratvankarsamaj.com/uploads /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/uploads 2>/dev/null || true
    ln -sfn /home/u796269890/domains/allgujaratvankarsamaj.com/uploads "$BACKEND_DIR/uploads" 2>/dev/null || true
    [ -d "$SCRIPT_DIR/next-nest/frontend/out/_next" ] && cp -rf "$SCRIPT_DIR/next-nest/frontend/out/_next" /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/ 2>/dev/null || true
    [ -d "$SCRIPT_DIR/next-nest/frontend/out/admin" ] && cp -rf "$SCRIPT_DIR/next-nest/frontend/out/admin" /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/ 2>/dev/null || true
fi

# Ensure basic critical symlink and proxy exist (lightweight check, no file copy)
if [ -d "/home/u796269890/domains/allgujaratvankarsamaj.com/public_html" ]; then
    if [ ! -f "/home/u796269890/domains/allgujaratvankarsamaj.com/public_html/api_proxy.php" ]; then
        cp -f "$SCRIPT_DIR/application/build/web/api_proxy.php" /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/api_proxy.php 2>/dev/null || true
    fi
    if [ ! -f "/home/u796269890/domains/allgujaratvankarsamaj.com/public_html/restart_backend.php" ]; then
        cp -f "$SCRIPT_DIR/application/build/web/restart_backend.php" /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/restart_backend.php 2>/dev/null || true
    fi
fi

# 2. Test Socket Health with dedicated Liveness endpoint (2-strike check, 10s budget)
IS_HEALTHY=0
LIVENESS_URL="http://localhost/api/v1/health/liveness"

check_liveness_probe() {
    local resp=""
    if [ -S "$SOCKET_FILE" ]; then
        resp=$(curl -s --max-time 6 --unix-socket "$SOCKET_FILE" "$LIVENESS_URL" 2>/dev/null || echo "")
    fi
    if [ -z "$resp" ]; then
        resp=$(curl -s --max-time 6 "http://127.0.0.1:3000/api/v1/health/liveness" 2>/dev/null || echo "")
    fi
    if echo "$resp" | grep -q '"status"' && echo "$resp" | grep -q '"ok"'; then
        return 0
    fi
    return 1
}

if [ -S "$SOCKET_FILE" ] && [ "$FORCE_RESTART" -ne 1 ]; then
    if check_liveness_probe; then
        IS_HEALTHY=1
    else
        log "⚠️ First liveness probe failed or timed out. Waiting 3 seconds before strike 2..."
        sleep 3
        if check_liveness_probe; then
            IS_HEALTHY=1
            log "✅ Second liveness probe succeeded. Backend is healthy."
        else
            log "❌ Second consecutive probe failed. Backend is confirmed unresponsive."
        fi
    fi
fi

# 3. If Healthy, ensure socket permissions and exit
if [ "$IS_HEALTHY" -eq 1 ]; then
    chmod 777 "$SOCKET_FILE" 2>/dev/null || true
    exit 0
fi

# 4. Check Daemon Supervisor status
DAEMON_RUNNING=0
if [ -f "$DAEMON_PID_FILE" ]; then
    DPID=$(cat "$DAEMON_PID_FILE" 2>/dev/null || echo "")
    if [ -n "$DPID" ] && kill -0 "$DPID" 2>/dev/null; then
        if [ -f "/proc/$DPID/cmdline" ]; then
            if grep -qa "start_backend_daemon" "/proc/$DPID/cmdline" 2>/dev/null; then
                DAEMON_RUNNING=1
            fi
        elif ps -p "$DPID" -o args= 2>/dev/null | grep -q "start_backend_daemon"; then
            DAEMON_RUNNING=1
        fi
    fi
fi

# 5. Recovery Execution
log "⚠️ Backend confirmed unhealthy (Socket exists: $([ -S "$SOCKET_FILE" ] && echo YES || echo NO)). Initiating recovery..."

if [ "$DAEMON_RUNNING" -eq 1 ] && [ -S "$SOCKET_FILE" ]; then
    if ! can_restart; then
        log "⏳ Backend not responding, but currently inside restart cooldown/grace period. Allowing supervisor daemon (PID: $DPID) time to boot."
        exit 0
    fi
    log "ℹ️ Supervisor daemon loop is alive (PID: $DPID). Restarting child process..."
    record_restart
    stop_backend_node
else
    # Socket is missing OR supervisor is offline: Cleanly respawn supervisor daemon
    log "ℹ️ Backend socket missing or supervisor offline. Cleanly respawning supervisor daemon..."
    record_restart
    # Kill any and all duplicate supervisor loops and orphaned node processes
    pkill -9 -f "start_backend_daemon" 2>/dev/null || true
    pkill -9 -f "dist/main\.js" 2>/dev/null || true
    rm -f "$DAEMON_PID_FILE" "$NODE_PID_FILE" "$SOCKET_FILE" "$SCRIPT_DIR/backend_daemon.lock"
    sleep 1
    nohup bash "$SCRIPT_DIR/start_backend_daemon.sh" >> "$BACKEND_DIR/backend.log" 2>&1 &
fi

# Wait up to 10 seconds for socket initialization
for i in {1..10}; do
    if [ -S "$SOCKET_FILE" ]; then
        chmod 777 "$SOCKET_FILE" 2>/dev/null || true
        log "✅ Socket initialized and permissions set to 0777 (took ${i}s)."
        exit 0
    fi
    sleep 1
done

log "⚠️ Socket not detected after 10s. Checking recent logs..."
tail -n 25 "$BACKEND_DIR/backend.log" >> "$LOG_FILE" 2>&1 || true
exit 1
