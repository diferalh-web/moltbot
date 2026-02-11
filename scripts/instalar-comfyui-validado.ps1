# Script para instalar ComfyUI con validación paso a paso
# Valida que el clonado esté completo antes de continuar

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Instalar ComfyUI (Con Validación)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Detener contenedor anterior
Write-Host "[1/6] Limpiando contenedor anterior..." -ForegroundColor Yellow
docker stop comfyui 2>$null | Out-Null
docker rm comfyui 2>$null | Out-Null
Write-Host "[OK] Limpiado" -ForegroundColor Green
Write-Host ""

# Crear directorios
Write-Host "[2/6] Creando directorios..." -ForegroundColor Yellow
$comfyuiModels = "${env:USERPROFILE}\comfyui-models"
$comfyuiOutput = "${env:USERPROFILE}\comfyui-output"
$comfyuiInput = "${env:USERPROFILE}\comfyui-input"

New-Item -ItemType Directory -Force -Path $comfyuiModels | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiOutput | Out-Null
New-Item -ItemType Directory -Force -Path $comfyuiInput | Out-Null
Write-Host "[OK] Directorios creados" -ForegroundColor Green
Write-Host ""

# Script de instalación con validación (sin heredoc para evitar problemas de finales de línea)
Write-Host "[3/6] Creando contenedor con script de validación..." -ForegroundColor Yellow

# Usar un comando bash en una sola línea para evitar problemas de finales de línea
# Maneja correctamente los directorios montados (input/output)
$installScript = "apt-get update -qq && apt-get install -y -qq git curl >/dev/null 2>&1 && echo '[PASO 1] Dependencias del sistema instaladas' && pip install -q torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && echo '[PASO 2] PyTorch instalado' && cd /root && echo '[PASO 3] Verificando directorio ComfyUI...' && (if [ -d ComfyUI ]; then cd ComfyUI && if [ -d .git ] && git log --oneline -1 >/dev/null 2>&1 && [ -f main.py ] && [ -f requirements.txt ]; then echo '[PASO 3] ComfyUI ya existe y es válido, actualizando...' && git pull origin main && cd .. && echo '[PASO 3] ComfyUI actualizado'; else echo '[PASO 3] ComfyUI existe pero está corrupto, limpiando...' && cd .. && rm -rf ComfyUI/.git ComfyUI/*.py ComfyUI/*.md ComfyUI/*.txt ComfyUI/*.json ComfyUI/*.yml ComfyUI/*.yaml 2>/dev/null || true && echo '[PASO 3] Limpieza completada'; fi; else echo '[PASO 3] No hay directorio anterior'; fi) && echo '[PASO 4] Clonando/Actualizando ComfyUI...' && (if [ -d ComfyUI ] && [ -d ComfyUI/.git ]; then echo '[PASO 4] Ya es un repositorio git válido'; else if [ -d ComfyUI ]; then echo '[PASO 4] Clonando en directorio existente...' && rm -rf ComfyUI-tmp 2>/dev/null || true && git clone https://github.com/comfyanonymous/ComfyUI.git ComfyUI-tmp && cp -r ComfyUI-tmp/.git ComfyUI/ 2>/dev/null && cp ComfyUI-tmp/*.py ComfyUI-tmp/*.md ComfyUI-tmp/*.txt ComfyUI-tmp/*.json ComfyUI-tmp/*.yml ComfyUI-tmp/*.yaml ComfyUI/ 2>/dev/null || true && rm -rf ComfyUI-tmp && echo '[PASO 4] Repositorio restaurado'; else git clone https://github.com/comfyanonymous/ComfyUI.git && echo '[PASO 4] Repositorio clonado'; fi) && cd /root/ComfyUI && echo '[PASO 5] VALIDANDO clonado...' && (test -d .git && echo '[OK] .git encontrado' || (echo '[ERROR] .git no encontrado' && exit 1)) && (test -f main.py && echo '[OK] main.py encontrado' || (echo '[ERROR] main.py no encontrado' && exit 1)) && (test -f requirements.txt && echo '[OK] requirements.txt encontrado' || (echo '[ERROR] requirements.txt no encontrado' && exit 1)) && (git log --oneline -1 >/dev/null 2>&1 && echo '[OK] Repositorio git válido' || (echo '[ERROR] git log falló' && exit 1)) && echo '[PASO 6] Instalando dependencias...' && pip install -q -r requirements.txt && echo '[PASO 6] Dependencias instaladas' && echo '[PASO 7] Iniciando ComfyUI...' && python main.py --listen 0.0.0.0 --port 8188"

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

Write-Host "[4/6] Esperando inicio inicial (30 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "[5/6] Verificando estado..." -ForegroundColor Yellow
$status = docker ps --filter "name=comfyui" --format "{{.Status}}" 2>$null
if ($status) {
    Write-Host "[OK] Contenedor corriendo: $status" -ForegroundColor Green
} else {
    Write-Host "[!] Contenedor no está corriendo, revisa los logs" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "[6/6] Mostrando logs iniciales..." -ForegroundColor Yellow
docker logs comfyui --tail 10
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Instalación Iniciada!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Monitorear progreso:" -ForegroundColor Yellow
Write-Host "  docker logs -f comfyui" -ForegroundColor Cyan
Write-Host ""
Write-Host "El script validará cada paso antes de continuar." -ForegroundColor Gray
Write-Host "Si hay errores, se detendrá y los mostrará." -ForegroundColor Gray
Write-Host ""
Write-Host "Tiempo estimado: 10-30 minutos" -ForegroundColor Gray
Write-Host ""

