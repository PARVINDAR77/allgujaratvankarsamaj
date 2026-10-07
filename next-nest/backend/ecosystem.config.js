module.exports = {
  apps: [
    {
      name: "vankar-matrimony-backend",
      script: "./dist/main.js",
      instances: 1, // Restrict to 1 instance for Hostinger shared resources
      exec_mode: "fork",
      autorestart: true,
      watch: false, // Do not watch for changes in production
      max_memory_restart: "500M",
      env: {
        NODE_ENV: "development",
        SOCKET_PATH: "/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock",
      },
      env_production: {
        NODE_ENV: "production",
        SOCKET_PATH: "/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock",
      },
      log_date_format: "YYYY-MM-DD HH:mm Z",
      error_file: "./logs/pm2-error.log",
      out_file: "./logs/pm2-out.log",
      merge_logs: true,
    },
  ],
};
