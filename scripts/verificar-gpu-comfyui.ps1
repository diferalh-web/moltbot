# Verifica que ComfyUI tenga acceso a la GPU NVIDIA
# Ejecutar mientras ComfyUI esta corriendo (o durante una generacion)

Write-Host ""
Write-Host "=== Verificacion GPU para ComfyUI ===" -ForegroundColor Cyan
Write-Host ""

# 1. Comprobar que el contenedor existe y esta corriendo
$container = docker ps --filter "name=comfyui" --format "{{.Names}}" 2>$null
if (-not $container) {
    Write-Host "[X] Contenedor 'comfyui' no esta corriendo" -ForegroundColor Red
    exit 1
}
Write-Host "[1] Contenedor comfyui: OK (corriendo)" -ForegroundColor Green

# 2. Comprobar si el contenedor tiene GPUs asignadas
$gpuConfig = docker inspect comfyui --format '{{.HostConfig.DeviceRequests}}' 2>$null
$hasGpus = docker inspect comfyui --format '{{.HostConfig.DeviceRequests}}' 2>$null
$runtime = docker inspect comfyui --format '{{.HostConfig.Runtime}}' 2>$null

# Alternativa: ejecutar nvidia-smi dentro del contenedor
Write-Host ""
Write-Host "[2] Ejecutando nvidia-smi DENTRO del contenedor comfyui..." -ForegroundColor Yellow
Write-Host ""
try {
    $nvidiaOut = docker exec comfyui nvidia-smi 2>&1
    if ($LASTEXITCODE -ne 0 -or $nvidiaOut -match "could not select device|No devices found|nvidia-smi: not found") {
        Write-Host "[X] ComfyUI NO tiene acceso a la GPU" -ForegroundColor Red
        Write-Host $nvidiaOut -ForegroundColor Gray
        Write-Host ""
        Write-Host "Posibles causas:" -ForegroundColor Yellow
        Write-Host "  - El contenedor se creo sin --gpus all" -ForegroundColor White
        Write-Host "  - NVIDIA Container Toolkit no instalado" -ForegroundColor White
        Write-Host "  - Driver NVIDIA desactualizado" -ForegroundColor White
        Write-Host ""
        Write-Host "Si usas recrear-comfyui-robusto.ps1, incluye --gpus all." -ForegroundColor Gray
        Write-Host "Si usas docker-compose, verifica deploy.resources.reservations.devices." -ForegroundColor Gray
        exit 1
    }
    Write-Host $nvidiaOut -ForegroundColor Gray
    Write-Host ""
    Write-Host "[OK] ComfyUI VE la GPU NVIDIA" -ForegroundColor Green
} catch {
    Write-Host "[X] Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "    nvidia-smi no pudo ejecutarse dentro del contenedor." -ForegroundColor Gray
    exit 1
}

# 3. Comprobar procesos Python usando GPU (durante generacion)
Write-Host ""
Write-Host "[3] Verificando uso de GPU por procesos..." -ForegroundColor Yellow
$procOut = docker exec comfyui nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv 2>$null
if ($procOut -and $procOut -match "python|torch") {
    Write-Host "Procesos usando GPU:" -ForegroundColor Cyan
    Write-Host $procOut -ForegroundColor Gray
    Write-Host "[OK] ComfyUI esta usando la GPU" -ForegroundColor Green
} else {
    Write-Host "    (No hay procesos activos ahora - ejecuta una generacion y vuelve a correr este script)" -ForegroundColor Gray
    Write-Host "    O ya termino la generacion." -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== Resumen ===" -ForegroundColor Cyan
Write-Host "Si nvidia-smi mostro la GPU arriba, ComfyUI tiene acceso." -ForegroundColor White
Write-Host "Durante una generacion Flux, deberias ver 'python' en los procesos y ~10-20GB de VRAM." -ForegroundColor White
Write-Host ""
