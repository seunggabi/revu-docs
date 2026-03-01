# Register Windows Scheduled Task for WSL2 Port Forwarding
# Run this script ONCE in PowerShell (Admin) to set up auto-run at login

$scriptPath = "C:\wsl2-portforward.ps1"

# Copy script to C:\ for stable path
$wslScriptPath = (wsl -d Ubuntu -e wslpath -w "/home/seung/sg/revu-docs/scripts/wsl2-portforward.ps1")
Copy-Item $wslScriptPath $scriptPath -Force

$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""

$trigger = New-ScheduledTaskTrigger -AtLogOn

$principal = New-ScheduledTaskPrincipal `
    -UserId "$env:USERNAME" `
    -RunLevel Highest

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable

Register-ScheduledTask `
    -TaskName "WSL2 Port Forward" `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings `
    -Force

Write-Host "`n[DONE] 'WSL2 Port Forward' 작업이 등록되었습니다." -ForegroundColor Green
Write-Host "Windows 로그인 시 자동으로 포트포워딩이 업데이트됩니다." -ForegroundColor Cyan
