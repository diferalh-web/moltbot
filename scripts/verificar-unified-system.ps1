# Script para verificar el estado de todos los servicios unificados
# Ejecutar en PowerShell de Windows

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Verificar Sistema Unificado de IA" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Servicios a verificar
$services = @(
    @{Name="ollama-mistral"; Port=11436; Description="LLM General - Mistral"},
    @{Name="ollama-qwen"; Port=11437; Description="LLM General - Qwen"},
    @{Name="ollama-code"; Port=11438; Description="IA de Programación"},
    @{Name="ollama-flux"; Port=11439; Description="Generación de Imágenes - Flux"},
    @{Name="comfyui"; Port=7860; Description="Generación Avanzada de Imágenes"},
    @{Name="stable-video"; Port=8000; Description="Generación de Video"},
    @{Name="coqui-tts"; Port=5002; Description="Síntesis de Voz + Clonación"},
    @{Name="web-search"; Port=5003; Description="Búsqueda Web"},
    @{Name="external-apis-gateway"; Port=5004; Description="APIs Externas (Gemini, Hugging Face)"},
    @{Name="open-webui"; Port=8082; Description="Interfaz Web Unificada"}
)

Write-Host "[1/4] Verificando contenedores Docker..." -ForegroundColor Yellow
Write-Host ""

$running = 0
$stopped = 0

foreach ($service in $services) {
    $containerName = $service.Name
    $status = docker ps --filter "name=$containerName" --format "{{.Names}}" 2>$null
    
    if ($status -eq $containerName) {
        $containerStatus = docker ps --filter "name=$containerName" --format "{{.Status}}" 2>$null
        Write-Host "[OK] $containerName - $($service.Description)" -ForegroundColor Green
        Write-Host "     Estado: $containerStatus" -ForegroundColor Gray
        Write-Host "     Puerto: $($service.Port)" -ForegroundColor Gray
        $running++
    } else {
        Write-Host "[X] $containerName - $($service.Description)" -ForegroundColor Red
        Write-Host "     Estado: No está corriendo" -ForegroundColor Gray
        $stopped++
    }
    Write-Host ""
}

Write-Host "[2/4] Verificando conectividad de APIs..." -ForegroundColor Yellow
Write-Host ""

$accessible = 0
$inaccessible = 0

foreach ($service in $services) {
    $port = $service.Port
    $containerName = $service.Name
    
    # Verificar si el contenedor está corriendo primero
    $isRunning = docker ps --filter "name=$containerName" --format "{{.Names}}" 2>$null
    if ($isRunning -ne $containerName) {
        Write-Host "[SKIP] $containerName (no está corriendo)" -ForegroundColor Yellow
        continue
    }
    
    # Probar conectividad según el tipo de servicio
    if ($containerName -like "ollama-*") {
        $testUrl = "http://localhost:$port/api/tags"
    } elseif ($containerName -eq "comfyui") {
        $testUrl = "http://localhost:$port"
    } elseif ($containerName -eq "stable-video") {
        $testUrl = "http://localhost:$port/health"
    } elseif ($containerName -eq "coqui-tts") {
        $testUrl = "http://localhost:$port/health"
    } elseif ($containerName -eq "web-search") {
        $testUrl = "http://localhost:$port/health"
    } elseif ($containerName -eq "external-apis-gateway") {
        $testUrl = "http://localhost:$port/health"
    } elseif ($containerName -eq "open-webui") {
        $testUrl = "http://localhost:$port"
    } else {
        $testUrl = "http://localhost:$port"
    }
    
    try {
        $response = Invoke-WebRequest -Uri $testUrl -Method Get -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        Write-Host "[OK] $containerName - API accesible en puerto $port" -ForegroundColor Green
        $accessible++
    } catch {
        Write-Host "[!] $containerName - API no accesible en puerto $port" -ForegroundColor Yellow
        Write-Host "     Error: $($_.Exception.Message)" -ForegroundColor Gray
        $inaccessible++
    }
}

Write-Host ""
Write-Host "[3/4] Verificando funcionalidades específicas..." -ForegroundColor Yellow
Write-Host ""

# Verificar clonación de voz
try {
    $ttsResponse = Invoke-WebRequest -Uri "http://localhost:5002/api/models" -Method Get -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    $ttsData = $ttsResponse.Content | ConvertFrom-Json
    if ($ttsData.voice_cloning_available) {
        Write-Host "[OK] Clonación de voz (XTTS) disponible" -ForegroundColor Green
    } else {
        Write-Host "[!] Clonación de voz no disponible aún (se carga bajo demanda)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[SKIP] No se pudo verificar clonación de voz" -ForegroundColor Yellow
}

# Verificar proveedores de búsqueda web
try {
    $searchResponse = Invoke-WebRequest -Uri "http://localhost:5003/api/providers" -Method Get -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    $searchData = $searchResponse.Content | ConvertFrom-Json
    $providers = $searchData.providers
    Write-Host "[OK] Proveedores de búsqueda web:" -ForegroundColor Green
    foreach ($provider in $providers) {
        $status = if ($provider.available) { "disponible" } else { "requiere API key" }
        Write-Host "     - $($provider.name): $status" -ForegroundColor Gray
    }
} catch {
    Write-Host "[SKIP] No se pudo verificar proveedores de búsqueda" -ForegroundColor Yellow
}

# Verificar APIs externas
try {
    $apisResponse = Invoke-WebRequest -Uri "http://localhost:5004/api/providers" -Method Get -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    $apisData = $apisResponse.Content | ConvertFrom-Json
    $providers = $apisData.providers
    Write-Host "[OK] Proveedores de APIs externas:" -ForegroundColor Green
    foreach ($provider in $providers) {
        $status = if ($provider.available) { "disponible" } else { "requiere API key" }
        Write-Host "     - $($provider.name): $status" -ForegroundColor Gray
    }
} catch {
    Write-Host "[SKIP] No se pudo verificar APIs externas" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[4/4] Verificando uso de GPU..." -ForegroundColor Yellow
Write-Host ""

try {
    $gpuInfo = nvidia-smi --query-gpu=name,memory.used,memory.total,utilization.gpu --format=csv,noheader 2>$null
    if ($gpuInfo) {
        Write-Host "[OK] GPU NVIDIA detectada:" -ForegroundColor Green
        $gpuInfo | ForEach-Object {
            Write-Host "     $_" -ForegroundColor Gray
        }
    } else {
        Write-Host "[!] No se pudo obtener información de GPU" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[!] nvidia-smi no disponible" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Resumen" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Contenedores:" -ForegroundColor Yellow
Write-Host "  - Corriendo: $running / $($services.Count)" -ForegroundColor $(if ($running -eq $services.Count) { "Green" } else { "Yellow" })
Write-Host "  - Detenidos: $stopped" -ForegroundColor $(if ($stopped -gt 0) { "Red" } else { "Green" })
Write-Host ""
Write-Host "APIs:" -ForegroundColor Yellow
Write-Host "  - Accesibles: $accessible" -ForegroundColor Green
Write-Host "  - Inaccesibles: $inaccessible" -ForegroundColor $(if ($inaccessible -gt 0) { "Yellow" } else { "Green" })
Write-Host ""
Write-Host "Funcionalidades:" -ForegroundColor Yellow
Write-Host "  - Búsqueda Web: DuckDuckGo (sin API key) + Tavily (opcional)" -ForegroundColor Gray
Write-Host "  - Clonación de Voz: XTTS (se carga bajo demanda)" -ForegroundColor Gray
Write-Host "  - APIs Externas: Gemini (requiere API key) + Hugging Face (opcional)" -ForegroundColor Gray
Write-Host "  - Marketing: Copy, hashtags, imágenes, videos" -ForegroundColor Gray
Write-Host ""
Write-Host "Acceso a Open WebUI:" -ForegroundColor Yellow
Write-Host "  http://localhost:8082" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para usar todas las funcionalidades:" -ForegroundColor Yellow
Write-Host "  1. Abre http://localhost:8082" -ForegroundColor White
Write-Host "  2. Crea una cuenta si es la primera vez" -ForegroundColor White
Write-Host "  3. Explora las funciones de marketing, búsqueda web y clonación de voz" -ForegroundColor White
Write-Host ""









