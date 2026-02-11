# Prueba la API de ComfyUI para generar una imagen
# Usa sd_xl_base_1.0 (checkpoint completo: CLIP+VAE+UNet)
# flux2_dev_fp8mixed es solo UNet, no incluye CLIP ni VAE

$comfyUrl = "http://localhost:7860"
$checkpointsDir = "$env:USERPROFILE\comfyui-models\checkpoints"
$prompt = "un gato jugando paintball"
$outFile = "$env:TEMP\comfyui_test.png"

# Detectar checkpoint disponible (sd_xl o v1-5)
$ckpts = Get-ChildItem $checkpointsDir -Filter "*.safetensors" -ErrorAction SilentlyContinue
$checkpoint = if ($ckpts | Where-Object { $_.Name -like "*xl*" -or $_.Name -like "*sd_xl*" }) {
    ($ckpts | Where-Object { $_.Name -like "*xl*" -or $_.Name -like "*sd_xl*" } | Select-Object -First 1).Name
} elseif ($ckpts) {
    ($ckpts | Select-Object -First 1).Name
} else {
    "sd_xl_base_1.0.safetensors"  # fallback, fallara si no existe
}

Write-Host "ComfyUI API Test" -ForegroundColor Cyan
Write-Host "  URL: $comfyUrl" -ForegroundColor Gray
Write-Host "  Checkpoint: $checkpoint" -ForegroundColor Gray
Write-Host "  Prompt: $prompt" -ForegroundColor Gray
Write-Host ""

# Verificar que hay checkpoints
if (-not $ckpts -or $ckpts.Count -eq 0) {
    Write-Host "[!] No hay checkpoints (.safetensors) en $checkpointsDir" -ForegroundColor Yellow
    Write-Host "    Ejecuta: .\scripts\descargar-modelo-comfyui.ps1" -ForegroundColor White
    Write-Host ""
    exit 1
}

# 1. Verificar que ComfyUI responde
Write-Host "[1] Verificando ComfyUI..." -ForegroundColor Yellow
try {
    $r = Invoke-WebRequest -Uri "$comfyUrl/object_info" -TimeoutSec 30 -UseBasicParsing
    if ($r.StatusCode -ne 200) { throw "Status $($r.StatusCode)" }
    Write-Host "    OK ComfyUI responde" -ForegroundColor Green
} catch {
    Write-Host "    ERROR: ComfyUI no responde en $comfyUrl" -ForegroundColor Red
    Write-Host "    Detalle: $($_.Exception.Message)" -ForegroundColor Gray
    exit 1
}

# 2. Workflow Flux text-to-image
$workflow = @{
    "1" = @{
        class_type = "CheckpointLoaderSimple"
        inputs    = @{ ckpt_name = $checkpoint }
    }
    "2" = @{
        class_type = "CLIPTextEncode"
        inputs     = @{ text = $prompt; clip = @("1", 1) }
    }
    "3" = @{
        class_type = "CLIPTextEncode"
        inputs     = @{ text = ""; clip = @("1", 1) }
    }
    "4" = @{
        class_type = "EmptyLatentImage"
        inputs     = @{ width = 1024; height = 1024; batch_size = 1 }
    }
    "5" = @{
        class_type = "KSampler"
        inputs     = @{
            model        = @("1", 0)
            positive     = @("2", 0)
            negative     = @("3", 0)
            latent_image = @("4", 0)
            seed         = (Get-Random -Minimum 1 -Maximum 999999999)
            steps        = 20
            cfg          = 3.5
            sampler_name = "euler"
            scheduler    = "simple"
            denoise      = 1.0
        }
    }
    "6" = @{
        class_type = "VAEDecode"
        inputs     = @{ samples = @("5", 0); vae = @("1", 2) }
    }
    "7" = @{
        class_type = "SaveImage"
        inputs     = @{ images = @("6", 0); filename_prefix = "comfyui_test" }
    }
}

$body = @{ prompt = $workflow } | ConvertTo-Json -Depth 10 -Compress

# 3. Enviar workflow
Write-Host "[2] Enviando workflow a /prompt..." -ForegroundColor Yellow
try {
    $resp = Invoke-RestMethod -Uri "$comfyUrl/prompt" -Method POST -Body $body -ContentType "application/json"
    $promptId = $resp.prompt_id
    Write-Host "    Prompt ID: $promptId" -ForegroundColor Green
} catch {
    Write-Host "    ERROR al enviar: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) { Write-Host "    $($_.ErrorDetails.Message)" -ForegroundColor Gray }
    exit 1
}

# 4. Esperar y obtener resultado
Write-Host "[3] Esperando generacion (puede tardar 30-90s)..." -ForegroundColor Yellow
$maxWait = 120
$elapsed = 0
$hist = $null

while ($elapsed -lt $maxWait) {
    Start-Sleep -Seconds 3
    $elapsed += 3
    Write-Host "    ... $elapsed s" -ForegroundColor Gray

    try {
        $hist = Invoke-RestMethod -Uri "$comfyUrl/history/$promptId" -Method GET
        if ($hist.PSObject.Properties.Name -contains $promptId) {
            $outputs = $hist.$promptId.outputs
            foreach ($nodeId in $outputs.PSObject.Properties.Name) {
                $nodeOut = $outputs.$nodeId
                if ($nodeOut.images -and $nodeOut.images.Count -gt 0) {
                    $imgInfo = $nodeOut.images[0]
                    $filename = $imgInfo.filename
                    $subfolder = if ($imgInfo.subfolder) { $imgInfo.subfolder } else { "" }
                    $imgType = if ($imgInfo.type) { $imgInfo.type } else { "output" }

                    # 5. Descargar imagen
                    $viewParams = "filename=$filename&type=$imgType"
                    if ($subfolder) { $viewParams += "&subfolder=$subfolder" }
                    $viewUrl = "$comfyUrl/view?$viewParams"

                    Write-Host "[4] Descargando imagen..." -ForegroundColor Yellow
                    Invoke-WebRequest -Uri $viewUrl -OutFile $outFile -UseBasicParsing
                    Write-Host "" -ForegroundColor Green
                    Write-Host "OK - Imagen guardada en: $outFile" -ForegroundColor Green
                    Write-Host "Abre el archivo para verla." -ForegroundColor Cyan
                    exit 0
                }
            }
        }
    } catch {
        # Seguir intentando
    }
}

Write-Host "" -ForegroundColor Red
Write-Host "TIMEOUT: No se recibio imagen en $maxWait segundos." -ForegroundColor Red
Write-Host "Revisa los logs de ComfyUI: docker logs comfyui --tail 30" -ForegroundColor Yellow
exit 1
