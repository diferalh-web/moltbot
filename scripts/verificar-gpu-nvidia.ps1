# Script para verificar si hay GPU NVIDIA y si los contenedores la están usando
# Ejecutar en PowerShell de Windows

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Verificar GPU NVIDIA y Contenedores" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/4] Verificando GPU NVIDIA en el sistema..." -ForegroundColor Yellow
$nvidiaSmi = Get-Command nvidia-smi -ErrorAction SilentlyContinue
if ($nvidiaSmi) {
    Write-Host "[OK] nvidia-smi encontrado" -ForegroundColor Green
    Write-Host ""
    Write-Host "Información de GPU:" -ForegroundColor Cyan
    nvidia-smi --query-gpu=name,memory.total,memory.free,driver_version --format=csv,noheader
    Write-Host ""
    Write-Host "Estado detallado:" -ForegroundColor Cyan
    nvidia-smi
} else {
    Write-Host "[!] nvidia-smi no encontrado" -ForegroundColor Yellow
    Write-Host "    Esto puede significar:" -ForegroundColor Gray
    Write-Host "    - No hay GPU NVIDIA instalada" -ForegroundColor Gray
    Write-Host "    - Drivers de NVIDIA no instalados" -ForegroundColor Gray
    Write-Host "    - nvidia-smi no está en el PATH" -ForegroundColor Gray
}
Write-Host ""

Write-Host "[2/4] Verificando Docker con soporte NVIDIA..." -ForegroundColor Yellow
$dockerVersion = docker version --format '{{.Server.Version}}' 2>$null
if ($dockerVersion) {
    Write-Host "[OK] Docker versión: $dockerVersion" -ForegroundColor Green
} else {
    Write-Host "[!] No se pudo obtener versión de Docker" -ForegroundColor Yellow
}
Write-Host ""

# Verificar si Docker tiene runtime de NVIDIA
Write-Host "[3/4] Verificando runtime de NVIDIA en Docker..." -ForegroundColor Yellow
$nvidiaRuntime = docker info 2>$null | Select-String "nvidia"
if ($nvidiaRuntime) {
    Write-Host "[OK] Runtime de NVIDIA detectado en Docker" -ForegroundColor Green
    docker info 2>$null | Select-String -Pattern "nvidia|gpu" -Context 2
} else {
    Write-Host "[!] Runtime de NVIDIA no detectado" -ForegroundColor Yellow
    Write-Host "    Los contenedores no pueden usar GPU sin esto" -ForegroundColor Gray
}
Write-Host ""

Write-Host "[4/4] Verificando contenedores Ollama..." -ForegroundColor Yellow
$containers = docker ps -a --filter "name=ollama" --format "{{.Names}}"
foreach ($container in $containers) {
    Write-Host "Contenedor: $container" -ForegroundColor Cyan
    
    # Verificar si tiene acceso a GPU
    $inspect = docker inspect $container 2>$null | ConvertFrom-Json
    $devices = $inspect.HostConfig.DeviceRequests
    $runtime = $inspect.HostConfig.Runtime
    
    if ($devices -or $runtime -eq "nvidia") {
        Write-Host "  [OK] Configurado para usar GPU" -ForegroundColor Green
        if ($devices) {
            Write-Host "  Device Requests: $($devices | ConvertTo-Json)" -ForegroundColor Gray
        }
        if ($runtime) {
            Write-Host "  Runtime: $runtime" -ForegroundColor Gray
        }
    } else {
        Write-Host "  [!] NO está configurado para usar GPU" -ForegroundColor Yellow
        Write-Host "      Necesita --gpus all o --runtime=nvidia" -ForegroundColor Gray
    }
    
    # Verificar variables de entorno relacionadas con GPU
    $envVars = $inspect.Config.Env | Select-String -Pattern "CUDA|GPU|NVIDIA"
    if ($envVars) {
        Write-Host "  Variables de entorno GPU:" -ForegroundColor Cyan
        $envVars | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
    }
    Write-Host ""
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Resumen y Recomendaciones" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

if ($nvidiaSmi) {
    Write-Host "[OK] GPU NVIDIA detectada en el sistema" -ForegroundColor Green
    Write-Host ""
    Write-Host "Para habilitar GPU en contenedores Ollama:" -ForegroundColor Yellow
    Write-Host "  1. Detener contenedores actuales" -ForegroundColor Gray
    Write-Host "  2. Recrearlos con: --gpus all" -ForegroundColor Gray
    Write-Host "  3. O usar: --runtime=nvidia" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Ejemplo:" -ForegroundColor Cyan
    Write-Host "  docker run -d --gpus all --name ollama-mistral-gpu -p 11436:11434 ollama/ollama:latest" -ForegroundColor White
} else {
    Write-Host "[!] GPU NVIDIA no detectada o drivers no instalados" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Para usar GPU:" -ForegroundColor Yellow
    Write-Host "  1. Instalar drivers de NVIDIA" -ForegroundColor Gray
    Write-Host "  2. Instalar NVIDIA Container Toolkit" -ForegroundColor Gray
    Write-Host "  3. Reiniciar Docker" -ForegroundColor Gray
}

Write-Host ""












