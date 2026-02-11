# Arrancar ComfyUI con los nuevos volúmenes (loras, diffusion_models, etc.)
# Ejecutar manualmente si docker compose up falla con timeout de red

param(
    [switch]$NoPull,
    [string]$ComposeFile = "docker-compose-extended.yml"
)

$ErrorActionPreference = "Continue"

Write-Host "=== Arrancar ComfyUI con modelos montados ===" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar Docker
Write-Host "[1] Verificando Docker..." -ForegroundColor Yellow
$dockerOk = $false
try {
    $null = docker version 2>&1
    if ($LASTEXITCODE -eq 0) { $dockerOk = $true }
} catch { }
if (-not $dockerOk) {
    Write-Host "    [!] Docker no responde. ¿Está Docker Desktop en ejecución?" -ForegroundColor Red
    exit 1
}
Write-Host "    OK Docker responde" -ForegroundColor Green

# 2. Verificar si ya tenemos la imagen de ComfyUI
Write-Host "[2] Buscando imagen ComfyUI..." -ForegroundColor Yellow
$hasImage = docker images ghcr.io/comfyanonymous/comfyui --format "{{.Repository}}" 2>$null
if ($hasImage) {
    Write-Host "    OK Imagen encontrada localmente" -ForegroundColor Green
    $useNoPull = $true
} else {
    Write-Host "    No hay imagen local, se intentará descargar" -ForegroundColor Yellow
    $useNoPull = $false
}

# 3. Probar conectividad a ghcr.io (si vamos a descargar)
if (-not $useNoPull -and -not $NoPull) {
    Write-Host "[3] Probando ghcr.io..." -ForegroundColor Yellow
    try {
        $r = Invoke-WebRequest -Uri "https://ghcr.io" -Method Get -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
        Write-Host "    OK ghcr.io accesible" -ForegroundColor Green
    } catch {
        Write-Host "    [!] ghcr.io: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "    Puede que el pull falle. Prueba con -NoPull si ya tienes la imagen." -ForegroundColor Gray
    }
} else {
    Write-Host "[3] Omitiendo prueba de red (usando imagen local)" -ForegroundColor Gray
}

# 4. Arrancar ComfyUI
Write-Host "[4] Iniciando ComfyUI..." -ForegroundColor Yellow
$projectRoot = Split-Path $PSScriptRoot -Parent
$composePath = Join-Path $projectRoot $ComposeFile
if (-not (Test-Path $composePath)) {
    $composePath = Join-Path (Get-Location) $ComposeFile
}

$args = @("-f", $composePath, "up", "-d", "comfyui")
if ($NoPull -or $useNoPull) {
    $args += "--no-pull"
    Write-Host "    Usando --no-pull (imagen local)" -ForegroundColor Gray
}

Push-Location (Split-Path $composePath)
try {
    docker compose @args
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "ComfyUI iniciado. URL: http://localhost:7860" -ForegroundColor Green
        Write-Host "Refresca la página (F5) para ver loras, diffusion_models, text_encoders y vae." -ForegroundColor Gray
    } else {
        Write-Host ""
        Write-Host "Hubo un error. Si fue timeout de red:" -ForegroundColor Yellow
        Write-Host "  - Espera unos minutos y vuelve a ejecutar el script" -ForegroundColor Gray
        Write-Host "  - O ejecuta con -NoPull si ya tienes la imagen: .\arrancar-comfyui-con-modelos.ps1 -NoPull" -ForegroundColor Gray
    }
} finally {
    Pop-Location
}
