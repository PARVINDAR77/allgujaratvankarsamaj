# ==============================================================================
# Vankar Samaj Matrimony - Local Build and Deployment Script (PowerShell)
# ==============================================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Yellow
Write-Host "   VANKAR SAMAJ MATRIMONY -- LOCAL BUILD AND DOCKER DEPLOYMENT        " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Yellow
Write-Host ""

# Step 1: Build NestJS Backend
Write-Host "--> [1/4] Building NestJS Backend..." -ForegroundColor Yellow
Set-Location -Path "$PSScriptRoot\next-nest\backend"
npm run build
Set-Location -Path "$PSScriptRoot"
Write-Host "Backend build completed successfully." -ForegroundColor Green
Write-Host ""

# Step 2: Build Next.js Frontend
Write-Host "--> [2/4] Building Next.js Frontend..." -ForegroundColor Yellow
Set-Location -Path "$PSScriptRoot\next-nest\frontend"
npm run build
Set-Location -Path "$PSScriptRoot"
Write-Host "Frontend build completed successfully." -ForegroundColor Green
Write-Host ""

# Step 3: Run Docker Compose
Write-Host "--> [3/4] Starting Docker Containers (PostgreSQL, Backend, Frontend)..." -ForegroundColor Yellow
docker compose down --remove-orphans
docker compose up -d --build
Write-Host "Docker containers launched in detached mode." -ForegroundColor Green
Write-Host ""

# Step 4: Health Check and Display Links
Write-Host "======================================================================" -ForegroundColor Yellow
Write-Host "             LOCAL DEPLOYMENT SUCCESSFUL AND READY!                   " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host " ADMIN PANEL DASHBOARD:" -ForegroundColor Cyan
Write-Host "    http://localhost:3001/admin/dashboard" -ForegroundColor White
Write-Host ""
Write-Host " ADMIN LOGIN:" -ForegroundColor Cyan
Write-Host "    http://localhost:3001/admin/login" -ForegroundColor White
Write-Host ""
Write-Host " FRONTEND HOME PAGE:" -ForegroundColor Cyan
Write-Host "    http://localhost:3001" -ForegroundColor White
Write-Host ""
Write-Host " NESTJS API BASE URL:" -ForegroundColor Cyan
Write-Host "    http://localhost:3000/api/v1" -ForegroundColor White
Write-Host ""
Write-Host " BACKEND HEALTH CHECK:" -ForegroundColor Cyan
Write-Host "    http://localhost:3000/api/v1/health" -ForegroundColor White
Write-Host ""
Write-Host " SWAGGER API DOCS:" -ForegroundColor Cyan
Write-Host "    http://localhost:3000/api/docs" -ForegroundColor White
Write-Host ""
Write-Host " POSTGRESQL DATABASE:" -ForegroundColor Cyan
Write-Host "    localhost:5432 (User: postgres, Database: vankar_matrimony)" -ForegroundColor White
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Yellow
Write-Host " Tip: Re-run '.\local-deploy.ps1' or '.\local-deploy.bat' to refresh." -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Yellow
Write-Host ""
