# Script para descargar todos los modelos necesarios
# Ejecutar en PowerShell de Windows

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Descargar Modelos de IA" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que los contenedores están corriendo
Write-Host "[1/5] Verificando contenedores..." -ForegroundColor Yellow
$containers = @("ollama-code", "ollama-flux")
$allRunning = $true

foreach ($container in $containers) {
    $status = docker ps --filter "name=$container" --format "{{.Names}}" 2>$null
    if ($status -ne $container) {
        Write-Host "[X] Contenedor $container no está corriendo" -ForegroundColor Red
        $allRunning = $false
    } else {
        Write-Host "[OK] $container está corriendo" -ForegroundColor Green
    }
}

if (-not $allRunning) {
    Write-Host ""
    Write-Host "[!] Algunos contenedores no están corriendo." -ForegroundColor Yellow
    Write-Host "    Ejecuta primero los scripts de setup correspondientes." -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Descargar modelos de programación
Write-Host "[2/5] Descargando modelos de programación en ollama-code..." -ForegroundColor Yellow
Write-Host "      Esto puede tardar 30-60 minutos por modelo..." -ForegroundColor Yellow
Write-Host ""

$codeModels = @("deepseek-coder:33b", "wizardcoder:34b", "codellama:34b")

foreach ($model in $codeModels) {
    Write-Host "  Descargando $model..." -ForegroundColor Cyan
    docker exec ollama-code ollama pull $model
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] $model descargado" -ForegroundColor Green
    } else {
        Write-Host "  [X] Error al descargar $model" -ForegroundColor Red
    }
    Write-Host ""
}
Write-Host ""

# Descargar Flux
Write-Host "[3/5] Descargando Flux en ollama-flux..." -ForegroundColor Yellow
Write-Host "      Esto puede tardar 30-60 minutos..." -ForegroundColor Yellow
Write-Host ""
docker exec ollama-flux ollama pull flux
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Flux descargado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al descargar Flux" -ForegroundColor Red
}
Write-Host ""

# Verificar modelos descargados
Write-Host "[4/5] Verificando modelos descargados..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Modelos en ollama-code:" -ForegroundColor Cyan
docker exec ollama-code ollama list
Write-Host ""
Write-Host "Modelos en ollama-flux:" -ForegroundColor Cyan
docker exec ollama-flux ollama list
Write-Host ""

# Resumen
Write-Host "[5/5] Resumen:" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Descarga de modelos completada!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Modelos disponibles:" -ForegroundColor Yellow
Write-Host "  - ollama-code (puerto 11438):" -ForegroundColor White
Write-Host "    * deepseek-coder:33b" -ForegroundColor Gray
Write-Host "    * wizardcoder:34b" -ForegroundColor Gray
Write-Host "    * codellama:34b" -ForegroundColor Gray
Write-Host ""
Write-Host "  - ollama-flux (puerto 11439):" -ForegroundColor White
Write-Host "    * flux" -ForegroundColor Gray
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Configurar Open WebUI extendido:" -ForegroundColor White
Write-Host "     .\scripts\configure-open-webui-extended.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Probar modelos individualmente:" -ForegroundColor White
Write-Host "     curl http://localhost:11438/api/tags" -ForegroundColor Gray
Write-Host "     curl http://localhost:11439/api/tags" -ForegroundColor Gray
Write-Host ""












