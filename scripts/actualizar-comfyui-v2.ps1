# Script mejorado para actualizar ComfyUI
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Actualizar ComfyUI a la Última Versión" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Docker
Write-Host "[1/6] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    Write-Host "[OK] Docker instalado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker no está instalado" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Detener y eliminar contenedor actual
Write-Host "[2/6] Deteniendo ComfyUI actual..." -ForegroundColor Yellow
docker stop comfyui 2>$null | Out-Null
docker rm comfyui 2>$null | Out-Null
Write-Host "[OK] ComfyUI detenido" -ForegroundColor Green
Write-Host ""

# Crear directorios
Write-Host "[3/6] Verificando directorios..." -ForegroundColor Yellow
$comfyuiModels = "${env:USERPROFILE}\comfyui-models"
$comfyuiOutput = "${env:USERPROFILE}\comfyui-output"
$comfyuiInput = "${env:USERPROFILE}\comfyui-input"

New-Item -ItemType Directory -Force -Path $comfyuiModels | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiOutput | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiInput | Out-Null
Write-Host "[OK] Directorios listos" -ForegroundColor Green
Write-Host ""

# Crear script de instalación dentro del contenedor
Write-Host "[4/6] Creando ComfyUI con la última versión..." -ForegroundColor Yellow
Write-Host "      Esto puede tardar 10-30 minutos..." -ForegroundColor Gray

$installScript = @"
#!/bin/bash
set -e
apt-get update
apt-get install -y git curl
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
cd /root
rm -rf ComfyUI ComfyUI-new ComfyUI-tmp 2>/dev/null || true
git clone https://github.com/comfyanonymous/ComfyUI.git
cd /root/ComfyUI
pip install -r requirements.txt
python main.py --listen 0.0.0.0 --port 8188
"@

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

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] ComfyUI creado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar inicial
Write-Host "[5/6] Esperando inicio inicial (30 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Verificar estado
Write-Host "[6/6] Verificando estado..." -ForegroundColor Yellow
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
Write-Host "Ver progreso en tiempo real:" -ForegroundColor Yellow
Write-Host "  docker logs -f comfyui" -ForegroundColor Gray
Write-Host ""
Write-Host "NOTA IMPORTANTE:" -ForegroundColor Yellow
Write-Host "  ComfyUI puede tardar 10-30 minutos en iniciar completamente" -ForegroundColor Gray
Write-Host "  mientras descarga e instala todas las dependencias." -ForegroundColor Gray
Write-Host "  Verifica los logs para ver el progreso." -ForegroundColor Gray
Write-Host ""









