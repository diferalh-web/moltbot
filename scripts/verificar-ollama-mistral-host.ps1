# Script para verificar estado de Ollama-Mistral en el host
# Ejecutar en PowerShell de Windows

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Verificar Estado de Ollama-Mistral" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/4] Verificando contenedor..." -ForegroundColor Yellow
$container = docker ps -a --filter "name=ollama-mistral" --format "{{.Names}} {{.Status}}"
if ($container) {
    Write-Host "[OK] Contenedor encontrado:" -ForegroundColor Green
    Write-Host "  $container" -ForegroundColor Gray
} else {
    Write-Host "[X] Contenedor no encontrado" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "[2/4] Verificando logs recientes..." -ForegroundColor Yellow
Write-Host "Últimas 30 líneas:" -ForegroundColor Gray
docker logs ollama-mistral --tail 30
Write-Host ""

Write-Host "[3/4] Verificando modelos disponibles..." -ForegroundColor Yellow
docker exec ollama-mistral ollama list 2>&1
Write-Host ""

Write-Host "[4/4] Verificando uso de recursos..." -ForegroundColor Yellow
docker stats ollama-mistral --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Diagnóstico" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "El error 'signal: killed' generalmente significa:" -ForegroundColor Yellow
Write-Host "  1. Falta de memoria RAM" -ForegroundColor Gray
Write-Host "  2. El modelo es muy grande para la RAM disponible" -ForegroundColor Gray
Write-Host "  3. El contenedor necesita más recursos" -ForegroundColor Gray
Write-Host ""

Write-Host "Soluciones posibles:" -ForegroundColor Cyan
Write-Host "  1. Aumentar memoria del contenedor" -ForegroundColor Gray
Write-Host "  2. Usar un modelo más pequeño (mistral:7b-instruct-q4_0)" -ForegroundColor Gray
Write-Host "  3. Liberar memoria en el sistema" -ForegroundColor Gray
Write-Host "  4. Reiniciar el contenedor" -ForegroundColor Gray
Write-Host ""

Write-Host "Para reiniciar el contenedor:" -ForegroundColor Yellow
Write-Host "  docker restart ollama-mistral" -ForegroundColor White
Write-Host ""












