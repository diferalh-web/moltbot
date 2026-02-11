# Script para descargar el repo Gemma 3 text encoder (requerido por LTX-2)
# IMPORTANTE: Gemma 3 requiere aceptar la licencia de Google en Hugging Face
# 1. Crea cuenta en https://huggingface.co/join
# 2. Entra a https://huggingface.co/google/gemma-3-12b-it-qat-q4_0-unquantized y acepta la licencia
# 3. Crea un token en https://huggingface.co/settings/tokens
# 4. Ejecuta: $env:HF_TOKEN = "hf_xxxx"; .\scripts\descargar-gemma3-ltx2.ps1

param([string]$HfToken = $env:HF_TOKEN)

$baseUrl = "https://huggingface.co/google/gemma-3-12b-it-qat-q4_0-unquantized/resolve/main"
$destDir = Join-Path $env:USERPROFILE "comfyui-models\text_encoders\gemma-3-12b-it-qat-q4_0-unquantized"

$files = @(
    ".gitattributes",
    "README.md",
    "added_tokens.json",
    "chat_template.json",
    "config.json",
    "generation_config.json",
    "model.safetensors.index.json",
    "preprocessor_config.json",
    "processor_config.json",
    "special_tokens_map.json",
    "tokenizer.json",
    "tokenizer.model",
    "tokenizer_config.json",
    "model-00001-of-00005.safetensors",
    "model-00002-of-00005.safetensors",
    "model-00003-of-00005.safetensors",
    "model-00004-of-00005.safetensors",
    "model-00005-of-00005.safetensors"
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Descargando Gemma 3 Text Encoder" -ForegroundColor Cyan
Write-Host "Destino: $destDir" -ForegroundColor Gray
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

if ([string]::IsNullOrEmpty($HfToken)) {
    Write-Host "[!] Gemma 3 requiere autenticacion en Hugging Face." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Pasos:" -ForegroundColor Cyan
    Write-Host "  1. Crea una cuenta en https://huggingface.co/join" -ForegroundColor White
    Write-Host "  2. Entra a https://huggingface.co/google/gemma-3-12b-it-qat-q4_0-unquantized" -ForegroundColor White
    Write-Host "  3. Haz clic en 'Agree and access repository' (acepta la licencia de Google)" -ForegroundColor White
    Write-Host "  4. Crea un token en https://huggingface.co/settings/tokens (tipo: Read)" -ForegroundColor White
    Write-Host "  5. Ejecuta:" -ForegroundColor White
    Write-Host '     $env:HF_TOKEN = "hf_tu_token"; .\scripts\descargar-gemma3-ltx2.ps1' -ForegroundColor Gray
    Write-Host ""
    Write-Host "O usa Hugging Face CLI (con Python):" -ForegroundColor Cyan
    Write-Host "  huggingface-cli login" -ForegroundColor Gray
    Write-Host "  huggingface-cli download google/gemma-3-12b-it-qat-q4_0-unquantized --local-dir `"$destDir`"" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

New-Item -ItemType Directory -Force -Path $destDir | Out-Null
$headers = @{ Authorization = "Bearer $HfToken" }

$total = $files.Count
$current = 0

foreach ($file in $files) {
    $current++
    $destPath = Join-Path $destDir $file
    if (Test-Path $destPath) {
        $size = (Get-Item $destPath).Length
        if ($size -gt 1000) {
            Write-Host "[$current/$total] Ya existe: $file" -ForegroundColor Green
            continue
        }
    }
    
    $url = "$baseUrl/$file"
    Write-Host "[$current/$total] Descargando: $file" -ForegroundColor Yellow
    try {
        $ProgressPreference = 'Continue'
        Invoke-WebRequest -Uri $url -OutFile $destPath -UseBasicParsing -Headers $headers
        Write-Host "  [OK]" -ForegroundColor Green
    } catch {
        Write-Host "  [X] Error: $_" -ForegroundColor Red
        Write-Host "  URL: $url" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Descarga completada" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Si fallo algun archivo grande, usa Hugging Face CLI:" -ForegroundColor Yellow
Write-Host "  pip install huggingface_hub[cli]" -ForegroundColor Gray
Write-Host "  huggingface-cli download google/gemma-3-12b-it-qat-q4_0-unquantized --local-dir `"$destDir`"" -ForegroundColor Gray
Write-Host ""
