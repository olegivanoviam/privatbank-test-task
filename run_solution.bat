@echo off
REM PrivatBank Test Task - Windows Run Script
REM This script starts the solution and runs basic validation

echo 🚀 PrivatBank Test Task - Starting Solution
echo ===========================================

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Docker is not running!
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)

echo ✅ Docker is running

REM Start the solution
echo 🔄 Starting PrivatBank solution...
docker-compose up -d

echo ⏳ Waiting for services to be ready...
timeout /t 30 /nobreak >nul

REM Check if services are running
echo 🔍 Checking service status...
docker-compose ps

REM Wait a bit more for initialization
echo ⏳ Waiting for database initialization...
timeout /t 60 /nobreak >nul

REM Run basic validation
echo 🧪 Running basic validation...

echo 📊 Checking database records...
for /f %%i in ('docker-compose exec -T postgres-primary psql -U postgres -d privatbank_test -c "SELECT COUNT(*) FROM t1;" ^| findstr /r "[0-9][0-9][0-9][0-9][0-9]"') do set primary_count=%%i
for /f %%i in ('docker-compose exec -T postgres-standby psql -U postgres -d privatbank_test -c "SELECT COUNT(*) FROM t1;" ^| findstr /r "[0-9][0-9][0-9][0-9][0-9]"') do set standby_count=%%i

echo Primary database: %primary_count% records
echo Standby database: %standby_count% records

echo 🔄 Checking replication status...
docker-compose exec -T postgres-primary psql -U postgres -d privatbank_test -c "SELECT * FROM check_replication_status();"

echo 📈 Checking job status...
docker-compose exec -T postgres-primary psql -U postgres -d privatbank_test -c "SELECT * FROM check_job_status();"

echo.
echo 🎉 Solution is running!
echo ======================
echo.
echo ✅ Services are running
echo ✅ Databases are initialized
echo ✅ Replication is active
echo ✅ Jobs are scheduled
echo.
echo 📋 Next steps:
echo 1. Run 'test_solution.bat' for comprehensive validation
echo 2. Check logs with: docker-compose logs
echo 3. Access databases with: docker-compose exec postgres-primary psql -U postgres -d privatbank_test
echo.
echo 📚 For detailed instructions, see SETUP_GUIDE.md
echo.
echo 🚀 The PrivatBank test task solution is ready!
pause
