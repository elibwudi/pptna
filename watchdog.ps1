$port = 6001
$interval = 30 # 秒
$serviceBat = "start_service.bat"
$logFile = "watchdog.log"
$heartbeatInterval = 20 # 每20次检查输出一次正常日志 (约10分钟一次)
$counter = 0

function Write-Log($message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMsg = "[$timestamp] $message"
    Write-Host $logMsg
    try {
        $logMsg | Out-File -FilePath (Join-Path $PSScriptRoot $logFile) -Append -Encoding UTF8 -ErrorAction Stop
    } catch {
        Write-Host "[WARN] Could not write to log file: $($_.Exception.Message)"
    }
}

Write-Log "PPT Narrator Watchdog started. Monitoring port $port..."

while($true) {
    $portActive = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    
    if (-not $portActive) {
        Write-Log "[WARN] Port $port is NOT listening! Attempting to restart service..."
        $counter = 0 # 重置计数器，确保下次恢复正常时能立刻记录
        try {
            # 停止可能存在的僵死进程
            Stop-Process -Name pythonw -ErrorAction SilentlyContinue
            Stop-Process -Name python -ErrorAction SilentlyContinue
            
            # 运行启动脚本，指定工作目录
            $process = Start-Process cmd.exe -ArgumentList "/c `"$PSScriptRoot\$serviceBat`"" -WorkingDirectory $PSScriptRoot -WindowStyle Hidden -PassThru
            Write-Log "[OK] Restart command sent (PID: $($process.Id))."
        } catch {
            Write-Log "[ERROR] Failed to launch restart script: $($_.Exception.Message)"
        }
    } else {
        $counter++
        if ($counter -ge $heartbeatInterval) {
            Write-Log "[INFO] Periodic Check: Service is healthy on port $port."
            $counter = 0
        }
    }
    
    Start-Sleep -Seconds $interval
}
