# Script para arreglar ComfyUI
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Arreglando ComfyUI" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Detener y eliminar contenedor actual
Write-Host "[1/4] Deteniendo y eliminando contenedor actual..." -ForegroundColor Yellow
docker stop comfyui 2>$null | Out-Null
docker rm comfyui 2>$null | Out-Null
Write-Host "[OK] Contenedor eliminado" -ForegroundColor Green
Write-Host ""

# Crear directorios necesarios
Write-Host "[2/4] Creando directorios..." -ForegroundColor Yellow
$comfyuiData = "${env:USERPROFILE}\comfyui-data"
$comfyuiModels = "${env:USERPROFILE}\comfyui-models"
$comfyuiOutput = "${env:USERPROFILE}\comfyui-output"
$comfyuiInput = "${env:USERPROFILE}\comfyui-input"

New-Item -ItemType Directory -Force -Path $comfyuiData | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiModels | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiOutput | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiInput | Out-Null
Write-Host "[OK] Directorios creados" -ForegroundColor Green
Write-Host ""

# Crear nuevo contenedor con configuración mejorada
Write-Host "[3/4] Creando nuevo contenedor ComfyUI..." -ForegroundColor Yellow

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
  bash -c "apt-get update && apt-get install -y git curl && pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && cd /root && if [ ! -d ComfyUI ]; then git clone https://github.com/comfyanonymous/ComfyUI.git; fi && cd ComfyUI && pip install -r requirements.txt && python main.py --listen 0.0.0.0 --port 8188"

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Contenedor ComfyUI creado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "[4/4] Esperando a que ComfyUI inicie (60 segundos)..." -ForegroundColor Yellow
Write-Host "      (Esto puede tardar mientras instala dependencias)" -ForegroundColor Gray
Start-Sleep -Seconds 60

# Verificar estado
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] ComfyUI arreglado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Estado del contenedor:" -ForegroundColor Yellow
docker ps --filter "name=comfyui" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""
Write-Host "Logs (ultimas 20 lineas):" -ForegroundColor Yellow
docker logs comfyui --tail 20
Write-Host ""
Write-Host "Acceso:" -ForegroundColor Yellow
Write-Host "  http://localhost:7860" -ForegroundColor Cyan
Write-Host ""
Write-Host "Nota: Si aun no funciona, espera 2-3 minutos mas" -ForegroundColor Yellow
Write-Host "      y verifica los logs con: docker logs comfyui" -ForegroundColor Gray
Write-Host ""

