@echo off
setlocal

set SOURCE=E:\ppt-narrator-app
set TEMP_DIR=C:\Temp\PPTNarrator_Code
set DEST=E:\share103\apply\PPTNarrator-代码包-分享版\PPTNarrator-纯代码.zip

echo Creating code package...

REM Create temp directory
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

REM Copy Python files
copy "%SOURCE%\app.py" "%TEMP_DIR%\" >nul
copy "%SOURCE%\run.py" "%TEMP_DIR%\" >nul
copy "%SOURCE%\main.py" "%TEMP_DIR%\" >nul
copy "%SOURCE%\calc_tokens.py" "%TEMP_DIR%\" >nul
copy "%SOURCE%\windows_service.py" "%TEMP_DIR%\" >nul

REM Copy config files
copy "%SOURCE%\.env.example" "%TEMP_DIR%\" >nul
copy "%SOURCE%\pyproject.toml" "%TEMP_DIR%\" >nul
copy "%SOURCE%\requirements.txt" "%TEMP_DIR%\" >nul
copy "%SOURCE%\server_config.json" "%TEMP_DIR%\" >nul

REM Copy scripts
copy "%SOURCE%\start_service.bat" "%TEMP_DIR%\" >nul
copy "%SOURCE%\stop_service.bat" "%TEMP_DIR%\" >nul
copy "%SOURCE%\check_status.bat" "%TEMP_DIR%\" >nul
copy "%SOURCE%\monitor_logs.bat" "%TEMP_DIR%\" >nul
copy "%SOURCE%\service_manager.bat" "%TEMP_DIR%\" >nul
copy "%SOURCE%\install_task.ps1" "%TEMP_DIR%\" >nul
copy "%SOURCE%\log_monitor.ps1" "%TEMP_DIR%\" >nul
copy "%SOURCE%\watchdog.ps1" "%TEMP_DIR%\" >nul

REM Copy docs
if exist "%SOURCE%\SECURITY.md" copy "%SOURCE%\SECURITY.md" "%TEMP_DIR%\" >nul
if exist "%SOURCE%\服务启动说明.md" copy "%SOURCE%\服务启动说明.md" "%TEMP_DIR%\" >nul
if exist "%SOURCE%\功能说明书.md" copy "%SOURCE%\功能说明书.md" "%TEMP_DIR%\" >nul
if exist "%SOURCE%\脚本使用说明.md" copy "%SOURCE%\脚本使用说明.md" "%TEMP_DIR%\" >nul
if exist "%SOURCE%\TWO_STAGE_GENERATION.md" copy "%SOURCE%\TWO_STAGE_GENERATION.md" "%TEMP_DIR%\" >nul
if exist "%SOURCE%\TEST_GUIDE.md" copy "%SOURCE%\TEST_GUIDE.md" "%TEMP_DIR%\" >nul
if exist "%SOURCE%\AUTO_FALLBACK_SUMMARY.md" copy "%SOURCE%\AUTO_FALLBACK_SUMMARY.md" "%TEMP_DIR%\" >nul

REM Copy directories
xcopy /e /i /q "%SOURCE%\static" "%TEMP_DIR%\static" >nul
xcopy /e /i /q "%SOURCE%\templates" "%TEMP_DIR%\templates" >nul

REM Create ZIP
powershell -Command "Compress-Archive -Path '%TEMP_DIR%\*' -DestinationPath '%DEST%' -Force"

REM Cleanup
rmdir /s /q "%TEMP_DIR%"

echo Done! Package created: %DEST%
dir "%DEST%"
endlocal
