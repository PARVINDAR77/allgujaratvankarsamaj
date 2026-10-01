#!/usr/bin/env bash

set -Eeuo pipefail

# =========================================================
# Docker Deployment Script
# =========================================================

# Resolve project root regardless of where script is run from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
cd "$PROJECT_ROOT"

echo "=========================================="
echo "🚀 Starting Docker Deployment"
echo "=========================================="

echo "📥 Pulling latest code from git..."
git pull origin main

CURRENT_COMMIT=$(git rev-parse --short HEAD)
echo "📌 Target Commit: $CURRENT_COMMIT"

echo "🐳 Building Docker images..."
docker compose build

echo "🔄 Starting Docker containers..."
docker compose up -d

echo "🧹 Cleaning up dangling images to save space..."
docker image prune -f

echo "=========================================="
echo "✅ DOCKER DEPLOYMENT SUCCESSFUL!"
echo "Date: $(date)"
echo "Deployed Commit: $CURRENT_COMMIT"
echo "=========================================="
