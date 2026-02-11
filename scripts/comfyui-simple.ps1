# Script simple para crear ComfyUI usando imagen pre-construida
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurando ComfyUI (Version Simple)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Detener y eliminar contenedor existente
Write-Host "[1/4] Limpiando contenedor anterior..." -ForegroundColor Yellow
docker stop comfyui 2>$null | Out-Null
docker rm comfyui 2>$null | Out-Null
Write-Host "[OK] Limpieza completada" -ForegroundColor Green
Write-Host ""

# Crear directorios
Write-Host "[2/4] Creando directorios..." -ForegroundColor Yellow
$comfyuiModels = "${env:USERPROFILE}\comfyui-models"
$comfyuiOutput = "${env:USERPROFILE}\comfyui-output"
$comfyuiInput = "${env:USERPROFILE}\comfyui-input"
New-Item -ItemType Directory -Force -Path $comfyuiModels | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiOutput | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiInput | Out-Null
Write-Host "[OK] Directorios creados" -ForegroundColor Green
Write-Host ""

# Intentar usar imagen oficial primero, si falla usar alternativa
Write-Host "[3/4] Creando contenedor ComfyUI..." -ForegroundColor Yellow
Write-Host "      Intentando imagen oficial..." -ForegroundColor Gray

# Intentar imagen oficial de ComfyUI
docker pull ghcr.io/comfyanonymous/comfyui:latest 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Imagen oficial descargada" -ForegroundColor Green
    
    docker run -d `
      --name comfyui `
      -p 7860:8188 `
      -v "${env:USERPROFILE}/comfyui-models:/root/.cache/huggingface" `
      -v "${env:USERPROFILE}/comfyui-output:/root/ComfyUI/output" `
      -v "${env:USERPROFILE}/comfyui-input:/root/ComfyUI/input" `
      --restart unless-stopped `
      --gpus all `
      -e NVIDIA_VISIBLE_DEVICES=all `
      ghcr.io/comfyanonymous/comfyui:latest
      
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Contenedor creado con imagen oficial" -ForegroundColor Green
    } else {
        Write-Host "[!] Error con imagen oficial, usando alternativa..." -ForegroundColor Yellow
        $useAlternative = $true
    }
} else {
    Write-Host "[!] Imagen oficial no disponible, usando alternativa..." -ForegroundColor Yellow
    $useAlternative = $true
}

# Si la imagen oficial falla, usar imagen alternativa con instalacion manual
if ($useAlternative) {
    Write-Host "      Usando imagen alternativa..." -ForegroundColor Gray
    
    docker run -d `
      --name comfyui `
      -p 7860:8188 `
      -v "${env:USERPROFILE}/comfyui-models:/root/.cache/huggingface" `
      -v "${env:USERPROFILE}/comfyui-output:/root/ComfyUI/output" `
      -v "${env:USERPROFILE}/comfyui-input:/root/ComfyUI/input" `
      --restart unless-stopped `
      --gpus all `
      -e NVIDIA_VISIBLE_DEVICES=all `
      -w /root `
      python:3.11-slim `
      bash -c "apt-get update && apt-get install -y git && pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && cd /root && if [ ! -d ComfyUI ]; then git clone https://github.com/comfyanonymous/ComfyUI.git; elif [ -d ComfyUI/.git ]; then cd ComfyUI && git pull; else cd /root && rm -rf ComfyUI/.git ComfyUI/*.py ComfyUI/*.md ComfyUI/*.txt 2>/dev/null || true && git clone https://github.com/comfyanonymous/ComfyUI.git ComfyUI-tmp && mv ComfyUI-tmp/* ComfyUI-tmp/.git ComfyUI/ 2>/dev/null || cp -r ComfyUI-tmp/* ComfyUI/ && rm -rf ComfyUI-tmp; fi && cd /root/ComfyUI && pip install -r requirements.txt && python main.py --listen 0.0.0.0 --port 8188"
      
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Contenedor creado con imagen alternativa" -ForegroundColor Green
        Write-Host "[!] Nota: La primera vez puede tardar 10-15 minutos en instalar" -ForegroundColor Yellow
    } else {
        Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
        exit 1
    }
}
Write-Host ""

# Esperar y verificar
Write-Host "[4/4] Esperando inicio (30 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

$status = docker ps --filter "name=comfyui" --format "{{.Status}}" 2>$null
if ($status -and $status -notlike "*Restarting*") {
    Write-Host "[OK] ComfyUI esta corriendo: $status" -ForegroundColor Green
} else {
    Write-Host "[!] ComfyUI puede estar aun iniciando" -ForegroundColor Yellow
    Write-Host "    Verifica con: docker logs comfyui" -ForegroundColor Gray
}
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] ComfyUI configurado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Acceso:" -ForegroundColor Yellow
Write-Host "  http://localhost:7860" -ForegroundColor Cyan
Write-Host ""
Write-Host "Si no funciona:" -ForegroundColor Yellow
Write-Host "  1. Espera 2-3 minutos mas" -ForegroundColor White
Write-Host "  2. Verifica logs: docker logs comfyui" -ForegroundColor White
Write-Host "  3. Verifica estado: docker ps | Select-String comfyui" -ForegroundColor White
Write-Host ""

