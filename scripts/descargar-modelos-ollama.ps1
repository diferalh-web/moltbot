# Script para descargar modelos Mistral y Qwen en Ollama Docker
# Ejecutar en PowerShell como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Descargar Modelos en Ollama Docker" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que Docker está corriendo
Write-Host "[1/5] Verificando Docker..." -ForegroundColor Yellow
$dockerRunning = docker ps 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Docker no está corriendo o no está instalado" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Docker está corriendo" -ForegroundColor Green
Write-Host ""

# Verificar que el contenedor Ollama existe
Write-Host "[2/5] Verificando contenedor Ollama..." -ForegroundColor Yellow
$ollamaExists = docker ps -a --filter "name=ollama" --format "{{.Names}}" 2>$null
if ($ollamaExists -ne "ollama") {
    Write-Host "[X] Contenedor 'ollama' no existe" -ForegroundColor Red
    Write-Host "    Ejecuta primero: scripts\setup-ollama-host.ps1" -ForegroundColor Yellow
    exit 1
}

# Verificar que está corriendo
$ollamaRunning = docker ps --filter "name=ollama" --format "{{.Names}}" 2>$null
if ($ollamaRunning -ne "ollama") {
    Write-Host "[!] Contenedor Ollama no está corriendo. Iniciando..." -ForegroundColor Yellow
    docker start ollama
    Start-Sleep -Seconds 3
}
Write-Host "[OK] Contenedor Ollama está corriendo" -ForegroundColor Green
Write-Host ""

# Ver modelos actuales
Write-Host "[3/5] Modelos actuales en Ollama:" -ForegroundColor Yellow
docker exec ollama ollama list
Write-Host ""

# Descargar Mistral
Write-Host "[4/5] Descargando Mistral (esto puede tardar varios minutos)..." -ForegroundColor Yellow
Write-Host "      Tamaño aproximado: ~4GB" -ForegroundColor Gray
docker exec ollama ollama pull mistral

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Mistral descargado correctamente" -ForegroundColor Green
} else {
    Write-Host "[X] Error al descargar Mistral" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Descargar Qwen
Write-Host "[5/5] Descargando Qwen2.5:7b (esto puede tardar varios minutos)..." -ForegroundColor Yellow
Write-Host "      Tamaño aproximado: ~4.5GB" -ForegroundColor Gray
docker exec ollama ollama pull qwen2.5:7b

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Qwen2.5:7b descargado correctamente" -ForegroundColor Green
} else {
    Write-Host "[X] Error al descargar Qwen2.5:7b" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Verificar modelos descargados
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Descarga completada!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Modelos disponibles en Ollama:" -ForegroundColor Yellow
docker exec ollama ollama list
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Configurar Moltbot para usar Mistral o Qwen" -ForegroundColor Gray
Write-Host "  2. Ver guía: CONFIGURAR_MISTRAL_O_QWEN.md" -ForegroundColor Gray
Write-Host ""












