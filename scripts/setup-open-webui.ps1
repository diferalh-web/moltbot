# Script para configurar Open WebUI con Ollama-Mistral
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar Open WebUI para Ollama" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Docker
Write-Host "[1/5] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    Write-Host "[OK] Docker instalado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker no está instalado" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Obtener IP local
Write-Host "[2/5] Obteniendo IP local..." -ForegroundColor Yellow
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -notlike "192.168.56.*" -and $_.IPAddress -notlike "172.20.*"} | Select-Object -First 1).IPAddress
if (-not $ipAddress) {
    $ipAddress = "192.168.100.42"
}
Write-Host "[OK] IP: $ipAddress" -ForegroundColor Green
Write-Host ""

# Verificar que ollama-mistral está corriendo
Write-Host "[3/5] Verificando contenedor ollama-mistral..." -ForegroundColor Yellow
$mistralRunning = docker ps --filter "name=ollama-mistral" --format "{{.Names}}" 2>$null
if ($mistralRunning -ne "ollama-mistral") {
    Write-Host "[X] Contenedor ollama-mistral no está corriendo" -ForegroundColor Red
    Write-Host "    Ejecuta: docker start ollama-mistral" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] ollama-mistral está corriendo" -ForegroundColor Green
Write-Host ""

# Crear contenedor Open WebUI
Write-Host "[4/5] Creando contenedor Open WebUI..." -ForegroundColor Yellow

# Detener y eliminar si existe
docker stop open-webui 2>$null | Out-Null
docker rm open-webui 2>$null | Out-Null

# Crear nuevo contenedor
docker run -d `
  --name open-webui `
  -p 3000:8080 `
  -v ${env:USERPROFILE}/open-webui-data:/app/backend/data `
  --add-host=host.docker.internal:host-gateway `
  -e OLLAMA_BASE_URL=http://host.docker.internal:11436 `
  --restart unless-stopped `
  --gpus all `
  ghcr.io/open-webui/open-webui:main

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Contenedor Open WebUI creado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "[5/5] Esperando a que Open WebUI inicie (30 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Verificar estado
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Open WebUI configurado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Acceso a la interfaz web:" -ForegroundColor Yellow
Write-Host "  http://localhost:3000" -ForegroundColor Cyan
Write-Host "  http://$ipAddress:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuración:" -ForegroundColor Yellow
Write-Host "  - Conectado a Ollama-Mistral (puerto 11436)" -ForegroundColor Gray
Write-Host "  - Usando GPU NVIDIA" -ForegroundColor Gray
Write-Host "  - Datos guardados en: ${env:USERPROFILE}\open-webui-data" -ForegroundColor Gray
Write-Host ""
Write-Host "Primera vez:" -ForegroundColor Yellow
Write-Host "  1. Abre http://localhost:3000 en tu navegador" -ForegroundColor Gray
Write-Host "  2. Crea una cuenta (primera vez)" -ForegroundColor Gray
Write-Host "  3. Selecciona el modelo 'mistral' en la interfaz" -ForegroundColor Gray
Write-Host ""
Write-Host "Verificar estado:" -ForegroundColor Yellow
Write-Host "  docker ps | findstr open-webui" -ForegroundColor White
Write-Host "  docker logs open-webui --tail 20" -ForegroundColor White
Write-Host ""












