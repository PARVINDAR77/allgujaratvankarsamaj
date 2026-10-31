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

# Single-instance lock with PID command line validation to prevent cron overlap
if [ -f "$LOCK_FILE" ]; then
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
    if [ "$FORCE_RESTART" = "1" ]; then
        return 0
    fi
    if [ -f "$RESTART_STATE_FILE" ]; then
        local last_restart
        last_restart=$(cat "$RESTART_STATE_FILE" 2>/dev/null || echo 0)
        local now
        now=$(date +%s)
        local elapsed=$((now - last_restart))
        if [ "$elapsed" -lt "$COOLDOWN_SECONDS" ]; then
            log "⏳ Restart suppressed: within cooldown window (${elapsed}s elapsed, min ${COOLDOWN_SECONDS}s)."
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

# 1. Check if restart trigger was requested (e.g. from web UI or deploy)
if [ -f "$TRIGGER_FILE" ]; then
    rm -f "$TRIGGER_FILE"
    if can_restart; then
        log "🔔 Restart trigger file detected. Initiating graceful backend restart..."
        record_restart
        stop_backend_node
        sleep 2
    else
        log "⚠️ Restart trigger file ignored due to active cooldown window."
    fi
fi

# 2. Test Socket Health with dedicated Liveness endpoint (2-strike check, 10s budget)
IS_HEALTHY=0
LIVENESS_URL="http://localhost/api/v1/health/liveness"

check_liveness_probe() {
    local resp
    resp=$(curl -s --max-time 10 --unix-socket "$SOCKET_FILE" "$LIVENESS_URL" 2>/dev/null || echo "")
    if echo "$resp" | grep -q '"status"' && echo "$resp" | grep -q '"ok"'; then
        return 0
    fi
    return 1
}

if [ -S "$SOCKET_FILE" ]; then
    if check_liveness_probe; then
        IS_HEALTHY=1
    else
        log "⚠️ First liveness probe failed or timed out. Waiting 3 seconds before strike 2..."
        sleep 3
        if check_liveness_probe; then
            IS_HEALTHY=1
            log "✅ Second liveness probe succeeded. Backend is healthy."
        else
            log "❌ Second consecutive liveness probe failed. Backend is confirmed unresponsive."
        fi
    fi
fi

# 3. If Healthy, ensure socket permissions and exit
if [ "$IS_HEALTHY" -eq 1 ]; then
    chmod 777 "$SOCKET_FILE" 2>/dev/null || true
    exit 0
fi

# 4. If Unhealthy, check startup grace period before triggering restart
if ! can_restart; then
    log "⏳ Backend not responding, but currently inside restart cooldown/grace period. Allowing more time to boot."
    exit 0
fi

# 5. Recovery: Daemon Supervisor & Child Management
log "⚠️ Backend confirmed unhealthy (Socket exists: $([ -S "$SOCKET_FILE" ] && echo YES || echo NO)). Initiating daemon recovery..."
record_restart

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

if [ "$DAEMON_RUNNING" -eq 1 ]; then
    log "ℹ️ Supervisor daemon loop is alive (PID: $DPID). Restarting child process..."
    stop_backend_node
else
    log "ℹ️ Supervisor daemon not running. Starting new supervisor daemon..."
    stop_backend_node
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
