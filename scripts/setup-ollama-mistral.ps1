# Script para configurar Ollama con Mistral en Docker (Windows Host)
# Ejecuta este script en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurando Ollama-Mistral en Docker" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Docker
Write-Host "[1/6] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    Write-Host "[OK] Docker instalado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker no está instalado" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Obtener IP local
Write-Host "[2/6] Obteniendo IP local..." -ForegroundColor Yellow
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*"} | Select-Object -First 1).IPAddress
Write-Host "[OK] IP local: $ipAddress" -ForegroundColor Green
Write-Host ""

# Crear directorio para datos
$ollamaMistralData = "$env:USERPROFILE\ollama-mistral-data"
Write-Host "[3/6] Creando directorio para datos: $ollamaMistralData" -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $ollamaMistralData | Out-Null
Write-Host "[OK] Directorio creado" -ForegroundColor Green
Write-Host ""

# Verificar si el contenedor ya existe
Write-Host "[4/6] Verificando contenedor ollama-mistral..." -ForegroundColor Yellow
$existing = docker ps -a --filter "name=ollama-mistral" --format "{{.Names}}" 2>$null
if ($existing -eq "ollama-mistral") {
    Write-Host "[!] Contenedor ollama-mistral ya existe" -ForegroundColor Yellow
    $response = Read-Host "¿Deseas eliminarlo y crear uno nuevo? (S/N)"
    if ($response -eq "S" -or $response -eq "s" -or $response -eq "Y" -or $response -eq "y") {
        docker stop ollama-mistral 2>$null
        docker rm ollama-mistral 2>$null
        Write-Host "[OK] Contenedor eliminado" -ForegroundColor Green
    } else {
        Write-Host "Usando contenedor existente" -ForegroundColor Gray
        docker start ollama-mistral 2>$null
        Write-Host "[OK] Contenedor iniciado" -ForegroundColor Green
        Write-Host ""
        Write-Host "IP para configurar en Moltbot: http://$ipAddress:11436" -ForegroundColor Cyan
        exit 0
    }
}
Write-Host ""

# Ejecutar Ollama para Mistral (puerto 11436)
Write-Host "[5/6] Ejecutando Ollama-Mistral en Docker (puerto 11436)..." -ForegroundColor Yellow
docker run -d `
  --name ollama-mistral `
  -p 11436:11434 `
  -v "${ollamaMistralData}:/root/.ollama" `
  --restart unless-stopped `
  ollama/ollama:latest

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Ollama-Mistral iniciado en Docker" -ForegroundColor Green
} else {
    Write-Host "[X] Error al iniciar Ollama-Mistral" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Esperando a que Ollama-Mistral esté listo..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Descargar Mistral
Write-Host "[6/6] Descargando modelo Mistral (esto puede tardar varios minutos, ~4GB)..." -ForegroundColor Yellow
docker exec ollama-mistral ollama pull mistral

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Mistral descargado correctamente" -ForegroundColor Green
} else {
    Write-Host "[X] Error al descargar Mistral" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Configuración completada!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuración:" -ForegroundColor Yellow
Write-Host "  Contenedor: ollama-mistral" -ForegroundColor Gray
Write-Host "  Puerto: 11436" -ForegroundColor Gray
Write-Host "  URL para Moltbot: http://$ipAddress:11436/v1" -ForegroundColor Cyan
Write-Host ""
Write-Host "Verificar modelos:" -ForegroundColor Yellow
Write-Host "  docker exec ollama-mistral ollama list" -ForegroundColor Gray
Write-Host ""
Write-Host "Probar conexión:" -ForegroundColor Yellow
Write-Host "  curl http://$ipAddress:11436/api/tags" -ForegroundColor Gray
Write-Host ""












