# Script para configurar Open WebUI con todos los servicios unificados
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar Open WebUI Unificado" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Docker
Write-Host "[1/7] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    Write-Host "[OK] Docker instalado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker no está instalado" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Verificar que los servicios están corriendo
Write-Host "[2/7] Verificando servicios..." -ForegroundColor Yellow
$services = @(
    @{Name="ollama-mistral"; Port=11436; Description="LLM General"},
    @{Name="ollama-qwen"; Port=11437; Description="LLM Alternativo"},
    @{Name="ollama-code"; Port=11438; Description="IA Programación"},
    @{Name="ollama-flux"; Port=11439; Description="Generación Imágenes"},
    @{Name="comfyui"; Port=7860; Description="Imágenes Avanzadas"},
    @{Name="stable-video"; Port=8000; Description="Generación Video"},
    @{Name="coqui-tts"; Port=5002; Description="Síntesis Voz"},
    @{Name="web-search"; Port=5003; Description="Búsqueda Web"},
    @{Name="external-apis-gateway"; Port=5004; Description="APIs Externas"}
)

$running = 0
$stopped = 0
foreach ($service in $services) {
    $status = docker ps --filter "name=$($service.Name)" --format "{{.Names}}" 2>$null
    if ($status -eq $service.Name) {
        Write-Host "[OK] $($service.Name) - $($service.Description)" -ForegroundColor Green
        $running++
    } else {
        Write-Host "[!] $($service.Name) - $($service.Description) (no está corriendo)" -ForegroundColor Yellow
        $stopped++
    }
}
Write-Host ""
Write-Host "Servicios corriendo: $running / $($services.Count)" -ForegroundColor $(if ($running -eq $services.Count) { "Green" } else { "Yellow" })
Write-Host ""

# Verificar que existe el directorio de extensiones
Write-Host "[3/7] Verificando extensiones..." -ForegroundColor Yellow
$extensionsPath = ".\extensions\open-webui-multimedia"
if (-not (Test-Path $extensionsPath)) {
    Write-Host "[!] Directorio de extensiones no existe, se creará" -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $extensionsPath | Out-Null
}

# Verificar archivos de extensiones
$requiredExtensions = @(
    "web_search.py",
    "voice_cloning.py",
    "external_apis.py",
    "marketing_tools.py",
    "marketing_templates.py",
    "image_generator.py",
    "video_generator.py",
    "__init__.py"
)

$missingExtensions = @()
foreach ($ext in $requiredExtensions) {
    $extPath = Join-Path $extensionsPath $ext
    if (-not (Test-Path $extPath)) {
        $missingExtensions += $ext
    }
}

if ($missingExtensions.Count -gt 0) {
    Write-Host "[!] Extensiones faltantes: $($missingExtensions -join ', ')" -ForegroundColor Yellow
    Write-Host "    Algunas funcionalidades pueden no estar disponibles" -ForegroundColor Yellow
} else {
    Write-Host "[OK] Todas las extensiones encontradas" -ForegroundColor Green
}
Write-Host ""

# Detener Open WebUI actual si existe
Write-Host "[4/7] Deteniendo Open WebUI actual..." -ForegroundColor Yellow
docker stop open-webui 2>$null | Out-Null
docker rm open-webui 2>$null | Out-Null
Write-Host "[OK] Open WebUI detenido" -ForegroundColor Green
Write-Host ""

# Crear nuevo contenedor Open WebUI con configuración unificada
Write-Host "[5/7] Creando Open WebUI unificado..." -ForegroundColor Yellow

# Usar el proxy Ollama que agrega todos los modelos
$ollamaBaseUrl = "http://host.docker.internal:11440"

# Leer API keys opcionales
$tavilyKey = $env:TAVILY_API_KEY
$geminiKey = $env:GEMINI_API_KEY
$huggingfaceKey = $env:HUGGINGFACE_API_KEY

docker run -d `
  --name open-webui `
  -p 8082:8080 `
  -v "${env:USERPROFILE}/open-webui-data:/app/backend/data" `
  -v "${PWD}/extensions/open-webui-multimedia:/app/extensions/multimedia:ro" `
  --add-host=host.docker.internal:host-gateway `
      -e OLLAMA_BASE_URL=$ollamaBaseUrl `
  -e ENABLE_IMAGE_GENERATION=true `
  -e IMAGE_GENERATION_API_URL=http://host.docker.internal:7860 `
  -e VIDEO_GENERATION_API_URL=http://host.docker.internal:8000 `
  -e TTS_API_URL=http://host.docker.internal:5002 `
  -e FLUX_API_URL=http://host.docker.internal:11439 `
  -e WEB_SEARCH_API_URL=http://host.docker.internal:5003 `
  -e EXTERNAL_APIS_GATEWAY_URL=http://host.docker.internal:5004 `
  -e TAVILY_API_KEY=$tavilyKey `
  -e GEMINI_API_KEY=$geminiKey `
  -e HUGGINGFACE_API_KEY=$huggingfaceKey `
  --restart unless-stopped `
  --gpus all `
  ghcr.io/open-webui/open-webui:main

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Open WebUI unificado creado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "[6/7] Esperando a que Open WebUI inicie (30 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Obtener IP local
Write-Host "[7/7] Obteniendo información de acceso..." -ForegroundColor Yellow
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -notlike "192.168.56.*" -and $_.IPAddress -notlike "172.20.*"} | Select-Object -First 1).IPAddress
if (-not $ipAddress) {
    $ipAddress = "192.168.100.42"
}
Write-Host ""

# Verificar estado
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Open WebUI Unificado configurado!" -ForegroundColor Green
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
Write-Host "  - Síntesis Voz: Coqui TTS (5002) + Clonación XTTS" -ForegroundColor Gray
Write-Host "  - Búsqueda Web: DuckDuckGo + Tavily (5003)" -ForegroundColor Gray
Write-Host "  - APIs Externas: Gemini + Hugging Face (5004)" -ForegroundColor Gray
Write-Host ""
Write-Host "Funcionalidades de Marketing:" -ForegroundColor Yellow
Write-Host "  - Generación de copy de marketing" -ForegroundColor Gray
Write-Host "  - Generación de hashtags" -ForegroundColor Gray
Write-Host "  - Análisis de competencia" -ForegroundColor Gray
Write-Host "  - Imágenes para redes sociales (dimensiones optimizadas)" -ForegroundColor Gray
Write-Host "  - Videos de marketing con narración" -ForegroundColor Gray
Write-Host "  - Templates y workflows predefinidos" -ForegroundColor Gray
Write-Host ""
Write-Host "Primera vez:" -ForegroundColor Yellow
Write-Host "  1. Abre http://localhost:8082 en tu navegador" -ForegroundColor White
Write-Host "  2. Crea una cuenta (primera vez)" -ForegroundColor White
Write-Host "  3. Selecciona el modelo deseado en la interfaz" -ForegroundColor White
Write-Host "  4. Explora las nuevas funcionalidades de marketing" -ForegroundColor White
Write-Host ""
Write-Host "Configuración de API Keys (Opcional):" -ForegroundColor Yellow
if (-not $tavilyKey) {
    Write-Host "  - TAVILY_API_KEY: No configurada (DuckDuckGo funciona sin key)" -ForegroundColor Gray
}
if (-not $geminiKey) {
    Write-Host "  - GEMINI_API_KEY: No configurada (opcional)" -ForegroundColor Gray
}
if (-not $huggingfaceKey) {
    Write-Host "  - HUGGINGFACE_API_KEY: No configurada (algunos modelos funcionan sin key)" -ForegroundColor Gray
}
Write-Host ""
Write-Host "Verificar estado:" -ForegroundColor Yellow
Write-Host "  docker ps | findstr open-webui" -ForegroundColor White
Write-Host "  docker logs open-webui --tail 20" -ForegroundColor White
Write-Host ""

