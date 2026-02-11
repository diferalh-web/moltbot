# Arregla ComfyUI cuando esta en ciclo de reinicio (Restarting)
# Elimina el contenedor dañado y crea uno nuevo con la imagen oficial

$projectRoot = Split-Path $PSScriptRoot -Parent
Push-Location $projectRoot | Out-Null

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Arreglar ComfyUI (ciclo de reinicio)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Detener y eliminar contenedor actual
Write-Host "[1/4] Eliminando contenedor dañado..." -ForegroundColor Yellow
docker stop comfyui 2>$null | Out-Null
docker rm comfyui 2>$null | Out-Null
Write-Host "    OK" -ForegroundColor Green
Write-Host ""

# 2. Verificar directorios
Write-Host "[2/4] Verificando directorios..." -ForegroundColor Yellow
$checkpoints = "${env:USERPROFILE}\comfyui-models\checkpoints"
$output = "${env:USERPROFILE}\comfyui-output"
$inputDir = "${env:USERPROFILE}\comfyui-input"
New-Item -ItemType Directory -Force -Path $checkpoints | Out-Null
New-Item -ItemType Directory -Force -Path $output | Out-Null
New-Item -ItemType Directory -Force -Path $inputDir | Out-Null
Write-Host "    OK" -ForegroundColor Green
Write-Host ""

# 3. Intentar con docker-compose (imagen oficial)
Write-Host "[3/4] Creando ComfyUI con imagen oficial..." -ForegroundColor Yellow
$composeFiles = @("docker-compose-unified.yml", "docker-compose-extended.yml")
$created = $false

foreach ($f in $composeFiles) {
    $path = Join-Path $projectRoot $f
    if (Test-Path $path) {
        docker compose -f $path up -d comfyui 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    OK (usando $f)" -ForegroundColor Green
            $created = $true
            break
        }
    }
}

# 4. Si compose falla, usar script robusto (python:3.11-slim)
if (-not $created) {
    Write-Host "    Imagen oficial no disponible, usando metodo alternativo..." -ForegroundColor Yellow
    Pop-Location | Out-Null
    & "$PSScriptRoot\recrear-comfyui-robusto.ps1"
    exit $LASTEXITCODE
}
Write-Host ""

# 5. Esperar y verificar
Write-Host "[4/4] Esperando inicio (45 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 45

$status = docker ps --filter "name=comfyui" --format "{{.Status}}" 2>$null
if ($status -and $status -notlike "*Restarting*") {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "[OK] ComfyUI arreglado y corriendo!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Acceso: http://localhost:7860" -ForegroundColor Cyan
    Write-Host "Probar: .\scripts\probar-comfyui-api.ps1" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "[!] ComfyUI puede estar aun iniciando" -ForegroundColor Yellow
    Write-Host "    Verifica: docker logs comfyui -f" -ForegroundColor Gray
}
Write-Host ""

Pop-Location | Out-Null
