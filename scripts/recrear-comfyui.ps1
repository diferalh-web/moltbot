# Script para recrear ComfyUI correctamente
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Recreando ComfyUI" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Detener y eliminar contenedor existente
Write-Host "[1/5] Deteniendo y eliminando contenedor existente..." -ForegroundColor Yellow
docker stop comfyui 2>$null | Out-Null
docker rm comfyui 2>$null | Out-Null
Write-Host "[OK] Contenedor eliminado" -ForegroundColor Green
Write-Host ""

# Crear directorios
Write-Host "[2/5] Creando directorios..." -ForegroundColor Yellow
$comfyuiModels = "${env:USERPROFILE}\comfyui-models"
$comfyuiOutput = "${env:USERPROFILE}\comfyui-output"
$comfyuiInput = "${env:USERPROFILE}\comfyui-input"
$comfyuiData = "${env:USERPROFILE}\comfyui-data"
New-Item -ItemType Directory -Force -Path $comfyuiModels | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiOutput | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiInput | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiData | Out-Null
Write-Host "[OK] Directorios creados" -ForegroundColor Green
Write-Host ""

# Crear contenedor ComfyUI
Write-Host "[3/5] Creando contenedor ComfyUI..." -ForegroundColor Yellow
Write-Host "      (Esto puede tardar varios minutos mientras instala dependencias)" -ForegroundColor Gray

docker run -d `
  --name comfyui `
  -p 7860:8188 `
  -v "${env:USERPROFILE}/comfyui-models:/root/.cache/huggingface" `
  -v "${env:USERPROFILE}/comfyui-output:/root/ComfyUI/output" `
  -v "${env:USERPROFILE}/comfyui-input:/root/ComfyUI/input" `
  -v "${env:USERPROFILE}/comfyui-data:/root/ComfyUI" `
  --restart unless-stopped `
  --gpus all `
  -e NVIDIA_VISIBLE_DEVICES=all `
  -w /root `
  python:3.11-slim `
  bash -c "apt-get update && apt-get install -y git curl build-essential && pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && cd /root && if [ ! -d ComfyUI ]; then git clone https://github.com/comfyanonymous/ComfyUI.git; fi && cd ComfyUI && pip install --no-cache-dir -r requirements.txt && python main.py --listen 0.0.0.0 --port 8188"

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Contenedor ComfyUI creado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "[4/5] Esperando a que ComfyUI inicie (90 segundos)..." -ForegroundColor Yellow
Write-Host "      (Instalando dependencias, esto puede tardar)" -ForegroundColor Gray
Start-Sleep -Seconds 90
Write-Host ""

# Verificar estado
Write-Host "[5/5] Verificando estado..." -ForegroundColor Yellow
$status = docker ps --filter "name=comfyui" --format "{{.Status}}" 2>$null
if ($status) {
    Write-Host "[OK] ComfyUI está corriendo: $status" -ForegroundColor Green
} else {
    Write-Host "[!] ComfyUI puede estar aún iniciando" -ForegroundColor Yellow
    Write-Host "    Verifica los logs con: docker logs comfyui" -ForegroundColor Gray
}
Write-Host ""

# Mostrar logs recientes
Write-Host "Ultimas lineas de logs:" -ForegroundColor Yellow
docker logs comfyui --tail 10 2>&1
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] ComfyUI recreado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Acceso:" -ForegroundColor Yellow
Write-Host "  http://localhost:7860" -ForegroundColor Cyan
Write-Host ""
Write-Host "Nota:" -ForegroundColor Yellow
Write-Host "  - Si aun no funciona, espera 2-3 minutos mas" -ForegroundColor White
Write-Host "  - Verifica los logs: docker logs comfyui" -ForegroundColor White
Write-Host "  - La primera vez puede tardar 5-10 minutos en instalar todo" -ForegroundColor White
Write-Host ""

