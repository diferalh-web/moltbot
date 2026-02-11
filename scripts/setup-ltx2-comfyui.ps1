# Script para configurar LTX-2 en ComfyUI
# Instala el custom node ComfyUI-LTXVideo y crea los directorios necesarios
# Uso: .\scripts\setup-ltx2-comfyui.ps1

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar LTX-2 en ComfyUI" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$comfyuiModels = "${env:USERPROFILE}\comfyui-models"
$comfyuiData = "${env:USERPROFILE}\comfyui-data"
$customNodesPath = Join-Path $comfyuiData "custom_nodes"
$ltxVideoPath = Join-Path $customNodesPath "ComfyUI-LTXVideo"

# 1. Crear directorios de modelos
Write-Host "[1/4] Creando directorios para modelos LTX-2..." -ForegroundColor Yellow
$dirs = @(
    "$comfyuiModels\loras",
    "$comfyuiModels\latent_upscale_models"
)
foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Write-Host "  [OK] $dir" -ForegroundColor Green
}
Write-Host ""

# 2. Verificar/crear estructura ComfyUI
Write-Host "[2/4] Verificando estructura de ComfyUI..." -ForegroundColor Yellow
if (!(Test-Path $comfyuiData)) {
    New-Item -ItemType Directory -Force -Path $comfyuiData | Out-Null
    Write-Host "  [!] comfyui-data creado (ComfyUI debe estar corriendo o usaras recrear-comfyui-robusto)" -ForegroundColor Yellow
}
if (!(Test-Path $customNodesPath)) {
    New-Item -ItemType Directory -Force -Path $customNodesPath | Out-Null
    Write-Host "  [OK] custom_nodes creado" -ForegroundColor Green
} else {
    Write-Host "  [OK] custom_nodes existe" -ForegroundColor Green
}
Write-Host ""

# 3. Instalar ComfyUI-LTXVideo
Write-Host "[3/4] Instalando ComfyUI-LTXVideo..." -ForegroundColor Yellow
if (Test-Path $ltxVideoPath) {
    Write-Host "  [!] ComfyUI-LTXVideo ya existe" -ForegroundColor Yellow
    $actualizar = Read-Host "  Deseas actualizarlo? (s/n)"
    if ($actualizar -eq "s") {
        Push-Location $ltxVideoPath
        git pull
        Pop-Location
        Write-Host "  [OK] Actualizado" -ForegroundColor Green
    }
} else {
    $gitOk = Get-Command git -ErrorAction SilentlyContinue
    if (!$gitOk) {
        Write-Host "  [X] git no encontrado. Instala Git o clona manualmente:" -ForegroundColor Red
        Write-Host "      cd $customNodesPath" -ForegroundColor Gray
        Write-Host "      git clone https://github.com/Lightricks/ComfyUI-LTXVideo.git" -ForegroundColor Gray
    } else {
        Push-Location $customNodesPath
        git clone https://github.com/Lightricks/ComfyUI-LTXVideo.git
        Pop-Location
        Write-Host "  [OK] ComfyUI-LTXVideo clonado" -ForegroundColor Green
    }
}
Write-Host ""

# 4. Instrucciones para modelos
Write-Host "[4/4] Modelos a descargar:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Para RTX 5070 (12GB VRAM) necesitas estos archivos:" -ForegroundColor White
Write-Host ""
Write-Host "  checkpoints:" -ForegroundColor Cyan
Write-Host "    ltx-2-19b-distilled-fp8.safetensors (~10GB)" -ForegroundColor Gray
Write-Host "    https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-distilled-fp8.safetensors" -ForegroundColor Gray
Write-Host ""
Write-Host "  loras:" -ForegroundColor Cyan
Write-Host "    ltx-2-19b-distilled-lora-384.safetensors" -ForegroundColor Gray
Write-Host "    https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-distilled-lora-384.safetensors" -ForegroundColor Gray
Write-Host ""
Write-Host "  latent_upscale_models:" -ForegroundColor Cyan
Write-Host "    ltx-2-spatial-upscaler-x2-1.0.safetensors" -ForegroundColor Gray
Write-Host "    ltx-2-temporal-upscaler-x2-1.0.safetensors" -ForegroundColor Gray
Write-Host ""
Write-Host "  text_encoders (Gemma 3):" -ForegroundColor Cyan
Write-Host "    Descargar todo el repo: https://huggingface.co/google/gemma-3-12b-it-qat-q4_0-unquantized" -ForegroundColor Gray
Write-Host "    En: $comfyuiModels\text_encoders\gemma-3-12b-it-qat-q4_0-unquantized\" -ForegroundColor Gray
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Configuracion LTX-2 completada!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Descarga los modelos (ver enlaces arriba o usa: huggingface-cli download)" -ForegroundColor White
Write-Host "  2. Si usas recrear-comfyui-robusto: .\scripts\recrear-comfyui-robusto.ps1 -RTX50" -ForegroundColor White
Write-Host "  3. Reinicia ComfyUI: docker restart comfyui" -ForegroundColor White
Write-Host "  4. Abre http://localhost:7860 y carga un workflow de LTX-2" -ForegroundColor White
Write-Host ""
Write-Host "Guia completa: GUIA_LTX2_COMFYUI.md" -ForegroundColor Cyan
Write-Host ""
