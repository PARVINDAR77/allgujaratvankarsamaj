@echo off
REM ==============================================================================
REM Vankar Samaj Matrimony — Local Build & Deployment Batch File for Windows
REM ==============================================================================

echo.
echo ======================================================================
echo    VANKAR SAMAJ MATRIMONY -- LOCAL BUILD AND DOCKER DEPLOYMENT
echo ======================================================================
echo.

echo --> [1/4] Building NestJS Backend...
cd next-nest\backend
call npm run build
if %errorlevel% neq 0 (
    echo [ERROR] Backend build failed.
    exit /b %errorlevel%
)
cd ..\..
echo [OK] Backend build completed.
echo.

echo --> [2/4] Building Next.js Frontend...
cd next-nest\frontend
call npm run build
if %errorlevel% neq 0 (
    echo [ERROR] Frontend build failed.
    exit /b %errorlevel%
)
cd ..\..
echo [OK] Frontend build completed.
echo.

echo --> [3/4] Starting Docker Containers...
docker compose down --remove-orphans
docker compose up -d --build
if %errorlevel% neq 0 (
    echo [ERROR] Docker compose failed.
    exit /b %errorlevel%
)
echo [OK] Docker containers launched.
echo.

echo ======================================================================
echo              LOCAL DEPLOYMENT SUCCESSFUL AND READY!
echo ======================================================================
echo.
echo  ADMIN PANEL DASHBOARD:
echo     http://localhost:3001/admin/dashboard
echo.
echo  ADMIN LOGIN:
echo     http://localhost:3001/admin/login
echo.
echo  FRONTEND HOME PAGE:
echo     http://localhost:3001
echo.
echo  NESTJS API BASE URL:
echo     http://localhost:3000/api/v1
echo.
echo  BACKEND HEALTH CHECK:
echo     http://localhost:3000/api/v1/health
echo.
echo  SWAGGER API DOCS:
echo     http://localhost:3000/api/docs
echo.
echo  POSTGRESQL DATABASE:
echo     localhost:5432 (User: postgres, Database: vankar_matrimony)
echo.
echo ======================================================================
echo  Tip: Re-run 'local-deploy.bat' or '.\local-deploy.ps1' to refresh.
echo ======================================================================
echo.
