@echo off
REM ========================================
REM PPT Narrator - 纯代码打包脚本（分享版）
REM ========================================

setlocal

set SOURCE_DIR=E:\ppt-narrator-app
set RELEASE_DIR=E:\share103\apply\PPTNarrator-代码包-分享版
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set ZIP_NAME=PPTNarrator-纯代码-%TIMESTAMP%.zip
set TEMP_DIR=%TEMP%\PPTNarrator_Code_%TIMESTAMP%

echo ========================================
echo PPT Narrator - 纯代码打包脚本
echo ========================================
echo.

REM 创建发布目录
if not exist "%RELEASE_DIR%" mkdir "%RELEASE_DIR%"

REM 创建临时目录
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

echo [1/5] 创建临时目录: %TEMP_DIR%
echo.

REM 复制核心代码文件
echo [2/5] 复制核心代码文件...
echo.

copy "%SOURCE_DIR%\app.py" "%TEMP_DIR%\" >nul && echo   + app.py
copy "%SOURCE_DIR%\run.py" "%TEMP_DIR%\" >nul && echo   + run.py
copy "%SOURCE_DIR%\main.py" "%TEMP_DIR%\" >nul && echo   + main.py
copy "%SOURCE_DIR%\calc_tokens.py" "%TEMP_DIR%\" >nul && echo   + calc_tokens.py
copy "%SOURCE_DIR%\windows_service.py" "%TEMP_DIR%\" >nul && echo   + windows_service.py

echo.

REM 复制配置文件
echo   配置文件...
copy "%SOURCE_DIR%\.env.example" "%TEMP_DIR%\" >nul && echo   + .env.example
copy "%SOURCE_DIR%\pyproject.toml" "%TEMP_DIR%\" >nul && echo   + pyproject.toml
copy "%SOURCE_DIR%\requirements.txt" "%TEMP_DIR%\" >nul && echo   + requirements.txt
copy "%SOURCE_DIR%\server_config.json" "%TEMP_DIR%\" >nul && echo   + server_config.json

echo.

REM 复制批处理脚本
echo   管理脚本...
copy "%SOURCE_DIR%\start_service.bat" "%TEMP_DIR%\" >nul && echo   + start_service.bat
copy "%SOURCE_DIR%\stop_service.bat" "%TEMP_DIR%\" >nul && echo   + stop_service.bat
copy "%SOURCE_DIR%\check_status.bat" "%TEMP_DIR%\" >nul && echo   + check_status.bat
copy "%SOURCE_DIR%\monitor_logs.bat" "%TEMP_DIR%\" >nul && echo   + monitor_logs.bat
copy "%SOURCE_DIR%\service_manager.bat" "%TEMP_DIR%\" >nul && echo   + service_manager.bat

echo.

REM 复制PowerShell脚本
copy "%SOURCE_DIR%\install_task.ps1" "%TEMP_DIR%\" >nul && echo   + install_task.ps1
copy "%SOURCE_DIR%\log_monitor.ps1" "%TEMP_DIR%\" >nul && echo   + log_monitor.ps1
copy "%SOURCE_DIR%\watchdog.ps1" "%TEMP_DIR%\" >nul && echo   + watchdog.ps1

echo.

REM 复制文档
echo   文档...
if exist "%SOURCE_DIR%\SECURITY.md" copy "%SOURCE_DIR%\SECURITY.md" "%TEMP_DIR%\" >nul && echo   + SECURITY.md
if exist "%SOURCE_DIR%\服务启动说明.md" copy "%SOURCE_DIR%\服务启动说明.md" "%TEMP_DIR%\" >nul && echo   + 服务启动说明.md
if exist "%SOURCE_DIR%\功能说明书.md" copy "%SOURCE_DIR%\功能说明书.md" "%TEMP_DIR%\" >nul && echo   + 功能说明书.md
if exist "%SOURCE_DIR%\脚本使用说明.md" copy "%SOURCE_DIR%\脚本使用说明.md" "%TEMP_DIR%\" >nul && echo   + 脚本使用说明.md
if exist "%SOURCE_DIR%\TWO_STAGE_GENERATION.md" copy "%SOURCE_DIR%\TWO_STAGE_GENERATION.md" "%TEMP_DIR%\" >nul && echo   + TWO_STAGE_GENERATION.md
if exist "%SOURCE_DIR%\TEST_GUIDE.md" copy "%SOURCE_DIR%\TEST_GUIDE.md" "%TEMP_DIR%\" >nul && echo   + TEST_GUIDE.md
if exist "%SOURCE_DIR%\AUTO_FALLBACK_SUMMARY.md" copy "%SOURCE_DIR%\AUTO_FALLBACK_SUMMARY.md" "%TEMP_DIR%\" >nul && echo   + AUTO_FALLBACK_SUMMARY.md

echo.

REM [3/5] 复制目录
echo [3/5] 复制前端资源...
if exist "%SOURCE_DIR%\static" xcopy /e /i /q "%SOURCE_DIR%\static" "%TEMP_DIR%\static" >nul && echo   + static\
if exist "%SOURCE_DIR%\templates" xcopy /e /i /q "%SOURCE_DIR%\templates" "%TEMP_DIR%\templates" >nul && echo   + templates\

echo.

REM [4/5] 清理内网地址
echo [4/5] 清理配置文件中的内网地址...
powershell -Command "(Get-Content '%TEMP_DIR%\server_config.json' -Raw) -replace 'http://10\.255\.\d+\.\d+:\d+/v1', 'http://YOUR_SERVER:PORT/v1' | Set-Content '%TEMP_DIR%\server_config.json'"
echo   + 已清理 server_config.json

echo.

REM [5/5] 创建ZIP压缩包
echo [5/5] 创建ZIP压缩包...
powershell -Command "Compress-Archive -Path '%TEMP_DIR%\*' -DestinationPath '%RELEASE_DIR%\%ZIP_NAME%' -Force"

echo.
echo ========================================
echo 打包完成！
echo ========================================
echo.
echo 压缩包位置: %RELEASE_DIR%\%ZIP_NAME%
echo.

REM 清理临时目录
rmdir /s /q "%TEMP_DIR%"
echo + 临时目录已清理
echo.

echo 包含内容:
echo   * 核心Python代码（app.py, run.py等）
echo   * 前端资源（static/, templates/）
echo   * 配置模板（.env.example, server_config.json）
echo   * 管理脚本（.bat, .ps1）
echo   * 完整文档（.md文件）
echo.

echo 已排除:
echo   * API密钥（.env）
echo   * 日志文件（*.log）
echo   * 用户数据（uploads/, generated/）
echo   * 密钥文件（*.key）
echo   * Python缓存（__pycache__, .venv）
echo   * 内网IP地址（已替换）
echo.

echo 纯代码包，可安全分享！
echo.

pause
