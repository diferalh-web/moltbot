# Verificacion completa de la arquitectura post-reinicio
# Docker, Open WebUI, ComfyUI y conectividad

$ErrorActionPreference = "SilentlyContinue"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Verificacion Arquitectura Completa" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Docker
Write-Host "[1] Docker" -ForegroundColor Yellow
try {
    $dockerVer = docker version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    [OK] Docker operativo" -ForegroundColor Green
    } else {
        Write-Host "    [X] Docker no responde. Reinicia Docker Desktop." -ForegroundColor Red
    }
} catch {
    Write-Host "    [X] Docker no disponible: $_" -ForegroundColor Red
}
Write-Host ""

# 2. Contenedores principales
Write-Host "[2] Contenedores principales" -ForegroundColor Yellow
$containers = @(
    @{Name="open-webui"; Desc="Interfaz Web"; Port=8082},
    @{Name="comfyui"; Desc="Generacion de imagenes"; Port=7860},
    @{Name="ollama-mistral"; Desc="LLM Mistral"; Port=11436},
    @{Name="ollama-qwen"; Desc="LLM Qwen"; Port=11437}
)
foreach ($c in $containers) {
    $r = docker ps --filter "name=$($c.Name)" --format "{{.Names}}" 2>$null
    if ($r -eq $c.Name) {
        $st = docker ps --filter "name=$($c.Name)" --format "{{.Status}}" 2>$null
        Write-Host "    [OK] $($c.Name) - $($c.Desc)" -ForegroundColor Green
        Write-Host "         Puerto $($c.Port) | $st" -ForegroundColor Gray
    } else {
        Write-Host "    [X] $($c.Name) - No esta corriendo" -ForegroundColor Red
    }
}
Write-Host ""

# 3. Open WebUI
Write-Host "[3] Open WebUI (http://localhost:8082)" -ForegroundColor Yellow
try {
    $r = Invoke-WebRequest -Uri "http://localhost:8082" -TimeoutSec 10 -UseBasicParsing
    Write-Host "    [OK] Open WebUI accesible (Status $($r.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "    [X] No accesible: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "        Levanta: docker compose -f docker-compose-unified.yml up -d open-webui" -ForegroundColor Gray
}
Write-Host ""

# 4. ComfyUI
Write-Host "[4] ComfyUI (http://localhost:7860)" -ForegroundColor Yellow
try {
    $r = Invoke-WebRequest -Uri "http://localhost:7860/object_info" -TimeoutSec 10 -UseBasicParsing
    Write-Host "    [OK] ComfyUI API accesible (Status $($r.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "    [X] No accesible: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "        Levanta: .\scripts\recrear-comfyui-robusto.ps1 -RTX50" -ForegroundColor Gray
}
Write-Host ""

# 5. Conectividad WebUI -> ComfyUI (misma red)
Write-Host "[5] Conectividad Open WebUI -> ComfyUI" -ForegroundColor Yellow
$webuiRunning = docker ps --filter "name=open-webui" --format "{{.Names}}" 2>$null
$comfyRunning = docker ps --filter "name=comfyui" --format "{{.Names}}" 2>$null
if ($webuiRunning -and $comfyRunning) {
    $curlOut = docker exec open-webui curl -s -o /dev/null -w "%{http_code}" http://comfyui:8188/object_info 2>$null
    if ($curlOut -eq "200") {
        Write-Host "    [OK] Open WebUI puede alcanzar ComfyUI en la red Docker" -ForegroundColor Green
    } else {
        Write-Host "    [!] Open WebUI no alcanza comfyui:8188 (codigo: $curlOut)" -ForegroundColor Yellow
        Write-Host "        Ambos deben estar en la misma red Docker" -ForegroundColor Gray
    }
} else {
    Write-Host "    [SKIP] Falta algun contenedor" -ForegroundColor Gray
}
Write-Host ""

# 6. Resumen y siguientes pasos
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Proximos pasos" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  1. Probar generacion: .\scripts\probar-comfyui-api.ps1" -ForegroundColor White
Write-Host "  2. Open WebUI: http://localhost:8082" -ForegroundColor White
Write-Host "  3. ComfyUI: http://localhost:7860" -ForegroundColor White
Write-Host "  4. Admin > Settings > Images: Engine=ComfyUI, URL=http://comfyui:8188" -ForegroundColor White
Write-Host ""
