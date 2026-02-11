# Script para actualizar ComfyUI a la última versión
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Actualizar ComfyUI a la Última Versión" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Docker
Write-Host "[1/5] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    Write-Host "[OK] Docker instalado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker no está instalado" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Detener y eliminar contenedor actual si existe
Write-Host "[2/5] Deteniendo ComfyUI actual..." -ForegroundColor Yellow
docker stop comfyui 2>$null | Out-Null
docker rm comfyui 2>$null | Out-Null
Write-Host "[OK] ComfyUI detenido" -ForegroundColor Green
Write-Host ""

# Crear directorios necesarios
Write-Host "[3/5] Verificando directorios..." -ForegroundColor Yellow
$comfyuiModels = "${env:USERPROFILE}\comfyui-models"
$comfyuiOutput = "${env:USERPROFILE}\comfyui-output"
$comfyuiInput = "${env:USERPROFILE}\comfyui-input"

New-Item -ItemType Directory -Force -Path $comfyuiModels | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiOutput | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiInput | Out-Null
Write-Host "[OK] Directorios listos" -ForegroundColor Green
Write-Host ""

# Crear nuevo contenedor con la última versión de ComfyUI
Write-Host "[4/5] Creando ComfyUI con la última versión..." -ForegroundColor Yellow
Write-Host "      Esto puede tardar varios minutos (descarga e instalación)..." -ForegroundColor Gray

docker run -d `
  --name comfyui `
  -p 7860:8188 `
  -v "${comfyuiModels}:/root/.cache/huggingface" `
  -v "${comfyuiOutput}:/root/ComfyUI/output" `
  -v "${comfyuiInput}:/root/ComfyUI/input" `
  --restart unless-stopped `
  --gpus all `
  -e NVIDIA_VISIBLE_DEVICES=all `
  python:3.11-slim `
  bash -c "apt-get update && apt-get install -y git curl && pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && cd /root && if [ -d ComfyUI ]; then rm -rf ComfyUI/.git ComfyUI/*.py ComfyUI/*.md ComfyUI/*.txt ComfyUI/*.json 2>/dev/null || true; fi && git clone https://github.com/comfyanonymous/ComfyUI.git ComfyUI-new && if [ -d ComfyUI-new ]; then if [ -d ComfyUI ]; then rm -rf ComfyUI; fi && mv ComfyUI-new ComfyUI; fi && cd /root/ComfyUI && pip install -r requirements.txt && python main.py --listen 0.0.0.0 --port 8188"

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] ComfyUI creado y actualizando..." -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "[5/5] Esperando a que ComfyUI inicie (esto puede tardar 2-5 minutos)..." -ForegroundColor Yellow
Write-Host "      ComfyUI está descargando e instalando dependencias..." -ForegroundColor Gray
Write-Host "      Puedes ver el progreso con: docker logs -f comfyui" -ForegroundColor Gray
Start-Sleep -Seconds 30

# Verificar estado
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] ComfyUI Actualizado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Estado del contenedor:" -ForegroundColor Yellow
docker ps --filter "name=comfyui" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""
Write-Host "Acceso a ComfyUI:" -ForegroundColor Yellow
Write-Host "  http://localhost:7860" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ver logs en tiempo real:" -ForegroundColor Yellow
Write-Host "  docker logs -f comfyui" -ForegroundColor Gray
Write-Host ""
Write-Host "Nota: ComfyUI puede tardar varios minutos en iniciar completamente" -ForegroundColor Yellow
Write-Host "      mientras descarga e instala todas las dependencias." -ForegroundColor Yellow
Write-Host ""

