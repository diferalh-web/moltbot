# Script para verificar modelos disponibles en Ollama Docker

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Verificar Modelos en Ollama Docker" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que Docker está corriendo
$dockerRunning = docker ps 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Docker no está corriendo" -ForegroundColor Red
    exit 1
}

# Verificar que el contenedor Ollama existe y está corriendo
$ollamaRunning = docker ps --filter "name=ollama" --format "{{.Names}}" 2>$null
if ($ollamaRunning -ne "ollama") {
    Write-Host "[X] Contenedor Ollama no está corriendo" -ForegroundColor Red
    Write-Host "    Ejecuta: docker start ollama" -ForegroundColor Yellow
    exit 1
}

Write-Host "Modelos disponibles en Ollama:" -ForegroundColor Yellow
Write-Host ""
docker exec ollama ollama list
Write-Host ""

# Verificar modelos específicos
Write-Host "Verificando modelos específicos..." -ForegroundColor Yellow
Write-Host ""

$mistralExists = docker exec ollama ollama list 2>$null | Select-String "mistral"
$qwenExists = docker exec ollama ollama list 2>$null | Select-String "qwen"
$llama2Exists = docker exec ollama ollama list 2>$null | Select-String "llama2"

if ($mistralExists) {
    Write-Host "[OK] Mistral está disponible" -ForegroundColor Green
} else {
    Write-Host "[!] Mistral NO está disponible" -ForegroundColor Yellow
}

if ($qwenExists) {
    Write-Host "[OK] Qwen está disponible" -ForegroundColor Green
} else {
    Write-Host "[!] Qwen NO está disponible" -ForegroundColor Yellow
}

if ($llama2Exists) {
    Write-Host "[OK] Llama2 está disponible" -ForegroundColor Green
} else {
    Write-Host "[!] Llama2 NO está disponible" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Para descargar modelos faltantes:" -ForegroundColor Cyan
Write-Host "  scripts\descargar-modelos-ollama.ps1" -ForegroundColor Gray
Write-Host ""












