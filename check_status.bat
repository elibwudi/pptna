@echo off
title PPT Narrator - System Status

echo ========================================
echo   PPT Narrator AI System - Status
echo ========================================

echo [1] Service Status
netstat -ano | findstr :6001 | findstr LISTENING >nul 2>&1
if "%errorlevel%"=="0" (
    echo [RUNNING] Port 6001 is active.
) else (
    echo [STOPPED] Port 6001 is not listening.
)

echo.
echo [2] Environment Check
if exist ".venv\Scripts\python.exe" (
    echo [OK] Virtual environment found.
) else (
    echo [MISSING] Virtual environment not found. Run "uv sync".
)

echo.
echo [3] Windows Service Check
sc query PPT_Narrator_Service >nul 2>&1
if "%errorlevel%"=="0" (
    echo [FOUND] Windows Service "PPT_Narrator_Service" exists.
) else (
    echo [NONE] Windows Service not installed.
)

echo.
pause
exit /b 0
