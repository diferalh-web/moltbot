# Script para ejecutar todos los pasos de configuración
# Ejecuta este script en PowerShell

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configuracion Completa de Moltbot VM" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$vmUser = "moltbot"
$vmIP = "127.0.0.1"
$vmPort = 2222

Write-Host "Configuracion:" -ForegroundColor Yellow
Write-Host "  Usuario: $vmUser" -ForegroundColor Gray
Write-Host "  IP: $vmIP" -ForegroundColor Gray
Write-Host "  Puerto: $vmPort" -ForegroundColor Gray
Write-Host ""

# Paso 1: Verificar que estamos en el directorio correcto
Write-Host "Paso 1: Verificando directorio..." -ForegroundColor Yellow
if (-not (Test-Path "scripts\setup-complete.sh")) {
    Write-Host "[X] Error: No se encuentran los scripts" -ForegroundColor Red
    Write-Host "    Asegurate de estar en: C:\code\moltbot" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] Scripts encontrados" -ForegroundColor Green
Write-Host ""

# Paso 2: Crear directorio en la VM
Write-Host "Paso 2: Creando directorio en la VM..." -ForegroundColor Yellow
Write-Host "Ejecutando: ssh $vmUser@$vmIP -p $vmPort 'mkdir -p ~/scripts'" -ForegroundColor Gray
Write-Host ""
Write-Host "Ingresa tu contraseña cuando se solicite:" -ForegroundColor Cyan

ssh $vmUser@$vmIP -p $vmPort "mkdir -p ~/scripts && echo 'Directorio creado exitosamente'"

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Directorio creado en la VM" -ForegroundColor Green
} else {
    Write-Host "[!] Error al crear directorio. Verifica tu conexion SSH." -ForegroundColor Yellow
    Write-Host "    Intenta conectarte manualmente primero:" -ForegroundColor Gray
    Write-Host "    ssh $vmUser@$vmIP -p $vmPort" -ForegroundColor Gray
    exit 1
}
Write-Host ""

# Paso 3: Transferir scripts
Write-Host "Paso 3: Transfiriendo scripts a la VM..." -ForegroundColor Yellow
Write-Host "Esto puede tomar unos segundos..." -ForegroundColor Gray
Write-Host ""

$transferCommand = "scp -P $vmPort -r scripts\* ${vmUser}@${vmIP}:~/scripts/"
Write-Host "Ejecutando: $transferCommand" -ForegroundColor Gray
Write-Host "Ingresa tu contraseña cuando se solicite:" -ForegroundColor Cyan
Write-Host ""

Invoke-Expression $transferCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[OK] Scripts transferidos exitosamente!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[!] Error en la transferencia" -ForegroundColor Yellow
    Write-Host "    Intenta manualmente:" -ForegroundColor Gray
    Write-Host "    $transferCommand" -ForegroundColor Gray
    exit 1
}
Write-Host ""

# Paso 4: Instalar Node.js y Moltbot
Write-Host "Paso 4: Instalando Node.js y Moltbot..." -ForegroundColor Yellow
Write-Host "Esto tomara 10-15 minutos..." -ForegroundColor Gray
Write-Host ""
Write-Host "Ejecutando en la VM:" -ForegroundColor Cyan
Write-Host "  chmod +x ~/scripts/*.sh" -ForegroundColor Gray
Write-Host "  bash ~/scripts/setup-complete.sh" -ForegroundColor Gray
Write-Host ""

$installCommand = "ssh $vmUser@$vmIP -p $vmPort 'chmod +x ~/scripts/*.sh && bash ~/scripts/setup-complete.sh'"
Write-Host "Ingresa tu contraseña cuando se solicite:" -ForegroundColor Cyan
Write-Host ""

Invoke-Expression $installCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[OK] Instalacion completada!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[!] Error en la instalacion" -ForegroundColor Yellow
    Write-Host "    Conectate manualmente y ejecuta:" -ForegroundColor Gray
    Write-Host "    ssh $vmUser@$vmIP -p $vmPort" -ForegroundColor Gray
    Write-Host "    bash ~/scripts/setup-complete.sh" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Configuracion completada!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Proximo paso: Conectar Cursor" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Abre Cursor" -ForegroundColor Gray
Write-Host "2. Ctrl+Shift+P -> Remote-SSH: Connect to Host" -ForegroundColor Gray
Write-Host "3. Escribe: $vmUser@$vmIP -p $vmPort" -ForegroundColor Gray
Write-Host "4. Ingresa tu contraseña" -ForegroundColor Gray
Write-Host "5. Abre carpeta: /home/$vmUser/moltbot-project" -ForegroundColor Gray
Write-Host ""












