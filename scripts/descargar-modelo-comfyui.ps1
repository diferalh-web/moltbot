# Script para descargar un modelo de Stable Diffusion/Flux para ComfyUI
# Uso: .\descargar-modelo-comfyui.ps1 [-Model 1|2|3]
#   -Model 1: SD 1.5 (4GB). -Model 2: SD XL (7GB). -Model 3: Flux Schnell FP8 (17GB)
param([int]$Model = 0)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Descargar Modelo para ComfyUI" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Crear directorio
$modelDir = "${env:USERPROFILE}\comfyui-models\checkpoints"
Write-Host "[1/3] Creando directorio..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $modelDir | Out-Null
Write-Host "[OK] Directorio: $modelDir" -ForegroundColor Green
Write-Host ""

# Mostrar opciones
Write-Host "[2/3] Seleccionando modelo..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Modelos disponibles:" -ForegroundColor Cyan
Write-Host "  1. Stable Diffusion 1.5 (4GB) - Recomendado para empezar" -ForegroundColor White
Write-Host "  2. Stable Diffusion XL Base (7GB) - Mejor calidad" -ForegroundColor White
Write-Host "  3. Flux Schnell FP8 (17GB) - Rapido, checkpoint completo para ComfyUI" -ForegroundColor White
Write-Host ""
$opcion = if ($Model -ge 1 -and $Model -le 3) { $Model.ToString() } else { Read-Host "Selecciona opcion (1, 2 o 3)" }

if ($opcion -eq "1") {
    $modelName = "v1-5-pruned-emaonly.safetensors"
    $modelUrl = "https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors"
    $modelSize = "~4GB"
} elseif ($opcion -eq "2") {
    $modelName = "sd_xl_base_1.0.safetensors"
    $modelUrl = "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors"
    $modelSize = "~7GB"
} elseif ($opcion -eq "3") {
    $modelName = "flux1-schnell-fp8.safetensors"
    $modelUrl = "https://huggingface.co/Comfy-Org/flux1-schnell/resolve/main/flux1-schnell-fp8.safetensors"
    $modelSize = "~17GB"
} else {
    Write-Host "[X] Opcion invalida, usando SD 1.5 por defecto" -ForegroundColor Red
    $modelName = "v1-5-pruned-emaonly.safetensors"
    $modelUrl = "https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors"
    $modelSize = "~4GB"
}

$modelPath = Join-Path $modelDir $modelName

# Verificar si ya existe
if (Test-Path $modelPath) {
    Write-Host "[!] El modelo ya existe: $modelName" -ForegroundColor Yellow
    $sobrescribir = if ($Model -ne 0) { "n" } else { Read-Host "Deseas descargarlo de nuevo? (s/n)" }
    if ($sobrescribir -ne "s") {
        Write-Host "[OK] Usando modelo existente" -ForegroundColor Green
        exit 0
    }
}

Write-Host ""
Write-Host "[3/3] Descargando modelo..." -ForegroundColor Yellow
Write-Host "  Modelo: $modelName" -ForegroundColor Gray
Write-Host "  Tamaño: $modelSize" -ForegroundColor Gray
Write-Host "  Esto puede tardar varios minutos..." -ForegroundColor Yellow
Write-Host ""

try {
    # Descargar con barra de progreso
    $ProgressPreference = 'Continue'
    Invoke-WebRequest -Uri $modelUrl -OutFile $modelPath -UseBasicParsing
    
    Write-Host ""
    Write-Host "[OK] Modelo descargado exitosamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "Proximos pasos:" -ForegroundColor Yellow
    Write-Host "  1. Reinicia ComfyUI:" -ForegroundColor White
    Write-Host "     docker restart comfyui" -ForegroundColor Gray
    Write-Host "  2. Espera 2-3 minutos" -ForegroundColor White
    Write-Host "  3. Recarga la pagina de ComfyUI (F5)" -ForegroundColor White
    Write-Host "  4. El modelo aparecera en el dropdown" -ForegroundColor White
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "[X] Error al descargar: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternativa: Descarga manualmente desde:" -ForegroundColor Yellow
    Write-Host "  $modelUrl" -ForegroundColor Cyan
    Write-Host "Y guarda el archivo en: $modelDir" -ForegroundColor White
    Write-Host ""
}









