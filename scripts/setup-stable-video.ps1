# Script para configurar Stable Video Diffusion
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar Stable Video Diffusion" -ForegroundColor Cyan
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

# Verificar GPU NVIDIA
Write-Host "[2/6] Verificando GPU NVIDIA..." -ForegroundColor Yellow
try {
    $nvidiaSmi = nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>$null
    if ($nvidiaSmi) {
        Write-Host "[OK] GPU detectada: $nvidiaSmi" -ForegroundColor Green
    } else {
        Write-Host "[!] GPU NVIDIA no detectada" -ForegroundColor Yellow
        Write-Host "[!] Stable Video requiere GPU con al menos 8GB VRAM" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[!] nvidia-smi no disponible" -ForegroundColor Yellow
    Write-Host "[!] Stable Video requiere GPU con al menos 8GB VRAM" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Obtener IP local
Write-Host "[3/6] Obteniendo IP local..." -ForegroundColor Yellow
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -notlike "192.168.56.*" -and $_.IPAddress -notlike "172.20.*"} | Select-Object -First 1).IPAddress
if (-not $ipAddress) {
    $ipAddress = "192.168.100.42"
}
Write-Host "[OK] IP: $ipAddress" -ForegroundColor Green
Write-Host ""

# Crear directorios
Write-Host "[4/6] Creando directorios..." -ForegroundColor Yellow
$stableVideoData = "${env:USERPROFILE}\stable-video-data"
$stableVideoModels = "${env:USERPROFILE}\stable-video-models"
$stableVideoOutput = "${env:USERPROFILE}\stable-video-output"
New-Item -ItemType Directory -Force -Path $stableVideoData | Out-Null
New-Item -ItemType Directory -Force -Path $stableVideoModels | Out-Null
New-Item -ItemType Directory -Force -Path $stableVideoOutput | Out-Null

# Crear API simple para Stable Video
$apiContent = @'
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import FileResponse
import uvicorn
import os
import subprocess
import tempfile

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok", "service": "stable-video-diffusion"}

@app.post("/api/generate")
async def generate_video(file: UploadFile = File(...), duration: int = 5):
    try:
        # Guardar imagen temporal
        with tempfile.NamedTemporaryFile(delete=False, suffix=".png") as tmp_img:
            content = await file.read()
            tmp_img.write(content)
            tmp_img_path = tmp_img.name
        
        # Aquí iría la lógica de Stable Video Diffusion
        # Por ahora retornamos un placeholder
        return {
            "status": "processing",
            "message": "Stable Video Diffusion API endpoint. Implementation pending.",
            "input_image": tmp_img_path,
            "duration": duration
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
'@

$apiFile = Join-Path $stableVideoData "stable_video_api.py"
Set-Content -Path $apiFile -Value $apiContent -Encoding UTF8
Write-Host "[OK] Directorios y API creados" -ForegroundColor Green
Write-Host ""

# Crear contenedor stable-video
Write-Host "[5/6] Creando contenedor stable-video..." -ForegroundColor Yellow

# Detener y eliminar si existe
docker stop stable-video 2>$null | Out-Null
docker rm stable-video 2>$null | Out-Null

# Crear nuevo contenedor
docker run -d `
  --name stable-video `
  -p 8000:8000 `
  -v "${env:USERPROFILE}/stable-video-data:/app" `
  -v "${env:USERPROFILE}/stable-video-models:/app/models" `
  -v "${env:USERPROFILE}/stable-video-output:/app/output" `
  --restart unless-stopped `
  --gpus all `
  -w /app `
  python:3.11-slim `
  bash -c "apt-get update && apt-get install -y git curl python3-pip && pip install --upgrade pip setuptools wheel && pip install --no-cache-dir fastapi uvicorn python-multipart && pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && pip install --no-cache-dir diffusers transformers accelerate && python /app/stable_video_api.py"

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Contenedor stable-video creado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "[6/6] Esperando a que Stable Video inicie (30 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Configurar firewall
Write-Host "Configurando firewall para puerto 8000..." -ForegroundColor Yellow
try {
    $existingRule = Get-NetFirewallRule -DisplayName "Stable-Video" -ErrorAction SilentlyContinue
    if ($existingRule) {
        Write-Host "[OK] Regla de firewall ya existe" -ForegroundColor Green
    } else {
        New-NetFirewallRule -DisplayName "Stable-Video" -Direction Inbound -Protocol TCP -LocalPort 8000 -Action Allow -ErrorAction SilentlyContinue | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Regla de firewall creada" -ForegroundColor Green
        } else {
            Write-Host "[!] No se pudo crear regla de firewall automáticamente" -ForegroundColor Yellow
            Write-Host "    Ejecuta manualmente como Administrador:" -ForegroundColor Yellow
            Write-Host "    netsh advfirewall firewall add rule name=`"Stable-Video`" dir=in action=allow protocol=TCP localport=8000" -ForegroundColor White
        }
    }
} catch {
    Write-Host "[!] Error al configurar firewall: $_" -ForegroundColor Yellow
    Write-Host "    Ejecuta manualmente como Administrador:" -ForegroundColor Yellow
    Write-Host "    netsh advfirewall firewall add rule name=`"Stable-Video`" dir=in action=allow protocol=TCP localport=8000" -ForegroundColor White
}
Write-Host ""

# Verificar estado
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Stable Video Diffusion configurado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Estado del contenedor:" -ForegroundColor Yellow
docker ps --filter "name=stable-video" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Verificar que el servicio está funcionando:" -ForegroundColor White
Write-Host "     curl http://localhost:8000/health" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Nota: La implementación completa de Stable Video Diffusion" -ForegroundColor Yellow
Write-Host "     requiere descargar el modelo (~8GB) y configurar el pipeline." -ForegroundColor Yellow
Write-Host "     Este es un endpoint básico que puede ser extendido." -ForegroundColor Yellow
Write-Host ""
Write-Host "Nota: El modelo completo de Stable Video Diffusion requiere ~8GB" -ForegroundColor Yellow
Write-Host "      y se debe descargar e integrar manualmente." -ForegroundColor Yellow
Write-Host ""

