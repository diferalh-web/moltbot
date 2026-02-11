# Script para ejecutar la instalación completa
# Ejecuta este script en PowerShell

param(
    [string]$VMUser = "moltbot2",
    [string]$VMIP = "127.0.0.1",
    [int]$Port = 2222
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Instalacion Completa de Moltbot" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Configuracion:" -ForegroundColor Yellow
Write-Host "  Usuario: $VMUser" -ForegroundColor Gray
Write-Host "  IP: $VMIP" -ForegroundColor Gray
Write-Host "  Puerto: $Port" -ForegroundColor Gray
Write-Host ""

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "scripts\setup-complete.sh")) {
    Write-Host "[X] Error: No se encuentran los scripts" -ForegroundColor Red
    Write-Host "    Asegurate de estar en: C:\code\moltbot" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Scripts encontrados" -ForegroundColor Green
Write-Host ""

# Paso 1: Crear directorio en la VM
Write-Host "Paso 1: Creando directorio en la VM..." -ForegroundColor Yellow
Write-Host "Ejecutando: ssh $VMUser@$VMIP -p $Port 'mkdir -p ~/scripts'" -ForegroundColor Gray
Write-Host ""
Write-Host "Ingresa tu contraseña cuando se solicite:" -ForegroundColor Cyan
Write-Host ""

ssh $VMUser@$VMIP -p $Port "mkdir -p ~/scripts && echo 'Directorio creado'"

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Directorio creado" -ForegroundColor Green
} else {
    Write-Host "[!] Error al crear directorio" -ForegroundColor Yellow
}
Write-Host ""

# Paso 2: Transferir scripts
Write-Host "Paso 2: Transfiriendo scripts a la VM..." -ForegroundColor Yellow
Write-Host "Esto puede tomar unos segundos..." -ForegroundColor Gray
Write-Host ""
Write-Host "Ejecutando: scp -P $Port -r scripts\* ${VMUser}@${VMIP}:~/scripts/" -ForegroundColor Gray
Write-Host "Ingresa tu contraseña cuando se solicite:" -ForegroundColor Cyan
Write-Host ""

scp -P $Port -r scripts\* ${VMUser}@${VMIP}:~/scripts/

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[OK] Scripts transferidos!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[!] Error en la transferencia" -ForegroundColor Yellow
    Write-Host "    Intenta manualmente:" -ForegroundColor Gray
    Write-Host "    scp -P $Port -r scripts\* ${VMUser}@${VMIP}:~/scripts/" -ForegroundColor Gray
    exit 1
}
Write-Host ""

# Paso 3: Instalar Node.js y Moltbot
Write-Host "Paso 3: Instalando Node.js y Moltbot..." -ForegroundColor Yellow
Write-Host "Esto tomara 10-15 minutos..." -ForegroundColor Gray
Write-Host ""
Write-Host "Ejecutando en la VM:" -ForegroundColor Cyan
Write-Host "  chmod +x ~/scripts/*.sh" -ForegroundColor Gray
Write-Host "  bash ~/scripts/setup-complete.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "Ingresa tu contraseña cuando se solicite:" -ForegroundColor Cyan
Write-Host ""

ssh $VMUser@$VMIP -p $Port "chmod +x ~/scripts/*.sh && bash ~/scripts/setup-complete.sh"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[OK] Instalacion completada!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[!] Error en la instalacion" -ForegroundColor Yellow
    Write-Host "    Conectate manualmente y ejecuta:" -ForegroundColor Gray
    Write-Host "    ssh $VMUser@$VMIP -p $Port" -ForegroundColor Gray
    Write-Host "    bash ~/scripts/setup-complete.sh" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Instalacion completada!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Verificando instalacion..." -ForegroundColor Yellow
Write-Host ""

ssh $VMUser@$VMIP -p $Port "node --version && npm --version && which moltbot"

Write-Host ""
Write-Host "Proximo paso: Conectar Cursor" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Abre Cursor" -ForegroundColor Gray
Write-Host "2. Ctrl+Shift+P -> Remote-SSH: Connect to Host" -ForegroundColor Gray
Write-Host "3. Escribe: $VMUser@$VMIP -p $Port" -ForegroundColor Gray
Write-Host "4. Ingresa tu contraseña" -ForegroundColor Gray
Write-Host "5. Abre carpeta: /home/$VMUser/moltbot-project" -ForegroundColor Gray
Write-Host ""












