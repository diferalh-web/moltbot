# Script para configurar Open WebUI con múltiples instancias de Ollama
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar Open WebUI con Múltiples Ollama" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Docker
Write-Host "[1/4] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    Write-Host "[OK] Docker instalado" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker no está instalado" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Verificar que los servicios Ollama estén corriendo
Write-Host "[2/4] Verificando servicios Ollama..." -ForegroundColor Yellow
$services = @(
    @{Name="ollama-mistral"; Port=11436},
    @{Name="ollama-qwen"; Port=11437},
    @{Name="ollama-code"; Port=11438}
)

foreach ($service in $services) {
    $status = docker ps --filter "name=$($service.Name)" --format "{{.Names}}" 2>$null
    if ($status -eq $service.Name) {
        Write-Host "[OK] $($service.Name) está corriendo" -ForegroundColor Green
    } else {
        Write-Host "[!] $($service.Name) no está corriendo" -ForegroundColor Yellow
    }
}
Write-Host ""

# Detener Open WebUI actual
Write-Host "[3/4] Deteniendo Open WebUI actual..." -ForegroundColor Yellow
docker stop open-webui 2>$null | Out-Null
docker rm open-webui 2>$null | Out-Null
Write-Host "[OK] Open WebUI detenido" -ForegroundColor Green
Write-Host ""

# Crear nuevo contenedor con configuración para múltiples Ollama
Write-Host "[4/4] Recreando Open WebUI con soporte para múltiples Ollama..." -ForegroundColor Yellow
Write-Host "      Nota: Los modelos se agregarán manualmente en la interfaz" -ForegroundColor Gray
Write-Host ""

$dockerCmd = @"
docker run -d `
  --name open-webui `
  -p 8082:8080 `
  -v "${env:USERPROFILE}/open-webui-data:/app/backend/data" `
  -v "${PWD}/extensions/open-webui-multimedia:/app/extensions/multimedia:ro" `
  --add-host=host.docker.internal:host-gateway `
  -e OLLAMA_BASE_URL=http://host.docker.internal:11436 `
  -e ENABLE_IMAGE_GENERATION=true `
  -e IMAGE_GENERATION_API_URL=http://host.docker.internal:7860 `
  -e VIDEO_GENERATION_API_URL=http://host.docker.internal:8000 `
  -e TTS_API_URL=http://host.docker.internal:5002 `
  --restart unless-stopped `
  --gpus all `
  ghcr.io/open-webui/open-webui:main
"@

Invoke-Expression $dockerCmd

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Open WebUI recreado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al recrear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "Esperando 30 segundos para que Open WebUI inicie..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Obtener IP local
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -notlike "192.168.56.*" -and $_.IPAddress -notlike "172.20.*"} | Select-Object -First 1).IPAddress
if (-not $ipAddress) {
    $ipAddress = "192.168.100.42"
}

# Resumen
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Open WebUI configurado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Acceso:" -ForegroundColor Yellow
Write-Host "  http://localhost:8082" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para agregar los demás modelos:" -ForegroundColor Yellow
Write-Host "  1. Abre http://localhost:8082" -ForegroundColor White
Write-Host "  2. Ve a Settings → External Tools" -ForegroundColor White
Write-Host "  3. Busca la sección de Ollama/Backend" -ForegroundColor White
Write-Host "  4. Agrega nuevas conexiones:" -ForegroundColor White
Write-Host "     - Qwen: http://host.docker.internal:11437" -ForegroundColor Gray
Write-Host "     - Code: http://host.docker.internal:11438" -ForegroundColor Gray
Write-Host ""
Write-Host "O usa el script de configuración manual (ver AGREGAR_MODELOS_MANUAL.md)" -ForegroundColor Gray
Write-Host ""












