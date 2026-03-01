# WSL2 Port Forwarding Auto-Update Script
# Ports to forward
$ports = @(80, 443)

# Get WSL2 IP
$wslIp = (wsl -d Ubuntu -e hostname -I).Trim().Split(" ")[0]

if (-not $wslIp) {
    Write-Host "[ERROR] WSL2 IP를 가져올 수 없습니다." -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] WSL2 IP: $wslIp" -ForegroundColor Cyan

# Clear existing port proxy rules for these ports
foreach ($port in $ports) {
    netsh interface portproxy delete v4tov4 listenport=$port listenaddress=0.0.0.0 2>$null
}

# Add new port proxy rules
foreach ($port in $ports) {
    netsh interface portproxy add v4tov4 listenport=$port listenaddress=0.0.0.0 connectport=$port connectaddress=$wslIp
    Write-Host "[OK] Port $port -> ${wslIp}:${port}" -ForegroundColor Green
}

# Ensure firewall rules exist (idempotent)
$rules = @(
    @{ Name = "WSL2 HTTP";  Port = 80  },
    @{ Name = "WSL2 HTTPS"; Port = 443 }
)

foreach ($rule in $rules) {
    $existing = netsh advfirewall firewall show rule name=$($rule.Name) 2>$null
    if ($existing -notmatch "Rule Name") {
        netsh advfirewall firewall add rule name=$($rule.Name) dir=in action=allow protocol=TCP localport=$($rule.Port)
        Write-Host "[OK] Firewall rule added: $($rule.Name)" -ForegroundColor Green
    }
}

Write-Host "`n[DONE] Port forwarding updated." -ForegroundColor Yellow
netsh interface portproxy show all
