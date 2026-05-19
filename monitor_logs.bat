@echo off
title PPT Narrator - Log Monitor
echo [INFO] Starting log monitoring...
echo [INFO] Press Ctrl+C to stop.
powershell.exe -ExecutionPolicy Bypass -File "log_monitor.ps1"
pause
