/**
 * PM2 Ecosystem Configuration for Isolated Staging Backend
 * Project: All Gujarat Vankar Samaj Matrimony
 *
 * Strict Isolation Controls:
 * - Dedicated Process Name: vankar-backend-staging
 * - Explicit CWD: /home/u796269890/staging/backend
 * - TCP Loopback: 127.0.0.1:3001 (SOCKET_PATH omitted so main.ts binds to TCP)
 * - Isolated Log Directory: /home/u796269890/staging/logs/
 */

module.exports = {
  apps: [
    {
      name: "vankar-backend-staging",
      script: "./dist/main.js",
      cwd: "/home/u796269890/staging/backend",
      instances: 1,
      exec_mode: "fork",
      autorestart: true,
      watch: false,
      max_memory_restart: "450M",
      restart_delay: 2000,
      min_uptime: "5s",
      kill_timeout: 4000,
      env: {
        NODE_ENV: "staging",
        PORT: 3001,
        ALLOWED_ORIGINS: "https://staging.allgujaratvankarsamaj.com",
      },
      log_date_format: "YYYY-MM-DD HH:mm:ss Z",
      error_file: "/home/u796269890/staging/logs/pm2-staging-error.log",
      out_file: "/home/u796269890/staging/logs/pm2-staging-out.log",
      merge_logs: true,
    },
  ],
};
