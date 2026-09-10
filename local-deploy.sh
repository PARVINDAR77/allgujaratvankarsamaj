#!/usr/bin/env bash

# ==============================================================================
# Vankar Samaj Matrimony - Local Build and Deployment Script
# ==============================================================================

set -e

echo ""
echo "======================================================================"
echo "   VANKAR SAMAJ MATRIMONY -- LOCAL BUILD AND DOCKER DEPLOYMENT        "
echo "======================================================================"
echo ""

# Step 1: Build NestJS Backend
echo "--> [1/4] Building NestJS Backend..."
cd next-nest/backend
npm run build
cd ../..
echo "✓ NestJS Backend build completed successfully."
echo ""

# Step 2: Build Next.js Frontend
echo "--> [2/4] Building Next.js Frontend..."
cd next-nest/frontend
npm run build
cd ../..
echo "✓ Next.js Frontend build completed successfully."
echo ""

# Step 3: Run Docker Compose
echo "--> [3/4] Starting Docker Containers (PostgreSQL, Backend, Frontend)..."
docker compose down --remove-orphans
docker compose up -d --build
echo "✓ Docker containers launched in detached mode."
echo ""

# Step 4: Health Check Verification
echo "--> [4/4] Verifying System Services Health..."
sleep 3

echo ""
echo "======================================================================"
echo "             LOCAL DEPLOYMENT SUCCESSFUL AND READY!                   "
echo "======================================================================"
echo ""
echo " ADMIN PANEL DASHBOARD:"
echo "    http://localhost:3001/admin/dashboard"
echo ""
echo " ADMIN LOGIN:"
echo "    http://localhost:3001/admin/login"
echo ""
echo " FRONTEND HOME PAGE:"
echo "    http://localhost:3001"
echo ""
echo " NESTJS API BASE URL:"
echo "    http://localhost:3000/api/v1"
echo ""
echo " BACKEND HEALTH CHECK:"
echo "    http://localhost:3000/api/v1/health"
echo ""
echo " SWAGGER API DOCS:"
echo "    http://localhost:3000/api/docs"
echo ""
echo " POSTGRESQL DATABASE:"
echo "    localhost:5432 (User: postgres, Database: vankar_matrimony)"
echo ""
echo "======================================================================"
echo " Tip: Re-run './local-deploy.sh' or '.\local-deploy.ps1' to refresh."
echo "======================================================================"
echo ""
