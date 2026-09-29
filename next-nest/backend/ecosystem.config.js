module.exports = {
  apps: [
    {
      name: "vankar-matrimony-backend",
      script: "./dist/main.js",
      instances: "max", // Utilize all available CPU cores
      exec_mode: "cluster",
      autorestart: true,
      watch: false, // Do not watch for changes in production
      max_memory_restart: "1G",
      env: {
        NODE_ENV: "development",
      },
      env_production: {
        NODE_ENV: "production",
      },
      log_date_format: "YYYY-MM-DD HH:mm Z",
      error_file: "./logs/pm2-error.log",
      out_file: "./logs/pm2-out.log",
      merge_logs: true,
    },
  ],
};
