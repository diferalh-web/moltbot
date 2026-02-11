# Script para verificar conexión a la VM
# Intenta conectarse vía SSH para verificar que todo está bien

param(
    [string]$VMUser = "moltbot",
    [string]$VMIP = "",
    [int]$Port = 2222
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Verificando Conexion a la VM" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Si no se especificó IP, intentar con port forwarding
if ([string]::IsNullOrEmpty($VMIP)) {
    $VMIP = "127.0.0.1"
    Write-Host "Usando port forwarding (127.0.0.1:$Port)" -ForegroundColor Yellow
} else {
    $Port = 22
    Write-Host "Usando IP directa: $VMIP" -ForegroundColor Yellow
}

Write-Host "Usuario: $VMUser" -ForegroundColor Gray
Write-Host "IP: $VMIP" -ForegroundColor Gray
Write-Host "Puerto: $Port" -ForegroundColor Gray
Write-Host ""

# Probar conexión SSH
Write-Host "Probando conexion SSH..." -ForegroundColor Yellow

if ($Port -eq 22) {
    $testResult = ssh -o ConnectTimeout=5 -o BatchMode=yes ${VMUser}@${VMIP} "echo 'Conexion exitosa'" 2>&1
} else {
    $testResult = ssh -o ConnectTimeout=5 -o BatchMode=yes -p $Port ${VMUser}@${VMIP} "echo 'Conexion exitosa'" 2>&1
}

if ($LASTEXITCODE -eq 0 -or $testResult -match "Conexion exitosa") {
    Write-Host "[OK] Conexion SSH exitosa!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Para conectarte manualmente:" -ForegroundColor Cyan
    if ($Port -eq 22) {
        Write-Host "  ssh ${VMUser}@${VMIP}" -ForegroundColor Gray
    } else {
        Write-Host "  ssh ${VMUser}@${VMIP} -p $Port" -ForegroundColor Gray
    }
    return $true
} else {
    Write-Host "[!] No se pudo conectar automaticamente" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Esto es normal si:" -ForegroundColor Yellow
    Write-Host "  - Es la primera vez que te conectas" -ForegroundColor Gray
    Write-Host "  - No tienes claves SSH configuradas" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Intenta conectarte manualmente:" -ForegroundColor Cyan
    if ($Port -eq 22) {
        Write-Host "  ssh ${VMUser}@${VMIP}" -ForegroundColor Gray
    } else {
        Write-Host "  ssh ${VMUser}@${VMIP} -p $Port" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "Si te pide confirmar la clave, escribe 'yes'" -ForegroundColor Yellow
    Write-Host "Luego ingresa tu contraseña" -ForegroundColor Yellow
    return $false
}












