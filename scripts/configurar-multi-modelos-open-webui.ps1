# Script para configurar Open WebUI con múltiples modelos Ollama
# Este script reinicia Open WebUI con la configuración correcta para detectar todos los modelos

Write-Host "`n=== Configurando Open WebUI para múltiples modelos Ollama ===" -ForegroundColor Cyan

# Verificar que los contenedores estén corriendo
Write-Host "`n1. Verificando contenedores Ollama..." -ForegroundColor Yellow
$containers = @("ollama-mistral", "ollama-qwen", "ollama-code", "ollama-flux")
foreach ($container in $containers) {
    $status = docker ps --filter "name=$container" --format "{{.Status}}"
    if ($status) {
        Write-Host "  ✓ $container está corriendo" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $container NO está corriendo" -ForegroundColor Red
        Write-Host "    Ejecuta: docker-compose -f docker-compose-extended.yml up -d $container" -ForegroundColor Yellow
    }
}

# Detener Open WebUI
Write-Host "`n2. Deteniendo Open WebUI..." -ForegroundColor Yellow
docker stop open-webui 2>&1 | Out-Null
docker rm open-webui 2>&1 | Out-Null

# Configurar URLs de Ollama (usando nombres de contenedor para comunicación interna)
# Open WebUI soporta múltiples backends usando OLLAMA_BASE_URLS con formato: url1|url2|url3
$ollamaUrls = "http://ollama-mistral:11434|http://ollama-qwen:11434|http://ollama-code:11434|http://ollama-flux:11434"

Write-Host "`n3. Reiniciando Open WebUI con configuración de múltiples modelos..." -ForegroundColor Yellow
Write-Host "   URLs configuradas: $ollamaUrls" -ForegroundColor Gray

# Reiniciar Open WebUI con la nueva configuración
docker run -d `
  --name open-webui `
  --network ai-network `
  -p 8082:8080 `
  -v "${env:USERPROFILE}/open-webui-data:/app/backend/data" `
  -v "${PWD}/extensions/open-webui-multimedia:/app/extensions/multimedia:ro" `
  -e OLLAMA_BASE_URL=http://ollama-mistral:11434 `
  -e OLLAMA_BASE_URLS=$ollamaUrls `
  -e ENABLE_IMAGE_GENERATION=true `
  -e IMAGE_GENERATION_API_URL=http://comfyui:8188 `
  -e VIDEO_GENERATION_API_URL=http://stable-video:8000 `
  -e TTS_API_URL=http://coqui-tts:5002 `
  -e FLUX_API_URL=http://ollama-flux:11434 `
  --restart unless-stopped `
  --gpus all `
  ghcr.io/open-webui/open-webui:main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ Open WebUI reiniciado correctamente" -ForegroundColor Green
    
    Write-Host "`n4. Esperando a que Open WebUI inicie..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    Write-Host "`n=== Configuración Completada ===" -ForegroundColor Cyan
    Write-Host "`nOpen WebUI está configurado para detectar modelos de:" -ForegroundColor Green
    Write-Host "  • Ollama Mistral (puerto 11436): mistral:latest" -ForegroundColor White
    Write-Host "  • Ollama Qwen (puerto 11437): qwen2.5:7b" -ForegroundColor White
    Write-Host "  • Ollama Code (puerto 11438): codellama:34b, deepseek-coder:33b" -ForegroundColor White
    Write-Host "  • Ollama Flux (puerto 11439): (sin modelos aún)" -ForegroundColor White
    
    Write-Host "`nAccede a: http://localhost:8082" -ForegroundColor Cyan
    Write-Host "`nNOTA: Si los modelos no aparecen inmediatamente:" -ForegroundColor Yellow
    Write-Host "  1. Espera 30-60 segundos para que Open WebUI detecte los modelos" -ForegroundColor Gray
    Write-Host "  2. Refresca la página (F5)" -ForegroundColor Gray
    Write-Host "  3. Ve a Settings > General y verifica 'Ollama Base URL'" -ForegroundColor Gray
    Write-Host "  4. Si aún no aparecen, ve a Settings > Connections y agrega manualmente:" -ForegroundColor Gray
    Write-Host "     - Name: Qwen, URL: http://localhost:11437" -ForegroundColor Gray
    Write-Host "     - Name: Code, URL: http://localhost:11438" -ForegroundColor Gray
    Write-Host "     - Name: Flux, URL: http://localhost:11439" -ForegroundColor Gray
} else {
    Write-Host "`n✗ Error al reiniciar Open WebUI" -ForegroundColor Red
    Write-Host "Verifica los logs: docker logs open-webui" -ForegroundColor Yellow
}











