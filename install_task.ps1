# Configuration
$TaskName = "PPT_Narrator_Autostart"
$PowershellPath = "powershell.exe"
$ScriptPath = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"E:\ppt-narrator-app\watchdog.ps1`""
$WorkDir = "E:\ppt-narrator-app"
$LogFile = "E:\ppt-narrator-app\task_creation.log"

function Log-Message($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] $msg" | Out-File -FilePath $LogFile -Append
}

Log-Message "Starting Task Creation Process..."

# 1. Cleanup old task if exists
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Log-Message "Removing existing task: $TaskName"
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# 2. Define Action (Run pythonw.exe with run.py)
$Action = New-ScheduledTaskAction -Execute $PowershellPath -Argument $ScriptPath -WorkingDirectory $WorkDir

# 3. Define Trigger (At System Startup)
$Trigger = New-ScheduledTaskTrigger -AtStartup

# 4. Define Settings
# AllowStartIfOnBatteries, Don't stop if battery, Restart on failure
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)

# 5. Define Principal (Run as SYSTEM or current user)
# We use System to ensure it runs without login, but usually current user with "Run whether logged in or not" is better for COM objects.
# However, for pure web service, SYSTEM is fine. Let's use current user to avoid COM permission issues if they ever arise.
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType S4U -RunLevel Highest

# 6. Register the Task
Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal

Log-Message "Task Registered Successfully."
Write-Host "[OK] Task $TaskName registered successfully."
