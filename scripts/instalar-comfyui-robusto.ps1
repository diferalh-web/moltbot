# Script robusto para instalar ComfyUI
# Espera a que el clonado termine antes de continuar

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Instalar ComfyUI (Método Robusto)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Detener contenedor anterior
docker stop comfyui 2>$null | Out-Null
docker rm comfyui 2>$null | Out-Null

# Crear directorios
$comfyuiModels = "${env:USERPROFILE}\comfyui-models"
$comfyuiOutput = "${env:USERPROFILE}\comfyui-output"
$comfyuiInput = "${env:USERPROFILE}\comfyui-input"

New-Item -ItemType Directory -Force -Path $comfyuiModels | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiOutput | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiInput | Out-Null

Write-Host "Creando contenedor..." -ForegroundColor Yellow

# Script que espera a que el clonado termine (sin heredoc para evitar problemas de finales de línea)
$installScript = "apt-get update -qq && apt-get install -y -qq git curl >/dev/null 2>&1 && pip install -q torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && cd /root && (test -d ComfyUI && (cd ComfyUI && git pull origin main || true) || git clone https://github.com/comfyanonymous/ComfyUI.git) && sleep 5 && cd /root/ComfyUI && test -f main.py && (test -f requirements.txt && pip install -q -r requirements.txt || echo 'requirements.txt no encontrado, continuando...') && python main.py --listen 0.0.0.0 --port 8188"

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
  bash -c $installScript

Write-Host "[OK] Contenedor creado" -ForegroundColor Green
Write-Host ""
Write-Host "Monitorear progreso:" -ForegroundColor Yellow
Write-Host "  docker logs -f comfyui" -ForegroundColor Cyan
Write-Host ""
Write-Host "Tiempo estimado: 10-30 minutos" -ForegroundColor Gray
Write-Host ""

