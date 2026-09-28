module.exports = {
  apps: [
    {
      name: "matrimony-backend",
      script: "npm",
      args: "run start:prod",
      cwd: "./next-nest/backend",
      env_production: { NODE_ENV: "production" }
    }
  ]
};
