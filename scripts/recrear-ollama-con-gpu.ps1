# Script para recrear contenedores Ollama con soporte GPU
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Recrear Ollama con Soporte GPU" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar GPU
Write-Host "[1/5] Verificando GPU NVIDIA..." -ForegroundColor Yellow
$nvidiaSmi = Get-Command nvidia-smi -ErrorAction SilentlyContinue
if (-not $nvidiaSmi) {
    Write-Host "[X] nvidia-smi no encontrado" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] GPU NVIDIA detectada" -ForegroundColor Green
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
Write-Host ""

# Obtener IP local
Write-Host "[2/5] Obteniendo IP local..." -ForegroundColor Yellow
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -notlike "192.168.56.*"} | Select-Object -First 1).IPAddress
Write-Host "[OK] IP: $ipAddress" -ForegroundColor Green
Write-Host ""

# Detener y eliminar contenedores existentes
Write-Host "[3/5] Deteniendo contenedores existentes..." -ForegroundColor Yellow
docker stop ollama-mistral ollama-qwen 2>$null
docker rm ollama-mistral ollama-qwen 2>$null
Write-Host "[OK] Contenedores detenidos" -ForegroundColor Green
Write-Host ""

# Recrear ollama-mistral con GPU
Write-Host "[4/5] Recreando ollama-mistral con GPU..." -ForegroundColor Yellow
docker run -d `
  --name ollama-mistral `
  --gpus all `
  -p 11436:11434 `
  -v ${env:USERPROFILE}/ollama-mistral-data:/root/.ollama `
  --restart unless-stopped `
  -e OLLAMA_HOST=0.0.0.0:11434 `
  ollama/ollama:latest

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Contenedor ollama-mistral creado con GPU" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}

# Esperar a que inicie
Write-Host "Esperando 10 segundos para que inicie..." -ForegroundColor Gray
Start-Sleep -Seconds 10

# Descargar modelo mistral si no existe
Write-Host "Verificando modelo mistral..." -ForegroundColor Yellow
docker exec ollama-mistral ollama list 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Esperando más tiempo..." -ForegroundColor Gray
    Start-Sleep -Seconds 10
}

$models = docker exec ollama-mistral ollama list 2>&1
if ($models -notmatch "mistral") {
    Write-Host "Descargando modelo mistral (esto puede tardar varios minutos)..." -ForegroundColor Yellow
    docker exec ollama-mistral ollama pull mistral
} else {
    Write-Host "[OK] Modelo mistral ya está disponible" -ForegroundColor Green
}
Write-Host ""

# Recrear ollama-qwen con GPU
Write-Host "[5/5] Recreando ollama-qwen con GPU..." -ForegroundColor Yellow
docker run -d `
  --name ollama-qwen `
  --gpus all `
  -p 11437:11434 `
  -v ${env:USERPROFILE}/ollama-qwen-data:/root/.ollama `
  --restart unless-stopped `
  -e OLLAMA_HOST=0.0.0.0:11434 `
  ollama/ollama:latest

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Contenedor ollama-qwen creado con GPU" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
}

# Esperar a que inicie
Write-Host "Esperando 10 segundos para que inicie..." -ForegroundColor Gray
Start-Sleep -Seconds 10

# Descargar modelo qwen si no existe
Write-Host "Verificando modelo qwen..." -ForegroundColor Yellow
$models = docker exec ollama-qwen ollama list 2>&1
if ($models -notmatch "qwen") {
    Write-Host "Descargando modelo qwen2.5:7b (esto puede tardar varios minutos)..." -ForegroundColor Yellow
    docker exec ollama-qwen ollama pull qwen2.5:7b
} else {
    Write-Host "[OK] Modelo qwen ya está disponible" -ForegroundColor Green
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Contenedores recreados con GPU!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "URLs para configurar en Moltbot (VM):" -ForegroundColor Yellow
Write-Host "  Mistral: http://$ipAddress:11436/v1" -ForegroundColor Cyan
Write-Host "  Qwen:    http://$ipAddress:11437/v1" -ForegroundColor Cyan
Write-Host ""
Write-Host "Verificar que están usando GPU:" -ForegroundColor Yellow
Write-Host "  nvidia-smi" -ForegroundColor White
Write-Host ""
Write-Host "Probar desde la VM:" -ForegroundColor Yellow
Write-Host "  curl http://$ipAddress:11436/v1/models" -ForegroundColor White
Write-Host ""












