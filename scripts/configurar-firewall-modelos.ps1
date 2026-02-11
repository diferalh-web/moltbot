# Script para configurar firewall de Windows para los nuevos puertos
# Ejecutar en PowerShell como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar Firewall para Ollama-Mistral y Ollama-Qwen" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Obtener IP local
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*"} | Select-Object -First 1).IPAddress

# Verificar reglas existentes
Write-Host "[1/3] Verificando reglas de firewall existentes..." -ForegroundColor Yellow
$mistralRule = Get-NetFirewallRule -DisplayName "Ollama Mistral" -ErrorAction SilentlyContinue
$qwenRule = Get-NetFirewallRule -DisplayName "Ollama Qwen" -ErrorAction SilentlyContinue

# Crear regla para Mistral (puerto 11436)
if (-not $mistralRule) {
    Write-Host "[2/3] Creando regla de firewall para Ollama-Mistral (puerto 11436)..." -ForegroundColor Yellow
    New-NetFirewallRule -DisplayName "Ollama Mistral" `
        -Direction Inbound `
        -Protocol TCP `
        -LocalPort 11436 `
        -Action Allow | Out-Null
    Write-Host "[OK] Regla creada para puerto 11436" -ForegroundColor Green
} else {
    Write-Host "[OK] Regla ya existe para puerto 11436" -ForegroundColor Green
}

# Crear regla para Qwen (puerto 11437)
if (-not $qwenRule) {
    Write-Host "[3/3] Creando regla de firewall para Ollama-Qwen (puerto 11437)..." -ForegroundColor Yellow
    New-NetFirewallRule -DisplayName "Ollama Qwen" `
        -Direction Inbound `
        -Protocol TCP `
        -LocalPort 11437 `
        -Action Allow | Out-Null
    Write-Host "[OK] Regla creada para puerto 11437" -ForegroundColor Green
} else {
    Write-Host "[OK] Regla ya existe para puerto 11437" -ForegroundColor Green
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Configuración de firewall completada!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Puertos abiertos:" -ForegroundColor Yellow
Write-Host "  - Puerto 11436: Ollama-Mistral" -ForegroundColor Gray
Write-Host "  - Puerto 11437: Ollama-Qwen" -ForegroundColor Gray
Write-Host ""
Write-Host "URLs para configurar en Moltbot (VM):" -ForegroundColor Yellow
Write-Host "  Mistral: http://$ipAddress:11436/v1" -ForegroundColor Cyan
Write-Host "  Qwen:    http://$ipAddress:11437/v1" -ForegroundColor Cyan
Write-Host ""












