# Script alternativo usando netsh para configurar firewall
# Ejecutar en PowerShell como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar Firewall (netsh)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si se ejecuta como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[X] Este script requiere permisos de Administrador" -ForegroundColor Red
    Write-Host "    Ejecuta PowerShell como Administrador y vuelve a intentar" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    Click derecho en PowerShell -> Ejecutar como administrador" -ForegroundColor Gray
    exit 1
}

Write-Host "[OK] Ejecutando como Administrador" -ForegroundColor Green
Write-Host ""

# Verificar reglas existentes
Write-Host "[1/3] Verificando reglas existentes..." -ForegroundColor Yellow
$mistralRule = netsh advfirewall firewall show rule name="Ollama Mistral" 2>$null
$qwenRule = netsh advfirewall firewall show rule name="Ollama Qwen" 2>$null

# Crear regla para Mistral (puerto 11436)
if (-not $mistralRule) {
    Write-Host "[2/3] Creando regla para puerto 11436 (Mistral)..." -ForegroundColor Yellow
    netsh advfirewall firewall add rule name="Ollama Mistral" dir=in action=allow protocol=TCP localport=11436 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Regla creada para puerto 11436" -ForegroundColor Green
    } else {
        Write-Host "[X] Error al crear regla para puerto 11436" -ForegroundColor Red
    }
} else {
    Write-Host "[OK] Regla ya existe para puerto 11436" -ForegroundColor Green
}

# Crear regla para Qwen (puerto 11437)
if (-not $qwenRule) {
    Write-Host "[3/3] Creando regla para puerto 11437 (Qwen)..." -ForegroundColor Yellow
    netsh advfirewall firewall add rule name="Ollama Qwen" dir=in action=allow protocol=TCP localport=11437 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Regla creada para puerto 11437" -ForegroundColor Green
    } else {
        Write-Host "[X] Error al crear regla para puerto 11437" -ForegroundColor Red
    }
} else {
    Write-Host "[OK] Regla ya existe para puerto 11437" -ForegroundColor Green
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Configuración completada!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Obtener IP
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*"} | Select-Object -First 1).IPAddress

Write-Host "URLs para configurar en Moltbot (VM):" -ForegroundColor Yellow
Write-Host "  Mistral: http://$ipAddress:11436/v1" -ForegroundColor Cyan
Write-Host "  Qwen:    http://$ipAddress:11437/v1" -ForegroundColor Cyan
Write-Host ""












