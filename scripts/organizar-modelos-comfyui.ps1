# Organiza los modelos de comfyui-models en la estructura que ComfyUI espera
# Usa enlaces simbólicos para no duplicar archivos grandes

$base = "$env:USERPROFILE\comfyui-models"
$ckpt = "$base\checkpoints"
$vae = "$base\vae"
$diff = "$base\diffusion_models"
$clip = "$base\text_encoders"

Write-Host "Organizando modelos para ComfyUI" -ForegroundColor Cyan
Write-Host ""

# Crear directorios
New-Item -ItemType Directory -Force -Path $ckpt | Out-Null
New-Item -ItemType Directory -Force -Path $vae | Out-Null
New-Item -ItemType Directory -Force -Path $diff | Out-Null
New-Item -ItemType Directory -Force -Path $clip | Out-Null

function Link-OrCopy($src, $dst) {
    if (-not (Test-Path $dst)) {
        try {
            New-Item -ItemType SymbolicLink -Path $dst -Target $src -ErrorAction Stop | Out-Null
        } catch {
            Copy-Item $src $dst -Force
        }
        return $true
    }
    return $false
}

# Diffusion models (UNet only: flux2, etc.)
@("flux2_dev_fp8mixed.safetensors", "mistral_3_small_flux2_bf16.safetensors") | ForEach-Object {
    $src = Join-Path $base $_
    if (Test-Path $src) {
        if (Link-OrCopy $src (Join-Path $diff $_)) {
            Write-Host "  [OK] $_ -> diffusion_models/" -ForegroundColor Green
        }
    }
}

# VAE (desde raiz y desde vae/)
Get-ChildItem $base -Filter "*.safetensors" -File -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -like "*vae*" -or $_.Name -eq "ae.safetensors"
} | ForEach-Object {
    if (Link-OrCopy $_.FullName (Join-Path $vae $_.Name)) {
        Write-Host "  [OK] $($_.Name) -> vae/" -ForegroundColor Green
    }
}
# vae/ ya está montado; los de la raíz se enlazan arriba

# Text encoders (CLIP) - qwen para Flux
Get-ChildItem $base -Filter "*.safetensors" -File -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -like "*qwen*" -and $_.Name -notlike "*image*" -and $_.Name -notlike "*edit*" -and $_.Name -notlike "*vl*"
} | ForEach-Object {
    if (Link-OrCopy $_.FullName (Join-Path $clip $_.Name)) {
        Write-Host "  [OK] $($_.Name) -> text_encoders/" -ForegroundColor Green
    }
}

# Checkpoints (modelos completos: sd_xl, v1-5) - si no hay, avisar
$ckptFiles = Get-ChildItem $ckpt -Filter "*.safetensors" -ErrorAction SilentlyContinue
if (-not $ckptFiles -or $ckptFiles.Name -eq "put_checkpoints_here") {
    Write-Host ""
    Write-Host "  [!] No hay checkpoints completos. Para generar imagenes necesitas uno:" -ForegroundColor Yellow
    Write-Host "      .\scripts\descargar-modelo-comfyui.ps1" -ForegroundColor White
    Write-Host ""
}

# Resumen
Write-Host ""
Write-Host "Estructura actual:" -ForegroundColor Cyan
Get-ChildItem $ckpt -Filter "*.safetensors" | ForEach-Object { Write-Host "  checkpoints: $($_.Name)" }
Get-ChildItem $vae -Filter "*.safetensors" -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "  vae: $($_.Name)" }
Get-ChildItem $diff -Filter "*.safetensors" -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "  diffusion_models: $($_.Name)" }
Get-ChildItem $clip -Filter "*.safetensors" -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "  text_encoders: $($_.Name)" }
Write-Host ""
Write-Host "Reinicia ComfyUI para que detecte los modelos: docker restart comfyui" -ForegroundColor Yellow
