# Script completo: Transferir scripts e instalar todo
# Este script intenta transferir los scripts y guiar la instalación

param(
    [string]$VMUser = "moltbot",
    [string]$VMIP = "127.0.0.1",
    [int]$Port = 2222
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Transferir Scripts e Instalar" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Configuracion:" -ForegroundColor Yellow
Write-Host "  Usuario: $VMUser" -ForegroundColor Gray
Write-Host "  IP: $VMIP" -ForegroundColor Gray
Write-Host "  Puerto: $Port" -ForegroundColor Gray
Write-Host ""

# Verificar que los scripts existen
$scriptsPath = Join-Path $PSScriptRoot "."
if (-not (Test-Path (Join-Path $scriptsPath "setup-complete.sh"))) {
    Write-Host "[X] Error: Scripts no encontrados en: $scriptsPath" -ForegroundColor Red
    Write-Host "    Asegurate de ejecutar este script desde el directorio del proyecto" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Scripts encontrados" -ForegroundColor Green
Write-Host ""

# Paso 1: Crear directorio en la VM
Write-Host "Paso 1: Crear directorio en la VM..." -ForegroundColor Yellow
Write-Host "Ejecuta esto en la VM (via SSH):" -ForegroundColor Cyan
Write-Host "  mkdir -p ~/scripts" -ForegroundColor Gray
Write-Host ""

# Paso 2: Transferir scripts
Write-Host "Paso 2: Transferir scripts..." -ForegroundColor Yellow
Write-Host "Ejecutando transferencia..." -ForegroundColor Gray

try {
    if ($Port -eq 22) {
        $result = scp -r "$scriptsPath\*" "${VMUser}@${VMIP}:~/scripts/" 2>&1
    } else {
        $result = scp -P $Port -r "$scriptsPath\*" "${VMUser}@${VMIP}:~/scripts/" 2>&1
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Scripts transferidos!" -ForegroundColor Green
    } else {
        Write-Host "[!] Transferencia puede requerir contraseña" -ForegroundColor Yellow
        Write-Host "    Ingresa tu contraseña cuando se solicite" -ForegroundColor Gray
        Write-Host ""
        Write-Host "O ejecuta manualmente:" -ForegroundColor Cyan
        if ($Port -eq 22) {
            Write-Host "  scp -r scripts\* ${VMUser}@${VMIP}:~/scripts/" -ForegroundColor Gray
        } else {
            Write-Host "  scp -P $Port -r scripts\* ${VMUser}@${VMIP}:~/scripts/" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "[!] Error en transferencia: $_" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Ejecuta manualmente:" -ForegroundColor Cyan
    if ($Port -eq 22) {
        Write-Host "  scp -r scripts\* ${VMUser}@${VMIP}:~/scripts/" -ForegroundColor Gray
    } else {
        Write-Host "  scp -P $Port -r scripts\* ${VMUser}@${VMIP}:~/scripts/" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Proximos pasos en la VM:" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Conectate a la VM:" -ForegroundColor Yellow
if ($Port -eq 22) {
    Write-Host "   ssh ${VMUser}@${VMIP}" -ForegroundColor Gray
} else {
    Write-Host "   ssh ${VMUser}@${VMIP} -p $Port" -ForegroundColor Gray
}
Write-Host ""
Write-Host "2. Ejecuta estos comandos en la VM:" -ForegroundColor Yellow
Write-Host "   chmod +x ~/scripts/*.sh" -ForegroundColor Gray
Write-Host "   bash ~/scripts/setup-complete.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "Esto instalara Node.js y Moltbot automaticamente" -ForegroundColor Cyan
Write-Host ""












