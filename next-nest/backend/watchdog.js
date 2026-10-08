// ========================================================
// All Gujarat Vankar Samaj - Persistent Internal Watchdog
// Runs under PM2 to monitor NestJS backend health 24/7
// ========================================================

const http = require('http');
const fs = require('fs');
const { exec } = require('child_process');
const path = require('path');

const SOCKET_PATH = process.env.SOCKET_PATH || '/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock';
const TRIGGER_FILE = '/home/u796269890/domains/allgujaratvankarsamaj.com/restart_trigger.txt';
const LOG_FILE = path.join(__dirname, 'logs', 'watchdog.log');

function log(msg) {
  const line = `[${new Date().toISOString()}] ${msg}\n`;
  try {
    fs.appendFileSync(LOG_FILE, line);
  } catch (_) {}
  console.log(msg);
}

let consecutiveFailures = 0;
let isRestarting = false;

function checkSocketHealth() {
  return new Promise((resolve) => {
    if (!fs.existsSync(SOCKET_PATH)) {
      return resolve({ ok: false, reason: 'Socket file missing' });
    }

    const req = http.get({
      socketPath: SOCKET_PATH,
      path: '/api/v1/admin/health',
      timeout: 4000,
    }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        if (res.statusCode === 200) {
          resolve({ ok: true, statusCode: res.statusCode });
        } else {
          resolve({ ok: false, reason: `HTTP ${res.statusCode}: ${data}` });
        }
      });
    });

    req.on('timeout', () => {
      req.destroy();
      resolve({ ok: false, reason: 'Request timed out after 4s' });
    });

    req.on('error', (err) => {
      resolve({ ok: false, reason: err.message });
    });
  });
}

async function restartBackend(reason) {
  if (isRestarting) return;
  isRestarting = true;
  log(`⚠️ Restarting vankar-matrimony-backend. Reason: ${reason}`);

  try {
    if (fs.existsSync(SOCKET_PATH)) {
      try { fs.unlinkSync(SOCKET_PATH); } catch (_) {}
    }

    exec('pm2 restart vankar-matrimony-backend --update-env', (err, stdout, stderr) => {
      if (err) {
        log(`❌ PM2 restart failed: ${err.message}. Trying pm2 start...`);
        exec('pm2 start ecosystem.config.js --env production', () => {
          ensureSocketPermissions();
          isRestarting = false;
        });
      } else {
        log(`✅ PM2 restart initiated: ${stdout.trim()}`);
        setTimeout(() => {
          ensureSocketPermissions();
          isRestarting = false;
        }, 3000);
      }
    });
  } catch (err) {
    log(`❌ Error during restartBackend: ${err.message}`);
    isRestarting = false;
  }
}

function ensureSocketPermissions() {
  try {
    if (fs.existsSync(SOCKET_PATH)) {
      fs.chmodSync(SOCKET_PATH, 0o777);
      log(`🔒 Ensured socket permissions 0777 on ${SOCKET_PATH}`);
    }
  } catch (err) {
    log(`⚠️ Could not chmod socket: ${err.message}`);
  }
}

// 1. Health check loop every 15 seconds
async function healthLoop() {
  if (!isRestarting) {
    const result = await checkSocketHealth();
    if (result.ok) {
      if (consecutiveFailures > 0) {
        log(`✅ Backend recovered and responding normally.`);
      }
      consecutiveFailures = 0;
      ensureSocketPermissions();
    } else {
      consecutiveFailures++;
      log(`⚠️ Backend health check failed (${consecutiveFailures}/2): ${result.reason}`);
      if (consecutiveFailures >= 2) {
        await restartBackend(`Consecutive failures (${consecutiveFailures}): ${result.reason}`);
        consecutiveFailures = 0;
      }
    }
  }
  setTimeout(healthLoop, 15000);
}

// 2. Trigger file check every 3 seconds
function triggerLoop() {
  try {
    if (fs.existsSync(TRIGGER_FILE)) {
      log(`🔔 Detected external restart trigger file.`);
      try { fs.unlinkSync(TRIGGER_FILE); } catch (_) {}
      restartBackend('External trigger file detected');
    }
  } catch (_) {}
  setTimeout(triggerLoop, 3000);
}

log(`🚀 Vankar Samaj Internal Watchdog started (PID: ${process.pid})`);
healthLoop();
triggerLoop();
