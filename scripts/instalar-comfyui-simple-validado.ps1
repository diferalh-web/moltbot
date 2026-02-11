# Script simple para instalar ComfyUI con validación paso a paso
# Primero valida el clonado antes de continuar

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Instalar ComfyUI (Simple y Validado)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Detener contenedor anterior
Write-Host "[1/5] Limpiando contenedor anterior..." -ForegroundColor Yellow
docker stop comfyui 2>$null | Out-Null
docker rm comfyui 2>$null | Out-Null
Write-Host "[OK] Limpiado" -ForegroundColor Green
Write-Host ""

# Crear directorios
Write-Host "[2/5] Creando directorios..." -ForegroundColor Yellow
$comfyuiModels = "${env:USERPROFILE}\comfyui-models"
$comfyuiOutput = "${env:USERPROFILE}\comfyui-output"
$comfyuiInput = "${env:USERPROFILE}\comfyui-input"

New-Item -ItemType Directory -Force -Path $comfyuiModels | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiOutput | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiInput | Out-Null
Write-Host "[OK] Directorios creados" -ForegroundColor Green
Write-Host ""

# Script simplificado - primero clona, luego valida, luego instala
Write-Host "[3/5] Creando contenedor..." -ForegroundColor Yellow

# Paso 1: Instalar dependencias
# Paso 2: Clonar ComfyUI (sin intentar eliminar directorios montados)
# Paso 3: Validar que el clonado fue exitoso
# Paso 4: Instalar requirements.txt
# Paso 5: Iniciar servidor

$installScript = "apt-get update -qq && apt-get install -y -qq git curl >/dev/null 2>&1 && echo '[PASO 1] Dependencias del sistema instaladas' && pip install -q torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && echo '[PASO 2] PyTorch instalado' && cd /root && echo '[PASO 3] Verificando/Clonando ComfyUI...' && if [ -d ComfyUI ] && [ -d ComfyUI/.git ] && [ -f ComfyUI/main.py ] && [ -d ComfyUI/comfy ] && [ -d ComfyUI/app ] && [ -f ComfyUI/requirements.txt ]; then echo '[PASO 3] ComfyUI ya existe y es válido, actualizando...' && cd ComfyUI && git fetch origin && git pull || git pull origin master || git pull origin main || true && cd .. && echo '[PASO 3] ComfyUI actualizado'; else echo '[PASO 3] Clonando ComfyUI desde GitHub...' && rm -rf ComfyUI-tmp 2>/dev/null || true && git clone https://github.com/comfyanonymous/ComfyUI.git ComfyUI-tmp && if [ -d ComfyUI ]; then echo '[PASO 3] Limpiando directorio existente (excepto input/output)...' && find ComfyUI -mindepth 1 -maxdepth 1 ! -name 'input' ! -name 'output' -exec rm -rf {} + 2>/dev/null || true && echo '[PASO 3] Copiando todos los archivos del clonado...' && find ComfyUI-tmp -mindepth 1 -maxdepth 1 ! -name '.git' -exec cp -r {} ComfyUI/ \; 2>/dev/null && cp -r ComfyUI-tmp/.git ComfyUI/ 2>/dev/null || true && rm -rf ComfyUI-tmp; else mv ComfyUI-tmp ComfyUI; fi && echo '[PASO 3] ComfyUI clonado'; fi && cd /root/ComfyUI && echo '[PASO 4] VALIDANDO clonado...' && test -d .git && echo '[OK] .git encontrado' && test -f main.py && echo '[OK] main.py encontrado' && test -d comfy && echo '[OK] directorio comfy encontrado' && test -d app && echo '[OK] directorio app encontrado' && test -f requirements.txt && echo '[OK] requirements.txt encontrado' && git log --oneline -1 >/dev/null 2>&1 && echo '[OK] Repositorio git válido' && echo '[PASO 5] Instalando dependencias...' && pip install -q -r requirements.txt && echo '[PASO 5] Dependencias instaladas' && echo '[PASO 6] Iniciando ComfyUI...' && python main.py --listen 0.0.0.0 --port 8188"

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
    Write-Host "[OK] Contenedor creado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "[4/5] Esperando inicio inicial (30 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "[5/5] Verificando estado..." -ForegroundColor Yellow
$status = docker ps --filter "name=comfyui" --format "{{.Status}}" 2>$null
if ($status) {
    Write-Host "[OK] Contenedor: $status" -ForegroundColor Green
} else {
    Write-Host "[!] Revisa los logs" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Instalación Iniciada!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Monitorear progreso:" -ForegroundColor Yellow
Write-Host "  docker logs -f comfyui" -ForegroundColor Cyan
Write-Host ""
Write-Host "El script:" -ForegroundColor Yellow
Write-Host "  1. Instala dependencias" -ForegroundColor Gray
Write-Host "  2. Clona/Actualiza ComfyUI" -ForegroundColor Gray
Write-Host "  3. VALIDA que el clonado fue exitoso" -ForegroundColor Gray
Write-Host "  4. Instala requirements.txt" -ForegroundColor Gray
Write-Host "  5. Inicia el servidor" -ForegroundColor Gray
Write-Host ""
Write-Host "Tiempo estimado: 10-30 minutos" -ForegroundColor Gray
Write-Host ""

