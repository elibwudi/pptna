@echo off
title PPT Narrator - Stop Service
echo ========================================
echo   Stopping PPT Narrator AI System
echo ========================================

:: Port 6001
echo [INFO] Finding process on port 6001...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :6001 ^| findstr LISTENING') do (
    echo [FOUND] Killing process ID: %%a
    taskkill /F /PID %%a
)

:: Python processes
echo [INFO] Cleaning up python instances...
taskkill /F /IM pythonw.exe >nul 2>&1
taskkill /F /IM python.exe >nul 2>&1

echo [OK] Service stopped.
ping -n 3 127.0.0.1 >nul
exit /b 0
