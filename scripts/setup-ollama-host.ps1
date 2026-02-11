# Script para configurar Ollama en Docker (Windows Host)
# Ejecuta este script en PowerShell de Windows

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurando Ollama en Docker (Windows)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Docker
Write-Host "Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    Write-Host "[OK] Docker instalado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker no esta instalado" -ForegroundColor Red
    Write-Host "    Instala Docker Desktop desde: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Obtener IP local
Write-Host ""
Write-Host "Obteniendo IP local..." -ForegroundColor Yellow
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*"} | Select-Object -First 1).IPAddress
Write-Host "[OK] IP local: $ipAddress" -ForegroundColor Green
Write-Host ""

# Crear directorio para datos
$ollamaData = "$env:USERPROFILE\ollama-data"
Write-Host "Creando directorio para datos: $ollamaData" -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $ollamaData | Out-Null
Write-Host "[OK] Directorio creado" -ForegroundColor Green
Write-Host ""

# Verificar si Ollama ya está corriendo
Write-Host "Verificando si Ollama ya esta corriendo..." -ForegroundColor Yellow
$existing = docker ps -a --filter "name=ollama" --format "{{.Names}}" 2>$null
if ($existing -eq "ollama") {
    Write-Host "[!] Ollama ya existe" -ForegroundColor Yellow
    $response = Read-Host "Deseas eliminarlo y crear uno nuevo? (S/N)"
    if ($response -eq "S" -or $response -eq "s" -or $response -eq "Y" -or $response -eq "y") {
        docker stop ollama 2>$null
        docker rm ollama 2>$null
        Write-Host "[OK] Ollama eliminado" -ForegroundColor Green
    } else {
        Write-Host "Usando contenedor existente" -ForegroundColor Gray
        docker start ollama 2>$null
        Write-Host "[OK] Ollama iniciado" -ForegroundColor Green
        Write-Host ""
        Write-Host "IP para configurar en Moltbot: http://$ipAddress:11434" -ForegroundColor Cyan
        exit 0
    }
}

# Ejecutar Ollama
Write-Host "Ejecutando Ollama en Docker..." -ForegroundColor Yellow
docker run -d `
  --name ollama `
  -p 11434:11434 `
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
$status = docker ps --filter "name=ollama" --format "{{.Status}}" 2>$null
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
Write-Host "IP para configurar en Moltbot (VM):" -ForegroundColor Yellow
Write-Host "  http://$ipAddress:11434" -ForegroundColor Cyan
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "1. Configurar firewall de Windows (ver guia)" -ForegroundColor Gray
Write-Host "2. Descargar un modelo: docker exec -it ollama ollama pull llama2" -ForegroundColor Gray
Write-Host "3. Configurar Moltbot en la VM con la IP de arriba" -ForegroundColor Gray
Write-Host ""












