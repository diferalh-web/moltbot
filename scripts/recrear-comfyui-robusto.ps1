# Script para recrear ComfyUI de forma robusta
# -UseCPU: usar CPU (lento, para GPUs incompatibles)
# -RTX50: PyTorch CUDA 12.8 para RTX 5070/50 series (Blackwell/sm_120)
param([switch]$UseCPU, [switch]$RTX50)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Recreando ComfyUI (Version Robusta)" -ForegroundColor Cyan
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

# Crear contenedor ComfyUI (comando inline para evitar problemas de codificacion en Windows)
Write-Host "[3/5] Creando contenedor ComfyUI..." -ForegroundColor Yellow
Write-Host "      (Esto puede tardar 5-10 minutos)" -ForegroundColor Gray

$cudaIndex = if ($RTX50) { "cu128" } else { "cu121" }
if ($RTX50) { Write-Host "      Usando PyTorch CUDA 12.8 para RTX 50 series" -ForegroundColor Cyan }
$bashCmd = "apt-get update -qq && apt-get install -y -qq git curl build-essential && pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/$cudaIndex && (mkdir -p /root/ComfyUI && cd /root && if [ -d ComfyUI/.git ]; then cd ComfyUI && git pull || true; else rm -rf ComfyUI_clone && git clone https://github.com/comfyanonymous/ComfyUI.git ComfyUI_clone && (cd ComfyUI && shopt -s dotglob && rm -rf * 2>/dev/null; true) && cp -r ComfyUI_clone/. ComfyUI/ && rm -rf ComfyUI_clone; fi && cd /root/ComfyUI) && cd /root/ComfyUI && pip install --no-cache-dir -r requirements.txt && python main.py --listen 0.0.0.0 --port 8188 " + '${COMFYUI_CPU:+--cpu}'

# Crear subdirs de modelos si no existen (incluye loras y latent_upscale_models para LTX-2)
$modelDirs = "checkpoints", "vae", "diffusion_models", "text_encoders", "loras", "latent_upscale_models"
foreach ($d in $modelDirs) {
    New-Item -ItemType Directory -Force -Path "${env:USERPROFILE}/comfyui-models/$d" | Out-Null
}

docker run -d `
  --name comfyui `
  -p 7860:8188 `
  -v "${env:USERPROFILE}/comfyui-models:/root/.cache/huggingface" `
  -v "${env:USERPROFILE}/comfyui-models/checkpoints:/root/ComfyUI/models/checkpoints" `
  -v "${env:USERPROFILE}/comfyui-models/vae:/root/ComfyUI/models/vae" `
  -v "${env:USERPROFILE}/comfyui-models/diffusion_models:/root/ComfyUI/models/diffusion_models" `
  -v "${env:USERPROFILE}/comfyui-models/text_encoders:/root/ComfyUI/models/text_encoders" `
  -v "${env:USERPROFILE}/comfyui-models/loras:/root/ComfyUI/models/loras" `
  -v "${env:USERPROFILE}/comfyui-models/latent_upscale_models:/root/ComfyUI/models/latent_upscale_models" `
  -v "${env:USERPROFILE}/comfyui-output:/root/ComfyUI/output" `
  -v "${env:USERPROFILE}/comfyui-input:/root/ComfyUI/input" `
  -v "${env:USERPROFILE}/comfyui-data:/root/ComfyUI" `
  --restart unless-stopped `
  --gpus all `
  -e NVIDIA_VISIBLE_DEVICES=all `
  @(if ($UseCPU) { '-e', 'COMFYUI_CPU=1' }) `
  -w /root `
  python:3.11-slim `
  bash -c $bashCmd

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Contenedor ComfyUI creado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "[4/5] Esperando a que ComfyUI inicie (120 segundos)..." -ForegroundColor Yellow
Write-Host "      (Instalando dependencias, esto puede tardar)" -ForegroundColor Gray
Start-Sleep -Seconds 120
Write-Host ""

# Verificar estado
Write-Host "[5/5] Verificando estado..." -ForegroundColor Yellow
$status = docker ps --filter "name=comfyui" --format "{{.Status}}" 2>$null
if ($status -and $status -notlike "*Restarting*") {
    Write-Host "[OK] ComfyUI esta corriendo: $status" -ForegroundColor Green
} else {
    Write-Host "[!] ComfyUI puede estar aun iniciando o tiene problemas" -ForegroundColor Yellow
    Write-Host "    Verifica los logs con: docker logs comfyui" -ForegroundColor Gray
}
Write-Host ""

# Mostrar logs recientes
Write-Host "Ultimas lineas de logs:" -ForegroundColor Yellow
docker logs comfyui --tail 15 2>&1
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] ComfyUI recreado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Acceso:" -ForegroundColor Yellow
Write-Host "  http://localhost:7860" -ForegroundColor Cyan
Write-Host ""
Write-Host "Nota:" -ForegroundColor Yellow
Write-Host "  - Si aun no funciona, espera 3-5 minutos mas" -ForegroundColor White
Write-Host "  - Verifica los logs: docker logs comfyui -f" -ForegroundColor White
Write-Host "  - La primera vez puede tardar 10-15 minutos en instalar todo" -ForegroundColor White
Write-Host ""









