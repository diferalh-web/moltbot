# Script para configurar ComfyUI
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar ComfyUI (Generación Avanzada de Imágenes)" -ForegroundColor Cyan
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
        Write-Host "[!] ComfyUI funciona mejor con GPU" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[!] nvidia-smi no disponible" -ForegroundColor Yellow
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
$comfyuiModels = "${env:USERPROFILE}\comfyui-models"
$comfyuiOutput = "${env:USERPROFILE}\comfyui-output"
$comfyuiInput = "${env:USERPROFILE}\comfyui-input"
New-Item -ItemType Directory -Force -Path $comfyuiModels | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiOutput | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiInput | Out-Null
Write-Host "[OK] Directorios creados" -ForegroundColor Green
Write-Host ""

# Crear contenedor ComfyUI
Write-Host "[5/6] Creando contenedor ComfyUI..." -ForegroundColor Yellow

# Detener y eliminar si existe
docker stop comfyui 2>$null | Out-Null
docker rm comfyui 2>$null | Out-Null

# Crear nuevo contenedor usando imagen alternativa
# Si la imagen oficial no está disponible, usamos una imagen base y construimos ComfyUI
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
  bash -c "apt-get update && apt-get install -y git curl && pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && if [ -d /root/ComfyUI ]; then cd /root/ComfyUI && git pull || (cd /root && rm -rf ComfyUI && git clone https://github.com/comfyanonymous/ComfyUI.git /root/ComfyUI && cd /root/ComfyUI); else git clone https://github.com/comfyanonymous/ComfyUI.git /root/ComfyUI && cd /root/ComfyUI; fi && pip install -r requirements.txt && python main.py --listen 0.0.0.0 --port 8188"

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Contenedor ComfyUI creado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "[6/6] Esperando a que ComfyUI inicie (40 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 40

# Configurar firewall
Write-Host "Configurando firewall para puerto 7860..." -ForegroundColor Yellow
try {
    $existingRule = Get-NetFirewallRule -DisplayName "ComfyUI" -ErrorAction SilentlyContinue
    if ($existingRule) {
        Write-Host "[OK] Regla de firewall ya existe" -ForegroundColor Green
    } else {
        New-NetFirewallRule -DisplayName "ComfyUI" -Direction Inbound -Protocol TCP -LocalPort 7860 -Action Allow -ErrorAction SilentlyContinue | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Regla de firewall creada" -ForegroundColor Green
        } else {
            Write-Host "[!] No se pudo crear regla de firewall automáticamente" -ForegroundColor Yellow
            Write-Host "    Ejecuta manualmente como Administrador:" -ForegroundColor Yellow
            Write-Host "    netsh advfirewall firewall add rule name=`"ComfyUI`" dir=in action=allow protocol=TCP localport=7860" -ForegroundColor White
        }
    }
} catch {
    Write-Host "[!] Error al configurar firewall: $_" -ForegroundColor Yellow
    Write-Host "    Ejecuta manualmente como Administrador:" -ForegroundColor Yellow
    Write-Host "    netsh advfirewall firewall add rule name=`"ComfyUI`" dir=in action=allow protocol=TCP localport=7860" -ForegroundColor White
}
Write-Host ""

# Verificar estado
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] ComfyUI configurado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Estado del contenedor:" -ForegroundColor Yellow
docker ps --filter "name=comfyui" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""
Write-Host "Acceso a la interfaz web:" -ForegroundColor Yellow
Write-Host "  http://localhost:7860" -ForegroundColor Cyan
Write-Host "  http://$ipAddress:7860" -ForegroundColor Cyan
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Abre http://localhost:7860 en tu navegador" -ForegroundColor White
Write-Host "  2. ComfyUI tiene una interfaz visual para crear workflows" -ForegroundColor White
Write-Host "  3. Los modelos se descargan automáticamente al usar" -ForegroundColor White
Write-Host ""
Write-Host "Nota: ComfyUI es una interfaz avanzada para generación de imágenes." -ForegroundColor Yellow
Write-Host "      Puedes usarla directamente o a través de Open WebUI." -ForegroundColor Yellow
Write-Host ""

