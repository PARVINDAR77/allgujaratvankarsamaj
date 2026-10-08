module.exports = {
  apps: [
    {
      name: "vankar-matrimony-backend",
      script: "./dist/main.js",
      instances: 1, // Single instance for Hostinger shared resources
      exec_mode: "fork",
      autorestart: true,
      watch: false,
      max_memory_restart: "450M",
      restart_delay: 2000,
      max_restarts: 100,
      min_uptime: "5s",
      kill_timeout: 4000,
      env: {
        NODE_ENV: "production",
        SOCKET_PATH: "/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock",
      },
      env_production: {
        NODE_ENV: "production",
        SOCKET_PATH: "/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock",
      },
      log_date_format: "YYYY-MM-DD HH:mm:ss Z",
      error_file: "./logs/pm2-error.log",
      out_file: "./logs/pm2-out.log",
      merge_logs: true,
    },
    {
      name: "vankar-watchdog",
      script: "./watchdog.js",
      instances: 1,
      exec_mode: "fork",
      autorestart: true,
      watch: false,
      max_memory_restart: "60M",
      restart_delay: 3000,
      env: {
        NODE_ENV: "production",
        SOCKET_PATH: "/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock",
      },
      env_production: {
        NODE_ENV: "production",
        SOCKET_PATH: "/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock",
      },
      log_date_format: "YYYY-MM-DD HH:mm:ss Z",
      error_file: "./logs/watchdog-error.log",
      out_file: "./logs/watchdog-out.log",
      merge_logs: true,
    },
  ],
};
