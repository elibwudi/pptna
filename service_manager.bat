@echo off
setlocal
:: Ensure we are in the script's directory
cd /d "%~dp0"

:: Configuration
set "TASK_NAME=PPT_Narrator_Autostart"
set "OLD_SERVICE=PPT_Narrator_Service"
set "PS_SCRIPT=%~dp0install_task.ps1"

:: Privilege Check
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] This script MUST be run as ADMINISTRATOR.
    echo [ERROR] Please right-click and select "Run as Administrator".
    pause
    exit /b
)

:MENU
cls
echo ========================================
echo   PPT Narrator AI - Service Manager (v2.1)
echo ========================================
echo  [1] Install Autostart Task
echo  [2] Start Now
echo  [3] Stop Now
echo  [4] Uninstall (Remove)
echo  [5] Check Status
echo  [6] Full Setup (Repair + Install + Start)
echo  [Q] Quit
echo ========================================
echo  Note: Paths are now absolute for stability.
echo ========================================
set /p choice="Enter choice: "

if "%choice%"=="1" goto INSTALL
if "%choice%"=="2" goto START
if "%choice%"=="3" goto STOP
if "%choice%"=="4" goto UNINSTALL
if "%choice%"=="5" goto STATUS
if "%choice%"=="6" goto SETUP
if /i "%choice%"=="q" exit /b
goto MENU

:INSTALL
echo [INFO] Uninstalling old failed service...
sc stop %OLD_SERVICE% >nul 2>&1
sc delete %OLD_SERVICE% >nul 2>&1
echo [INFO] Registering Autostart Task...
powershell -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
echo [OK] Installation finished.
pause
goto MENU

:START
echo [INFO] Starting Task...
schtasks /run /tn "%TASK_NAME%"
echo [INFO] Waiting for process startup...
timeout /t 3 /nobreak >nul
pause
goto MENU

:STOP
echo [INFO] Ending Task...
schtasks /end /tn "%TASK_NAME%" >nul 2>&1
echo [INFO] Cleaning up background processes...
taskkill /F /IM pythonw.exe >nul 2>&1
taskkill /F /IM python.exe >nul 2>&1
echo [OK] Stopped.
pause
goto MENU

:UNINSTALL
echo [INFO] Removing Task...
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
echo [INFO] Removing old service if exists...
sc delete %OLD_SERVICE% >nul 2>&1
echo [OK] Uninstalled.
pause
goto MENU

:STATUS
echo [INFO] Task Status:
schtasks /query /tn "%TASK_NAME%" /v /fo list
echo.
echo [INFO] Port Monitoring (6001):
netstat -ano | findstr :6001
pause
goto MENU

:SETUP
echo [INFO] Running Clean Setup...
sc stop %OLD_SERVICE% >nul 2>&1
sc delete %OLD_SERVICE% >nul 2>&1
powershell -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
schtasks /run /tn "%TASK_NAME%"
echo [OK] System is now running in background.
pause
goto MENU
