# Script para ejecutar pruebas de ComfyUI
# Modos: -Flux (imagen via API), -LTX2 (video desde workflow en UI)
# Uso: .\scripts\probar-comfyui-test.ps1 [-Flux] [-LTX2] [-Prompt "texto"] [-ClearQueue] [-Debug]

param(
    [switch]$Flux,
    [switch]$LTX2,
    [switch]$SD15,
    [string]$Prompt = "",
    [switch]$ClearQueue,
    [switch]$Debug
)

$comfyUrl = "http://localhost:7860"
$workflowsDir = Join-Path (Split-Path $PSScriptRoot -Parent) "workflows"
$outDir = "${env:USERPROFILE}\comfyui-output"

# Si no se especifica, probar SD15 por defecto (Flux puede causar crash en 12GB VRAM)
if (-not $Flux -and -not $LTX2 -and -not $SD15) { $SD15 = $true }

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "ComfyUI - Prueba de Workflows" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar ComfyUI
Write-Host "[1] Verificando ComfyUI en $comfyUrl..." -ForegroundColor Yellow
try {
    $r = Invoke-WebRequest -Uri "$comfyUrl/object_info" -TimeoutSec 15 -UseBasicParsing
    if ($r.StatusCode -ne 200) { throw "Status $($r.StatusCode)" }
    Write-Host "    [OK] ComfyUI responde" -ForegroundColor Green
} catch {
    Write-Host "    [X] ComfyUI no responde. Ejecuta: docker start comfyui" -ForegroundColor Red
    exit 1
}
Write-Host ""

if ($SD15) {
    # --- Test SD 1.5 (imagen) via API - funciona en 12GB VRAM ---
    Write-Host "[2] Ejecutando test SD 1.5 (imagen)..." -ForegroundColor Yellow
    $ckpt = "v1-5-pruned-emaonly.safetensors"
    $workflow = @{
        "1" = @{ class_type = "CheckpointLoaderSimple"; inputs = @{ ckpt_name = $ckpt } }
        "2" = @{ class_type = "CLIPTextEncode"; inputs = @{ text = if ($Prompt) { $Prompt } else { "a red apple" }; clip = @("1", 1) } }
        "3" = @{ class_type = "CLIPTextEncode"; inputs = @{ text = "blurry, low quality"; clip = @("1", 1) } }
        "4" = @{ class_type = "EmptyLatentImage"; inputs = @{ width = 512; height = 512; batch_size = 1 } }
        "5" = @{ class_type = "KSampler"; inputs = @{ model = @("1", 0); positive = @("2", 0); negative = @("3", 0); latent_image = @("4", 0); seed = (Get-Random -Min 1 -Max 999999999); steps = 20; cfg = 7.5; sampler_name = "euler"; scheduler = "simple"; denoise = 1 } }
        "6" = @{ class_type = "VAEDecode"; inputs = @{ samples = @("5", 0); vae = @("1", 2) } }
        "7" = @{ class_type = "SaveImage"; inputs = @{ images = @("6", 0); filename_prefix = "comfyui_sd15_test" } }
    }
    $body = @{ prompt = $workflow } | ConvertTo-Json -Depth 10 -Compress
    try {
        $resp = Invoke-RestMethod -Uri "$comfyUrl/prompt" -Method POST -Body $body -ContentType "application/json"
        $promptId = $resp.prompt_id
        Write-Host "    Prompt ID: $promptId" -ForegroundColor Gray
    } catch {
        Write-Host "    [X] Error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
    $maxWait = 90
    $elapsed = 0
    $outFile = Join-Path $outDir "comfyui_sd15_test_$($resp.prompt_id).png"
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    $startTime = Get-Date
    $existingMaxTime = (Get-ChildItem $outDir -Filter "comfyui_sd15_test_*.png" -EA 0 | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime
    if (-not $existingMaxTime) { $existingMaxTime = [datetime]::MinValue }
    Write-Host "[3] Esperando generacion (15-45s)..." -ForegroundColor Yellow
    while ($elapsed -lt $maxWait) {
        Start-Sleep -Seconds 3
        $elapsed += 3
        Write-Host "    ... $elapsed s" -ForegroundColor Gray
        $recent = Get-ChildItem $outDir -Filter "comfyui_sd15_test_*.png" -EA 0 | Where-Object { $_.LastWriteTime -gt $existingMaxTime } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($recent) {
            Copy-Item $recent.FullName -Destination $outFile -Force
            Write-Host ""
            Write-Host "[OK] Imagen guardada: $outFile" -ForegroundColor Green
            exit 0
        }
    }
    Write-Host ""
    Write-Host "[X] Timeout" -ForegroundColor Red
    exit 1
}

if ($Flux) {
    # --- Test Flux (imagen) via API - puede causar crash en 12GB VRAM ---
    if ($ClearQueue) {
        Write-Host "[2a] Limpiando cola de ComfyUI..." -ForegroundColor Yellow
        try {
            Invoke-RestMethod -Uri "$comfyUrl/interrupt" -Method POST -Body '{}' -ContentType "application/json" -TimeoutSec 5 | Out-Null
            Start-Sleep -Seconds 2
            Invoke-RestMethod -Uri "$comfyUrl/queue" -Method POST -Body '{"clear":true}' -ContentType "application/json" -TimeoutSec 5 | Out-Null
            Write-Host "    [OK] Cola limpiada" -ForegroundColor Green
        } catch { Write-Host "    [!] No se pudo limpiar: $($_.Exception.Message)" -ForegroundColor Yellow }
    }
    Write-Host "[2] Ejecutando test Flux (imagen)..." -ForegroundColor Yellow

    $fluxWorkflowPath = Join-Path $workflowsDir "comfyui_test_flux_api.json"
    if (-not (Test-Path $fluxWorkflowPath)) {
        Write-Host "    [X] No existe: $fluxWorkflowPath" -ForegroundColor Red
        exit 1
    }

    # Detectar checkpoint Flux disponible
    $ckptDir = "${env:USERPROFILE}\comfyui-models\checkpoints"
    $fluxCkpt = $null
    if (Test-Path $ckptDir) {
        $ckpts = Get-ChildItem $ckptDir -Filter "*.safetensors" -ErrorAction SilentlyContinue
        $fluxCkpt = ($ckpts | Where-Object { $_.Name -like "*flux*" } | Select-Object -First 1).Name
    }
    if (-not $fluxCkpt) { $fluxCkpt = "flux1-schnell-fp8.safetensors" }
    Write-Host "    Checkpoint: $fluxCkpt" -ForegroundColor Gray

    $workflow = Get-Content $fluxWorkflowPath -Raw | ConvertFrom-Json
    $workflow.'4'.inputs.ckpt_name = $fluxCkpt
    if ($Prompt) { $workflow.'6'.inputs.text = $Prompt }
    $workflow.'3'.inputs.seed = (Get-Random -Minimum 1 -Maximum 999999999)

    $body = @{ prompt = $workflow } | ConvertTo-Json -Depth 15 -Compress

    try {
        $resp = Invoke-RestMethod -Uri "$comfyUrl/prompt" -Method POST -Body $body -ContentType "application/json"
        $promptId = $resp.prompt_id
        Write-Host "    Prompt ID: $promptId" -ForegroundColor Gray
    } catch {
        Write-Host "    [X] Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.ErrorDetails.Message) { Write-Host "    $($_.ErrorDetails.Message)" -ForegroundColor Gray }
        exit 1
    }

    Write-Host "[3] Esperando generacion (30-90s)..." -ForegroundColor Yellow
    $maxWait = 120
    $elapsed = 0
    $outFile = Join-Path $outDir "comfyui_test_$promptId.png"
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null

    # Tiempo antes de enviar (para detectar imagenes nuevas)
    $startTime = Get-Date
    $existingFiles = @(Get-ChildItem $outDir -Filter "comfyui_test_*.png" -ErrorAction SilentlyContinue)
    $existingMaxTime = if ($existingFiles.Count -gt 0) { ($existingFiles | Sort-Object LastWriteTime -Descending)[0].LastWriteTime } else { [datetime]::MinValue }

    function Get-ImageFromHistory {
        param($hist, $pid)
        if (-not $hist -or -not $hist.PSObject.Properties.Name) { return $null }
        $entry = $null
        if ($hist.PSObject.Properties.Name -contains $pid) { $entry = $hist.$pid }
        if (-not $entry) { return $null }
        # Detectar error de ejecucion
        if ($entry.status -and $entry.status.status_str -eq "error") { return "ERROR" }
        if (-not $entry.outputs) { return $null }
        foreach ($nodeId in $entry.outputs.PSObject.Properties.Name) {
            $nodeOut = $entry.outputs.$nodeId
            if ($nodeOut.images -and $nodeOut.images.Count -gt 0) {
                $imgInfo = $nodeOut.images[0]
                $fn = $imgInfo.filename
                $sub = if ($imgInfo.subfolder) { $imgInfo.subfolder } else { "" }
                $typ = if ($imgInfo.type) { $imgInfo.type } else { "output" }
                return @{ filename = $fn; subfolder = $sub; type = $typ }
            }
        }
        return $null
    }

    while ($elapsed -lt $maxWait) {
        Start-Sleep -Seconds 3
        $elapsed += 3
        Write-Host "    ... $elapsed s" -ForegroundColor Gray

        try {
            $hist = Invoke-RestMethod -Uri "$comfyUrl/history/$promptId" -Method GET -TimeoutSec 10
            if ($Debug -and $elapsed -eq 3) {
                $hist | ConvertTo-Json -Depth 8 | Out-File "$env:TEMP\comfyui_history_debug.json" -Encoding utf8
                Write-Host "    [Debug] history guardado en $env:TEMP\comfyui_history_debug.json" -ForegroundColor Gray
            }
            $imgData = Get-ImageFromHistory -hist $hist -pid $promptId
            if ($imgData -eq "ERROR") {
                Write-Host ""
                Write-Host "[X] ComfyUI reporto error en la ejecucion:" -ForegroundColor Red
                Write-Host ($hist.$promptId | ConvertTo-Json -Depth 5) -ForegroundColor Gray
                exit 1
            }
            if ($imgData) {
                $viewParams = "filename=$($imgData.filename)&type=$($imgData.type)"
                if ($imgData.subfolder) { $viewParams += "&subfolder=$($imgData.subfolder)" }
                Invoke-WebRequest -Uri "$comfyUrl/view?$viewParams" -OutFile $outFile -UseBasicParsing -TimeoutSec 30
                Write-Host ""
                Write-Host "[OK] Imagen guardada: $outFile" -ForegroundColor Green
                exit 0
            }

            # Fallback: ComfyUI guarda en output (ComfyUI 0.13+ history suele devolver {})
            $recent = @(Get-ChildItem $outDir -Filter "comfyui_test_*.png" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt $existingMaxTime } | Sort-Object LastWriteTime -Descending | Select-Object -First 1)
            if ($recent.Count -gt 0) {
                Copy-Item $recent[0].FullName -Destination $outFile -Force
                Write-Host ""
                Write-Host "[OK] Imagen detectada en output: $outFile" -ForegroundColor Green
                exit 0
            }

            # Fallback: /history completo (por si el formato de /history/$id cambio)
            if ($elapsed -ge 30) {
                $histAll = Invoke-RestMethod -Uri "$comfyUrl/history" -Method GET -TimeoutSec 10
                $imgData = Get-ImageFromHistory -hist $histAll -pid $promptId
                if ($imgData -and $imgData -ne "ERROR") {
                    $viewParams = "filename=$($imgData.filename)&type=$($imgData.type)"
                    if ($imgData.subfolder) { $viewParams += "&subfolder=$($imgData.subfolder)" }
                    Invoke-WebRequest -Uri "$comfyUrl/view?$viewParams" -OutFile $outFile -UseBasicParsing -TimeoutSec 30
                    Write-Host ""
                    Write-Host "[OK] Imagen guardada (via /history): $outFile" -ForegroundColor Green
                    exit 0
                }
            }
        } catch { }
    }

    # Fallback final: imagen nueva en output (history de ComfyUI 0.13+ suele devolver {})
    Write-Host ""
    Write-Host "    Buscando imagen nueva en output..." -ForegroundColor Gray
    $saved = @(Get-ChildItem $outDir -Filter "comfyui_test_*.png" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt $existingMaxTime } | Sort-Object LastWriteTime -Descending)
    if ($saved.Count -gt 0) {
        Copy-Item $saved[0].FullName -Destination $outFile -Force
        Write-Host "[OK] Imagen encontrada: $outFile" -ForegroundColor Green
        Write-Host "  (ComfyUI guarda en output; la API /history suele devolver vacio en v0.13+)" -ForegroundColor Gray
        exit 0
    }

    Write-Host ""
    Write-Host "[X] Timeout - No se recibio imagen" -ForegroundColor Red
    Write-Host "    Sugerencias:" -ForegroundColor Yellow
    Write-Host "    - Usa -ClearQueue para vaciar la cola antes de ejecutar" -ForegroundColor Gray
    Write-Host "    - Revisa docker logs comfyui (errores de modelo/workflow)" -ForegroundColor Gray
    Write-Host "    - Ejecuta con -Debug para ver la respuesta de /history" -ForegroundColor Gray
    exit 1
}

if ($LTX2) {
    # --- Test LTX-2 (video) - Cargar workflow en UI ---
    Write-Host "[2] Preparando test LTX-2 (video)..." -ForegroundColor Yellow

    $ltx2WorkflowPath = Join-Path $workflowsDir "ltx2_test_simple.json"
    if (-not (Test-Path $ltx2WorkflowPath)) {
        Write-Host "    [X] No existe: $ltx2WorkflowPath" -ForegroundColor Red
        exit 1
    }

    # Copiar workflow a comfyui-input para facil acceso
    $inputWorkflow = Join-Path ${env:USERPROFILE} "comfyui-input\ltx2_test_simple.json"
    New-Item -ItemType Directory -Force -Path (Split-Path $inputWorkflow) | Out-Null
    Copy-Item $ltx2WorkflowPath $inputWorkflow -Force

    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "[OK] Workflow LTX-2 preparado" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Para ejecutar el test LTX-2:" -ForegroundColor Yellow
    Write-Host "  1. Abre ComfyUI: $comfyUrl" -ForegroundColor White
    Write-Host "  2. Arrastra el archivo a la interfaz:" -ForegroundColor White
    Write-Host "     $ltx2WorkflowPath" -ForegroundColor Gray
    Write-Host "  3. O: Workflow -> Browse Workflow Templates -> ComfyUI-LTXVideo" -ForegroundColor White
    Write-Host "     (usa LTX-2_T2V_Distilled_wLora y reduce resolucion a 576x320)" -ForegroundColor Gray
    Write-Host "  4. Haz clic en Run" -ForegroundColor White
    Write-Host ""
    Write-Host "El workflow de prueba usa 576x320 y ~3 segundos (optimizado para 12GB VRAM)" -ForegroundColor Gray
    Write-Host ""

    # Abrir ComfyUI en navegador
    Start-Process $comfyUrl
}
