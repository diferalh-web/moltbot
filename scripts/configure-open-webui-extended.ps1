# Script para configurar Open WebUI con todos los servicios extendidos
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar Open WebUI Extendido" -ForegroundColor Cyan
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

# Verificar que los servicios están corriendo
Write-Host "[2/6] Verificando servicios..." -ForegroundColor Yellow
$services = @(
    @{Name="ollama-mistral"; Port=11436},
    @{Name="ollama-qwen"; Port=11437},
    @{Name="ollama-code"; Port=11438},
    @{Name="ollama-flux"; Port=11439},
    @{Name="comfyui"; Port=7860},
    @{Name="stable-video"; Port=8000},
    @{Name="coqui-tts"; Port=5002}
)

$allRunning = $true
foreach ($service in $services) {
    $status = docker ps --filter "name=$($service.Name)" --format "{{.Names}}" 2>$null
    if ($status -eq $service.Name) {
        Write-Host "[OK] $($service.Name) está corriendo" -ForegroundColor Green
    } else {
        Write-Host "[!] $($service.Name) no está corriendo (opcional)" -ForegroundColor Yellow
    }
}
Write-Host ""

# Verificar que existe el directorio de extensiones
Write-Host "[3/6] Verificando extensiones..." -ForegroundColor Yellow
$extensionsPath = ".\extensions\open-webui-multimedia"
if (-not (Test-Path $extensionsPath)) {
    Write-Host "[!] Directorio de extensiones no existe, se creará" -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $extensionsPath | Out-Null
}
Write-Host "[OK] Extensiones listas" -ForegroundColor Green
Write-Host ""

# Detener Open WebUI actual si existe
Write-Host "[4/6] Deteniendo Open WebUI actual..." -ForegroundColor Yellow
docker stop open-webui 2>$null | Out-Null
docker rm open-webui 2>$null | Out-Null
Write-Host "[OK] Open WebUI detenido" -ForegroundColor Green
Write-Host ""

# Crear nuevo contenedor Open WebUI con configuración extendida
Write-Host "[5/6] Creando Open WebUI extendido..." -ForegroundColor Yellow

$ollamaUrls = "http://host.docker.internal:11436|http://host.docker.internal:11437|http://host.docker.internal:11438|http://host.docker.internal:11439"

docker run -d `
  --name open-webui `
  -p 8082:8080 `
  -v "${env:USERPROFILE}/open-webui-data:/app/backend/data" `
  -v "${PWD}/extensions/open-webui-multimedia:/app/extensions/multimedia:ro" `
  --add-host=host.docker.internal:host-gateway `
  -e OLLAMA_BASE_URL=http://host.docker.internal:11436 `
  -e "OLLAMA_BASE_URLS=$ollamaUrls" `
  -e ENABLE_IMAGE_GENERATION=true `
  -e IMAGE_GENERATION_API_URL=http://host.docker.internal:7860 `
  -e VIDEO_GENERATION_API_URL=http://host.docker.internal:8000 `
  -e TTS_API_URL=http://host.docker.internal:5002 `
  --restart unless-stopped `
  --gpus all `
  ghcr.io/open-webui/open-webui:main

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Open WebUI extendido creado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "[6/6] Esperando a que Open WebUI inicie (30 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Obtener IP local
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -notlike "192.168.56.*" -and $_.IPAddress -notlike "172.20.*"} | Select-Object -First 1).IPAddress
if (-not $ipAddress) {
    $ipAddress = "192.168.100.42"
}

# Verificar estado
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Open WebUI Extendido configurado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Estado del contenedor:" -ForegroundColor Yellow
docker ps --filter "name=open-webui" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""
Write-Host "Acceso a la interfaz web:" -ForegroundColor Yellow
Write-Host "  http://localhost:8082" -ForegroundColor Cyan
Write-Host "  http://$ipAddress:8082" -ForegroundColor Cyan
Write-Host ""
Write-Host "Servicios integrados:" -ForegroundColor Yellow
Write-Host "  - LLM General: Mistral (11436), Qwen (11437)" -ForegroundColor Gray
Write-Host "  - IA Programación: DeepSeek-Coder, WizardCoder, CodeLlama (11438)" -ForegroundColor Gray
Write-Host "  - Generación Imágenes: Flux (11439), ComfyUI (7860)" -ForegroundColor Gray
Write-Host "  - Generación Video: Stable Video (8000)" -ForegroundColor Gray
Write-Host "  - Síntesis Voz: Coqui TTS (5002)" -ForegroundColor Gray
Write-Host ""
Write-Host "Primera vez:" -ForegroundColor Yellow
Write-Host "  1. Abre http://localhost:8082 en tu navegador" -ForegroundColor White
Write-Host "  2. Crea una cuenta (primera vez)" -ForegroundColor White
Write-Host "  3. Selecciona el modelo deseado en la interfaz" -ForegroundColor White
Write-Host ""
Write-Host "Verificar estado:" -ForegroundColor Yellow
Write-Host "  docker ps | findstr open-webui" -ForegroundColor White
Write-Host "  docker logs open-webui --tail 20" -ForegroundColor White
Write-Host ""

