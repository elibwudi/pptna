# ========================================
# PPT Narrator - 代码打包脚本（安全分享版）
# ========================================
# 此脚本会创建一个干净的代码包，排除所有敏感信息

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PPT Narrator - 代码打包脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 设置路径
$sourceDir = "E:\ppt-narrator-app"
$releaseDir = "E:\share103\apply\PPTNarrator-代码包-分享版"
$dateStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$zipFileName = "PPTNarrator-代码包-$dateStamp.zip"

# 创建临时发布目录
$tempDir = Join-Path $env:TEMP "PPTNarrator_Release_$dateStamp"
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "✓ 创建临时目录: $tempDir" -ForegroundColor Green
Write-Host ""

# 定义要排除的文件和目录
$excludePatterns = @(
    # 敏感配置文件
    ".env",
    "config_key.key",
    "encrypted_config.key",

    # 日志文件
    "*.log",
    "app.log",
    "start_debug.log",
    "service_debug.log",
    "trace_startup.log",
    "watchdog.log",
    "task_creation.log",

    # Python缓存和环境
    "__pycache__",
    "*.pyc",
    ".venv",
    "uv.lock",

    # 用户数据和生成文件
    "uploads/*",
    "generated/*",
    "query",

    # 测试文件
    "*.pptx",
    "test_*.py",

    # 临时文件
    "nul"
)

# 定义要包含的文件和目录
$includeItems = @(
    # 核心代码
    "app.py",
    "run.py",
    "main.py",
    "calc_tokens.py",
    "windows_service.py",

    # 配置文件（已清理）
    ".env.example",
    "pyproject.toml",
    "requirements.txt",
    "server_config.json",

    # 前端资源
    "static",
    "templates",

    # 管理脚本
    "start_service.bat",
    "stop_service.bat",
    "check_status.bat",
    "monitor_logs.bat",
    "service_manager.bat",
    "install_task.ps1",
    "log_monitor.ps1",
    "watchdog.ps1",

    # 文档
    "README.md",
    "SECURITY.md",
    "服务启动说明.md",
    "功能说明书.md",
    "脚本使用说明.md",
    "TWO_STAGE_GENERATION.md",
    "TEST_GUIDE.md",
    "AUTO_FALLBACK_SUMMARY.md"
)

Write-Host "正在复制文件..." -ForegroundColor Yellow
Write-Host ""

# 复制文件和目录
foreach ($item in $includeItems) {
    $sourcePath = Join-Path $sourceDir $item
    $destPath = Join-Path $tempDir $item

    if (Test-Path $sourcePath) {
        # 如果是目录，递归复制（排除某些模式）
        if (Test-Path $sourcePath -PathType Container) {
            Write-Host "  → 复制目录: $item" -ForegroundColor Gray
            Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force

            # 清理uploads和generated子目录（保留目录结构但清空内容）
            if ($item -eq "uploads" -or $item -eq "generated") {
                if (Test-Path $destPath) {
                    Get-ChildItem -Path $destPath -Recurse | Remove-Item -Force -Recurse
                    Write-Host "    ✓ 已清空内容（保留目录结构）" -ForegroundColor DarkGreen
                }
            }
        } else {
            # 如果是文件，直接复制
            Write-Host "  → 复制文件: $item" -ForegroundColor Gray
            Copy-Item -Path $sourcePath -Destination $destPath -Force
        }
    } else {
        Write-Host "  ⚠ 跳过（不存在）: $item" -ForegroundColor DarkYellow
    }
}

Write-Host ""
Write-Host "正在清理敏感信息..." -ForegroundColor Yellow

# 检查并清理server_config.json中的内网地址
$configPath = Join-Path $tempDir "server_config.json"
if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json

    # 将内网地址替换为示例地址
    if ($config.ollama_base_url -match "10\.255\.") {
        $config.ollama_base_url = "http://YOUR_OLLAMA_SERVER:11434/v1"
    }
    if ($config.vllm_base_url -match "10\.255\.") {
        $config.vllm_base_url = "http://YOUR_VLLM_SERVER:8000/v1"
    }

    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
    Write-Host "  ✓ 已清理 server_config.json 中的内网地址" -ForegroundColor Green
}

# 创建 .gitkeep 文件以确保空目录被包含
$uploadsDir = Join-Path $tempDir "uploads"
$generatedDir = Join-Path $tempDir "generated"
if (Test-Path $uploadsDir) { "" | Set-Content (Join-Path $uploadsDir ".gitkeep") }
if (Test-Path $generatedDir) { "" | Set-Content (Join-Path $generatedDir ".gitkeep") }

# 创建 README.md（如果没有）
$readmePath = Join-Path $tempDir "README_分享版.md"
@"
# PPT Narrator AI 智能讲稿系统

## 📦 快速开始

### 1. 环境要求
- Python 3.14 或更高版本
- uv 包管理器（推荐）或 pip
- Windows 操作系统

### 2. 安装依赖

**使用 uv（推荐）：**
```powershell
pip install uv
uv sync
```

**使用 pip：**
```powershell
pip install -r requirements.txt
```

### 3. 配置环境变量

复制配置模板：
```powershell
copy .env.example .env
```

编辑 `.env` 文件，填入您的 API 密钥：
- `GEMINI_API_KEY` - Google Gemini API密钥
- `DEEPSEEK_API_KEY` - DeepSeek API密钥
- `DASHSCOPE_API_KEY` - 阿里通义千问 API密钥
- `SECRET_KEY` - Flask会话密钥
- `ADMIN_PASSWORD_HASH` - 管理员密码哈希

### 4. 启动服务

**开发模式：**
```powershell
python run.py
```

**生产模式：**
```powershell
start_service.bat
```

服务将在 http://localhost:6001 启动

### 5. 使用说明

访问 http://localhost:6001，上传PPT文件即可生成智能讲稿。

## 📚 详细文档

- **功能说明书.md** - 完整功能介绍
- **服务启动说明.md** - 详细部署指南
- **脚本使用说明.md** - 管理脚本说明

## 🔒 安全说明

本代码包已排除以下敏感信息：
- ✗ API 密钥（.env 文件）
- ✗ 日志文件（*.log）
- ✗ 用户上传文件（uploads/）
- ✗ 生成文件（generated/）
- ✗ 加密密钥（*.key）

使用前请务必配置 `.env` 文件中的 API 密钥。

## 📄 许可证

本项目代码开源，供学习和使用。

---

**版本**: v1.0
**更新日期**: $(Get-Date -Format 'yyyy-MM-dd')
"@ | Set-Content $readmePath -Encoding UTF8

Write-Host "  ✓ 已创建 README_分享版.md" -ForegroundColor Green

Write-Host ""
Write-Host "正在创建压缩包..." -ForegroundColor Yellow

# 创建发布目录
if (!(Test-Path $releaseDir)) {
    New-Item -ItemType Directory -Path $releaseDir -Force | Out-Null
}

# 压缩为ZIP
$zipPath = Join-Path $releaseDir $zipFileName
Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -Force

Write-Host "  ✓ 压缩包已创建: $zipPath" -ForegroundColor Green

# 清理临时目录
Remove-Item -Path $tempDir -Recurse -Force
Write-Host "  ✓ 临时目录已清理" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "打包完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "压缩包位置: $zipPath" -ForegroundColor White
Write-Host ""
Write-Host "包含内容:" -ForegroundColor White
Write-Host "  ✓ 核心源代码（app.py, run.py等）" -ForegroundColor Gray
Write-Host "  ✓ 配置模板（.env.example, server_config.json）" -ForegroundColor Gray
Write-Host "  ✓ 前端资源（static/, templates/）" -ForegroundColor Gray
Write-Host "  ✓ 管理脚本（.bat, .ps1）" -ForegroundColor Gray
Write-Host "  ✓ 文档说明（.md文件）" -ForegroundColor Gray
Write-Host ""
Write-Host "已排除:" -ForegroundColor White
Write-Host "  ✗ API密钥（.env）" -ForegroundColor Gray
Write-Host "  ✗ 日志文件（*.log）" -ForegroundColor Gray
Write-Host "  ✗ 用户数据（uploads/, generated/）" -ForegroundColor Gray
Write-Host "  ✗ 密钥文件（*.key）" -ForegroundColor Gray
Write-Host "  ✗ Python缓存（__pycache__, .venv）" -ForegroundColor Gray
Write-Host ""
Write-Host "安全分享，请放心！ 🎉" -ForegroundColor Green
