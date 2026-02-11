# Prueba el workflow Flux contra ComfyUI
# Detecta flux1-schnell.safetensors o flux1-schnell-fp8.safetensors
# Uso: .\probar-flux-comfyui.ps1 [-Checkpoint nombre.safetensors] [-Prompt "tu prompt"] [-Debug]
#
# Nota: Si falla, prueba con la cola vacia (cierra ComfyUI web, pausa Open WebUI)
# para evitar que otros prompts sobrescriban el historial.

param(
    [string]$Checkpoint = "",
    [string]$Prompt = "un oso caminando por la playa mirando el mar",
    [switch]$Debug
)

$comfyUrl = "http://localhost:7860"
$checkpointsDir = "$env:USERPROFILE\comfyui-models\checkpoints"
$outFile = "$env:TEMP\comfyui_flux_test.png"

# Resolver checkpoint
if ($Checkpoint) {
    $checkpoint = $Checkpoint
    if (-not (Test-Path "$checkpointsDir\$checkpoint")) {
        Write-Host "[X] No existe: $checkpointsDir\$checkpoint" -ForegroundColor Red
        exit 1
    }
} else {
    # Detectar Flux disponible (prioridad: fp8, luego completo)
    $fluxFiles = Get-ChildItem $checkpointsDir -Filter "*flux*.safetensors" -ErrorAction SilentlyContinue
    $checkpoint = if ($fluxFiles | Where-Object { $_.Name -like "*fp8*" }) {
        ($fluxFiles | Where-Object { $_.Name -like "*fp8*" } | Select-Object -First 1).Name
    } elseif ($fluxFiles) {
        ($fluxFiles | Select-Object -First 1).Name
    } else {
        $null
    }
    if (-not $checkpoint) {
        Write-Host "[X] No hay checkpoints Flux en $checkpointsDir" -ForegroundColor Red
        Write-Host "    Buscados: flux1-schnell.safetensors, flux1-schnell-fp8.safetensors" -ForegroundColor Gray
        Write-Host "    Descarga desde: https://huggingface.co/Comfy-Org/flux1-schnell" -ForegroundColor Gray
        exit 1
    }
}

Write-Host ""
Write-Host "=== Prueba Flux + ComfyUI ===" -ForegroundColor Cyan
Write-Host "  URL: $comfyUrl" -ForegroundColor Gray
Write-Host "  Checkpoint: $checkpoint" -ForegroundColor Gray
Write-Host "  Prompt: $Prompt" -ForegroundColor Gray
Write-Host ""

# 1. Verificar ComfyUI
Write-Host "[1] Verificando ComfyUI..." -ForegroundColor Yellow
try {
    $r = Invoke-WebRequest -Uri "$comfyUrl/object_info" -TimeoutSec 30 -UseBasicParsing
    if ($r.StatusCode -ne 200) { throw "Status $($r.StatusCode)" }
    Write-Host "    OK ComfyUI responde" -ForegroundColor Green
} catch {
    Write-Host "    ERROR: ComfyUI no responde en $comfyUrl" -ForegroundColor Red
    Write-Host "    Detalle: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host "    Asegurate que el contenedor comfyui esta corriendo." -ForegroundColor Yellow
    exit 1
}

# 2. Verificar que el checkpoint existe en la lista de ComfyUI
Write-Host "[2] Verificando checkpoint en ComfyUI..." -ForegroundColor Yellow
try {
    $objInfo = Invoke-RestMethod -Uri "$comfyUrl/object_info/CheckpointLoaderSimple" -TimeoutSec 10
    $availableCkpts = $objInfo.CheckpointLoaderSimple.input.required.ckpt_name[0]
    if ($checkpoint -notin $availableCkpts) {
        Write-Host "    [!] '$checkpoint' NO esta en la lista de ComfyUI" -ForegroundColor Yellow
        Write-Host "    Disponibles: $($availableCkpts -join ', ')" -ForegroundColor Gray
        Write-Host "    Si acabas de copiar el archivo, reinicia ComfyUI: docker restart comfyui" -ForegroundColor White
    } else {
        Write-Host "    OK Checkpoint encontrado" -ForegroundColor Green
    }
} catch {
    Write-Host "    (No se pudo verificar lista de checkpoints)" -ForegroundColor Gray
}

# 3. Workflow Flux (mismo que workflow_api_flux.json)
$workflow = @{
    "1" = @{
        class_type = "CheckpointLoaderSimple"
        inputs    = @{ ckpt_name = $checkpoint }
    }
    "2" = @{
        class_type = "CLIPTextEncode"
        inputs     = @{ text = $Prompt; clip = @("1", 1) }
    }
    "3" = @{
        class_type = "CLIPTextEncode"
        inputs     = @{ text = "blurry, low quality, distorted, ugly, bad anatomy, watermark, text"; clip = @("1", 1) }
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
            steps        = 4
            cfg          = 1.0
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
        inputs     = @{ images = @("6", 0); filename_prefix = "flux_test" }
    }
}

$body = @{ prompt = $workflow } | ConvertTo-Json -Depth 10 -Compress

# 4. Enviar workflow
Write-Host "[3] Enviando workflow a /prompt..." -ForegroundColor Yellow
try {
    $resp = Invoke-RestMethod -Uri "$comfyUrl/prompt" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 30
    $promptId = $resp.prompt_id
    Write-Host "    OK Prompt ID: $promptId" -ForegroundColor Green
} catch {
    Write-Host "    ERROR al enviar:" -ForegroundColor Red
    Write-Host "    $($_.Exception.Message)" -ForegroundColor Gray
    if ($_.ErrorDetails.Message) {
        Write-Host ""
        Write-Host "Respuesta del servidor:" -ForegroundColor Yellow
        Write-Host $_.ErrorDetails.Message -ForegroundColor Gray
        # Intentar parsear node_errors si viene en JSON
        try {
            $errJson = $_.ErrorDetails.Message | ConvertFrom-Json
            if ($errJson.node_errors) { Write-Host "Node errors: $($errJson.node_errors | ConvertTo-Json -Depth 5)" -ForegroundColor Red }
            if ($errJson.exception_message) { Write-Host "Exception: $($errJson.exception_message)" -ForegroundColor Red }
        } catch {}
    }
    Write-Host ""
    Write-Host "Tip: Revisa docker logs comfyui --tail 50" -ForegroundColor Yellow
    exit 1
}

# 5. Esperar resultado (Flux: primera carga ~60s, siguientes ~30-45s)
Write-Host "[4] Esperando generacion (Flux: 30-90s, primera vez puede tardar mas)..." -ForegroundColor Yellow
$maxWait = 300
$elapsed = 0
$outputDir = "$env:USERPROFILE\comfyui-output"

# Funcion: extraer entry del historial (soporta formato {promptId:entry} o {outputs,status} directo)
function Get-HistoryEntry {
    param($hist, $pid)
    if ($hist.PSObject.Properties.Name -contains $pid) {
        return $hist.$pid
    }
    # Formato alternativo: respuesta directa con outputs
    if ($hist.outputs -ne $null) {
        return $hist
    }
    return $null
}

# Funcion: buscar imagen en outputs y descargar
function Get-ImageFromOutputs {
    param($outputs)
    if (-not $outputs) { return $false }
    foreach ($nodeId in $outputs.PSObject.Properties.Name) {
        $nodeOut = $outputs.$nodeId
        if ($nodeOut.images -and $nodeOut.images.Count -gt 0) {
            $imgInfo = $nodeOut.images[0]
            $filename = $imgInfo.filename
            $subfolder = if ($imgInfo.subfolder) { $imgInfo.subfolder } else { "" }
            $imgType = if ($imgInfo.type) { $imgInfo.type } else { "output" }

            $viewParams = "filename=$filename&type=$imgType"
            if ($subfolder) { $viewParams += "&subfolder=$subfolder" }
            $viewUrl = "$comfyUrl/view?$viewParams"

            Write-Host "[5] Descargando imagen via API..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri $viewUrl -OutFile $outFile -UseBasicParsing -TimeoutSec 60
            return $true
        }
    }
    return $false
}

while ($elapsed -lt $maxWait) {
    Start-Sleep -Seconds 2
    $elapsed += 2
    Write-Host "    ... $elapsed s" -ForegroundColor Gray

    try {
        # Intentar /history/{prompt_id}
        $hist = Invoke-RestMethod -Uri "$comfyUrl/history/$promptId" -Method GET -TimeoutSec 10
        if ($Debug -and $elapsed -eq 3) {
            $hist | ConvertTo-Json -Depth 5 | Out-File "$env:TEMP\comfyui_flux_history_debug.json" -Encoding utf8
        }
        $entry = Get-HistoryEntry -hist $hist -pid $promptId

        if ($entry) {
            # Revisar si hubo error
            if ($entry.status -and $entry.status.status_str -eq "error") {
                Write-Host ""
                Write-Host "ERROR en ComfyUI:" -ForegroundColor Red
                Write-Host ($entry | ConvertTo-Json -Depth 5) -ForegroundColor Gray
                exit 1
            }

            if (Get-ImageFromOutputs -outputs $entry.outputs) {
                Write-Host ""
                Write-Host "OK - Imagen guardada en: $outFile" -ForegroundColor Green
                Write-Host "Abre el archivo para verla." -ForegroundColor Cyan
                exit 0
            }
        }

        # Durante la espera: revisar si ya se guardo en output (ComfyUI puede guardar antes de actualizar history)
        $fluxNew = @(Get-ChildItem $outputDir -Filter "flux_test_*.png" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1)
        if ($fluxNew.Count -gt 0 -and ($fluxNew[0].LastWriteTime -gt (Get-Date).AddSeconds(-$elapsed - 10))) {
            Copy-Item $fluxNew[0].FullName -Destination $outFile -Force
            Write-Host "[5] Imagen detectada en output (ComfyUI guardo antes de que la API respondiera)" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "OK - Imagen guardada en: $outFile" -ForegroundColor Green
            exit 0
        }

        # Fallback: buscar en /history (lista completa) por si el formato es distinto
        if ($elapsed -ge 45) {
            $histAll = Invoke-RestMethod -Uri "$comfyUrl/history" -Method GET -TimeoutSec 10
            if ($histAll -and $histAll.PSObject.Properties.Name -contains $promptId) {
                $entry = $histAll.$promptId
                if ($entry -and (Get-ImageFromOutputs -outputs $entry.outputs)) {
                    Write-Host ""
                    Write-Host "OK - Imagen guardada en: $outFile (via /history)" -ForegroundColor Green
                    exit 0
                }
            }
        }
    } catch {
        # Seguir intentando
    }
}

# Fallback final: buscar flux_test_*.png en carpeta de output de ComfyUI
Write-Host ""
Write-Host "    Buscando imagen en carpeta de output..." -ForegroundColor Gray
$fluxImages = Get-ChildItem $outputDir -Filter "flux_test_*.png" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
if ($fluxImages) {
    $latest = $fluxImages[0]
    $ageSec = (Get-Date) - $latest.LastWriteTime | ForEach-Object { $_.TotalSeconds }
    if ($ageSec -lt ($maxWait + 30)) {
        Copy-Item $latest.FullName -Destination $outFile -Force
        Write-Host "OK - Imagen encontrada en output, copiada a: $outFile" -ForegroundColor Green
        Write-Host "  (La API no devolvio el resultado a tiempo, pero ComfyUI guardo la imagen)" -ForegroundColor Gray
        exit 0
    }
}

Write-Host ""
Write-Host "TIMEOUT: No se recibio imagen en $maxWait segundos." -ForegroundColor Red
Write-Host "Revisa: docker logs comfyui --tail 80" -ForegroundColor Yellow
exit 1
