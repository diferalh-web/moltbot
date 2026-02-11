# Script para configurar el proxy Ollama que agrega todos los modelos

Write-Host "`n=== Configurando Proxy Ollama para Agregar Todos los Modelos ===" -ForegroundColor Cyan

# Verificar que los contenedores Ollama esten corriendo
Write-Host "`n1. Verificando contenedores Ollama..." -ForegroundColor Yellow
$containers = @("ollama-mistral", "ollama-qwen", "ollama-code", "ollama-flux")
foreach ($container in $containers) {
    $status = docker ps --filter "name=$container" --format "{{.Status}}"
    if ($status) {
        Write-Host "  OK $container esta corriendo" -ForegroundColor Green
    } else {
        Write-Host "  X $container NO esta corriendo" -ForegroundColor Red
    }
}

# Detener y eliminar el proxy si existe
Write-Host "`n2. Configurando contenedor proxy..." -ForegroundColor Yellow
docker stop ollama-proxy 2>&1 | Out-Null
docker rm ollama-proxy 2>&1 | Out-Null

# Copiar script del proxy al contenedor temporal
$proxyScript = Join-Path $PSScriptRoot "crear-proxy-ollama.py"

# Crear contenedor con el proxy
Write-Host "`n3. Creando contenedor proxy Ollama..." -ForegroundColor Yellow
docker run -d `
  --name ollama-proxy `
  --network ai-network `
  -p 11440:11440 `
  -v "${proxyScript}:/app/proxy.py:ro" `
  --restart unless-stopped `
  python:3.11-slim `
  bash -c "pip install --no-cache-dir flask requests; python /app/proxy.py"

if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK Proxy Ollama creado" -ForegroundColor Green
    
    Write-Host "`n4. Esperando a que el proxy inicie..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    # Verificar que el proxy funcione
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:11440/api/tags" -Method GET -TimeoutSec 5
        $models = ($response.Content | ConvertFrom-Json).models
        Write-Host "  OK Proxy funcionando - Encontrados $($models.Count) modelos" -ForegroundColor Green
        foreach ($model in $models) {
            Write-Host "    - $($model.name)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Advertencia: El proxy puede tardar mas en iniciar" -ForegroundColor Yellow
    }
    
    # Actualizar Open WebUI para usar el proxy
    Write-Host "`n5. Actualizando Open WebUI para usar el proxy..." -ForegroundColor Yellow
    docker stop open-webui 2>&1 | Out-Null
    docker rm open-webui 2>&1 | Out-Null
    
    docker run -d `
      --name open-webui `
      --network ai-network `
      -p 8082:8080 `
      -v "${env:USERPROFILE}/open-webui-data:/app/backend/data" `
      -v "${PWD}/extensions/open-webui-multimedia:/app/extensions/multimedia:ro" `
      -e OLLAMA_BASE_URL=http://ollama-proxy:11440 `
      -e ENABLE_IMAGE_GENERATION=true `
      -e IMAGE_GENERATION_API_URL=http://comfyui:8188 `
      -e VIDEO_GENERATION_API_URL=http://stable-video:8000 `
      -e TTS_API_URL=http://coqui-tts:5002 `
      -e FLUX_API_URL=http://ollama-flux:11434 `
      --restart unless-stopped `
      --gpus all `
      ghcr.io/open-webui/open-webui:main
    
    Write-Host "  OK Open WebUI actualizado para usar el proxy" -ForegroundColor Green
    
    Write-Host "`n6. Esperando a que Open WebUI inicie..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
    
    Write-Host "`n=== CONFIGURACION COMPLETADA ===" -ForegroundColor Cyan
    Write-Host "`nOK Proxy Ollama configurado en puerto 11440" -ForegroundColor Green
    Write-Host "OK Open WebUI configurado para usar el proxy" -ForegroundColor Green
    Write-Host "`nAhora accede a: http://localhost:8082" -ForegroundColor White
    Write-Host "Recarga la pagina (F5) y deberias ver TODOS los modelos:" -ForegroundColor White
    Write-Host "  - mistral:latest" -ForegroundColor Gray
    Write-Host "  - qwen2.5:7b" -ForegroundColor Gray
    Write-Host "  - codellama:34b" -ForegroundColor Gray
    Write-Host "  - deepseek-coder:33b" -ForegroundColor Gray
} else {
    Write-Host "  X Error al crear el proxy" -ForegroundColor Red
    exit 1
}
