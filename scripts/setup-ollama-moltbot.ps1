# Script para configurar Ollama específico para Moltbot
# Ejecuta este script en PowerShell de Windows

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurando Ollama para Moltbot" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Docker
Write-Host "Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    Write-Host "[OK] Docker instalado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker no esta instalado" -ForegroundColor Red
    exit 1
}

# Obtener IP local (preferir la IP de la red local, no VirtualBox)
Write-Host ""
Write-Host "Obteniendo IP local..." -ForegroundColor Yellow
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.InterfaceAlias -notlike "*Loopback*" -and 
    $_.IPAddress -notlike "169.254.*" -and
    $_.IPAddress -notlike "192.168.56.*" -and
    $_.IPAddress -notlike "172.20.*"
} | Select-Object -First 1

if ($ipAddresses) {
    $ipAddress = $ipAddresses.IPAddress
    Write-Host "[OK] IP local: $ipAddress" -ForegroundColor Green
} else {
    # Fallback a la primera IP disponible
    $ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | Select-Object -First 1).IPAddress
    Write-Host "[OK] IP local: $ipAddress" -ForegroundColor Green
}

Write-Host ""

# Configuración
$containerName = "ollama-moltbot"
$hostPort = 11435  # Puerto diferente al de anails_ollama (11434)
$ollamaData = "$env:USERPROFILE\ollama-moltbot-data"

# Crear directorio para datos
Write-Host "Creando directorio para datos: $ollamaData" -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $ollamaData | Out-Null
Write-Host "[OK] Directorio creado" -ForegroundColor Green
Write-Host ""

# Verificar si el contenedor ya existe
Write-Host "Verificando si el contenedor ya existe..." -ForegroundColor Yellow
$existing = docker ps -a --filter "name=$containerName" --format "{{.Names}}" 2>$null
if ($existing -eq $containerName) {
    Write-Host "[!] El contenedor $containerName ya existe" -ForegroundColor Yellow
    $response = Read-Host "Deseas eliminarlo y crear uno nuevo? (S/N)"
    if ($response -eq "S" -or $response -eq "s" -or $response -eq "Y" -or $response -eq "y") {
        docker stop $containerName 2>$null
        docker rm $containerName 2>$null
        Write-Host "[OK] Contenedor eliminado" -ForegroundColor Green
    } else {
        Write-Host "Iniciando contenedor existente..." -ForegroundColor Gray
        docker start $containerName 2>$null
        Write-Host "[OK] Contenedor iniciado" -ForegroundColor Green
        Write-Host ""
        Write-Host "IP para configurar en Moltbot: http://$ipAddress:$hostPort" -ForegroundColor Cyan
        exit 0
    }
}

# Ejecutar Ollama
Write-Host "Ejecutando Ollama en Docker..." -ForegroundColor Yellow
Write-Host "  Nombre: $containerName" -ForegroundColor Gray
Write-Host "  Puerto: $hostPort" -ForegroundColor Gray
Write-Host "  Datos: $ollamaData" -ForegroundColor Gray
Write-Host ""

docker run -d `
  --name $containerName `
  -p "${hostPort}:11434" `
  -v "${ollamaData}:/root/.ollama" `
  --restart unless-stopped `
  ollama/ollama:latest

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Ollama iniciado en Docker" -ForegroundColor Green
} else {
    Write-Host "[X] Error al iniciar Ollama" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Esperando a que Ollama este listo..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Verificar que está corriendo
$status = docker ps --filter "name=$containerName" --format "{{.Status}}" 2>$null
if ($status) {
    Write-Host "[OK] Ollama esta corriendo: $status" -ForegroundColor Green
} else {
    Write-Host "[!] Ollama puede no estar listo aun" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Configuracion completada!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuracion:" -ForegroundColor Yellow
Write-Host "  Contenedor: $containerName" -ForegroundColor Gray
Write-Host "  Puerto: $hostPort" -ForegroundColor Gray
Write-Host "  IP: $ipAddress" -ForegroundColor Gray
Write-Host ""
Write-Host "IP para configurar en Moltbot (VM):" -ForegroundColor Yellow
Write-Host "  http://$ipAddress:$hostPort" -ForegroundColor Cyan
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "1. Configurar firewall de Windows (ver guia)" -ForegroundColor Gray
Write-Host "2. Descargar un modelo:" -ForegroundColor Gray
Write-Host "   docker exec -it $containerName ollama pull llama2" -ForegroundColor Cyan
Write-Host "3. Configurar Moltbot en la VM con la IP de arriba" -ForegroundColor Gray
Write-Host ""












