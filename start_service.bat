@echo off
setlocal enabledelayedexpansion
title PPT Narrator - Start Service (UV)

echo ========================================
echo   PPT Narrator AI System (UV Mode)
echo ========================================

:: Check uv installation
uv --version >nul 2>&1
if "%errorlevel%" neq "0" (
    echo [ERROR] uv not found. Please install uv.
    ping -n 5 127.0.0.1 >nul
    exit /b 1
)

echo [INFO] Syncing dependencies...
uv sync --quiet

:: Kill old processes
echo [INFO] Cleaning up old processes...
taskkill /F /IM pythonw.exe >nul 2>&1
taskkill /F /IM python.exe >nul 2>&1
ping -n 3 127.0.0.1 >nul

:: Port Check
netstat -ano | findstr ":6001" | findstr "LISTENING" >nul 2>&1
if "%errorlevel%"=="0" (
    echo [ERROR] Port 6001 is still occupied!
    ping -n 5 127.0.0.1 >nul
    exit /b 1
)

echo [INFO] Starting background service...
:: Use start without /b to ensure it detaches properly from the calling shell
start "PPT-Narrator" "%~dp0.venv\Scripts\pythonw.exe" -u "%~dp0run.py"

echo [INFO] Waiting for startup...
:: Wait 10 seconds for initial imports and waitress bind
ping -n 11 127.0.0.1 >nul

:: Final Check
netstat -ano | findstr ":6001" | findstr "LISTENING" >nul 2>&1
if "%errorlevel%"=="0" (
    echo [OK] Service started at http://localhost:6001
) else (
    echo [ERROR] Service failed to start or port 6001 is not listening.
    :: Check if it's still starting (some machines are slow)
    ping -n 6 127.0.0.1 >nul
    netstat -ano | findstr ":6001" | findstr "LISTENING" >nul 2>&1
    if "%errorlevel%"=="0" (
        echo [OK] Service started (delayed)
    ) else (
        echo [ERROR] Final check failed.
        exit /b 1
    )
)

echo [INFO] Opening log monitor...
if "%SESSIONNAME%" neq "" (
    if "%SESSIONNAME%" neq "Services" (
        start "PPT Log Monitor" cmd.exe /c "monitor_logs.bat"
    )
)

exit /b 0
