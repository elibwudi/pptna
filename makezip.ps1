$ErrorActionPreference = "Stop"

$s = "E:\ppt-narrator-app"
$t = "C:\Temp\PPTCode"
$d = "E:\share103\apply\PPTNarrator-Code-Package"
$f = "$d\PPTNarrator-Code.zip"

# Clean and create temp
if (Test-Path $t) { Remove-Item $t -Recurse -Force }
New-Item -ItemType Directory -Path $t -Force | Out-Null

# Create dest
if (!(Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }

# Files
$files = "app.py","run.py","main.py","calc_tokens.py","windows_service.py",
          ".env.example","pyproject.toml","requirements.txt","server_config.json",
          "start_service.bat","stop_service.bat","check_status.bat",
          "monitor_logs.bat","service_manager.bat",
          "install_task.ps1","log_monitor.ps1","watchdog.ps1"

foreach ($file in $files) {
    $src = Join-Path $s $file
    if (Test-Path $src) { Copy-Item $src $t -Force }
}

# Docs
$docs = Get-ChildItem $s -Filter "*.md" -File
foreach ($doc in $docs) {
    Copy-Item $doc.FullName $t -Force
}

# Dirs
foreach ($dir in $dirs) {
    $src = Join-Path $s $dir
    if (Test-Path $src) { Copy-Item $src $t -Recurse -Force }
}

# ZIP
Compress-Archive -Path "$t\*" -DestinationPath $f -Force

# Cleanup
Remove-Item $t -Recurse -Force

# Result
Write-Host "DONE: $f"
$size = (Get-Item $f).Length / 1MB
Write-Host ("Size: {0:N2} MB" -f $size)
