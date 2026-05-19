# PPT Narrator - 纯代码打包脚本
$ErrorActionPreference = "Stop"

$sourceDir = "E:\ppt-narrator-app"
$releaseDir = "E:\share103\apply\PPTNarrator-代码包-分享版"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$zipName = "PPTNarrator-纯代码-$timestamp.zip"
$tempDir = Join-Path $env:TEMP "PPTNarrator_Code_$timestamp"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PPT Narrator - 纯代码打包脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 创建发布目录
if (!(Test-Path $releaseDir)) {
    New-Item -ItemType Directory -Path $releaseDir -Force | Out-Null
}

# 创建临时目录
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Write-Host "✓ 创建临时目录: $tempDir" -ForegroundColor Green
Write-Host ""

# 定义要复制的文件
$files = @(
    "app.py",
    "run.py",
    "main.py",
    "calc_tokens.py",
    "windows_service.py",
    ".env.example",
    "pyproject.toml",
    "requirements.txt",
    "server_config.json",
    "start_service.bat",
    "stop_service.bat",
    "check_status.bat",
    "monitor_logs.bat",
    "service_manager.bat",
    "install_task.ps1",
    "log_monitor.ps1",
    "watchdog.ps1"
)

# 定义要复制的文档
$docs = @(
    "SECURITY.md",
    "服务启动说明.md",
    "功能说明书.md",
    "脚本使用说明.md",
    "TWO_STAGE_GENERATION.md",
    "TEST_GUIDE.md",
    "AUTO_FALLBACK_SUMMARY.md"
)

Write-Host "正在复制核心代码文件..." -ForegroundColor Yellow
foreach ($file in $files) {
    $src = Join-Path $sourceDir $file
    $dst = Join-Path $tempDir $file
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $dst -Force
        Write-Host "  ✓ $file" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "正在复制文档..." -ForegroundColor Yellow
foreach ($doc in $docs) {
    $src = Join-Path $sourceDir $doc
    $dst = Join-Path $tempDir $doc
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $dst -Force
        Write-Host "  ✓ $doc" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "正在复制前端资源..." -ForegroundColor Yellow
$dirs = @("static", "templates")
foreach ($dir in $dirs) {
    $src = Join-Path $sourceDir $dir
    $dst = Join-Path $tempDir $dir
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $dst -Recurse -Force
        Write-Host "  ✓ $dir\" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "正在清理配置文件..." -ForegroundColor Yellow
# 清理内网地址
$configPath = Join-Path $tempDir "server_config.json"
if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    if ($config.ollama_base_url -match "10\.255\.") {
        $config.ollama_base_url = "http://YOUR_OLLAMA_SERVER:11434/v1"
    }
    if ($config.vllm_base_url -match "10\.255\.") {
        $config.vllm_base_url = "http://YOUR_VLLM_SERVER:8000/v1"
    }
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
    Write-Host "  ✓ 已清理内网地址" -ForegroundColor Gray
}

# 创建 .gitignore
$gitignore = @"
__pycache__/
*.pyc
.venv/
.env
*.key
*.log
uploads/
generated/
query/
"@
$gitignore | Set-Content (Join-Path $tempDir ".gitignore") -Encoding UTF8

Write-Host ""
Write-Host "正在创建ZIP压缩包..." -ForegroundColor Yellow
$zipPath = Join-Path $releaseDir $zipName
Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -Force

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "打包完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "压缩包位置: $zipPath" -ForegroundColor White
$zipSize = (Get-Item $zipPath).Length / 1MB
Write-Host ("压缩包大小: {0:N2} MB" -f $zipSize) -ForegroundColor White
Write-Host ""

Write-Host "包含内容:" -ForegroundColor White
Write-Host "  ✓ 核心Python代码（app.py, run.py等）" -ForegroundColor Gray
Write-Host "  ✓ 前端资源（static/, templates/）" -ForegroundColor Gray
Write-Host "  ✓ 配置模板（.env.example, server_config.json）" -ForegroundColor Gray
Write-Host "  ✓ 管理脚本（.bat, .ps1）" -ForegroundColor Gray
Write-Host "  ✓ 完整文档（.md文件）" -ForegroundColor Gray
Write-Host ""

Write-Host "已排除:" -ForegroundColor White
Write-Host "  ✗ API密钥（.env）" -ForegroundColor Gray
Write-Host "  ✗ 日志文件（*.log）" -ForegroundColor Gray
Write-Host "  ✗ 用户数据（uploads/, generated/）" -ForegroundColor Gray
Write-Host "  ✗ 密钥文件（*.key）" -ForegroundColor Gray
Write-Host "  ✗ Python缓存（__pycache__, .venv）" -ForegroundColor Gray
Write-Host "  ✗ 内网IP地址（已替换）" -ForegroundColor Gray
Write-Host ""

Write-Host "✓ 纯代码包，可安全分享！ 🎉" -ForegroundColor Green
Write-Host ""

# 清理临时目录
Remove-Item -Path $tempDir -Recurse -Force
Write-Host "✓ 临时目录已清理" -ForegroundColor DarkGreen
