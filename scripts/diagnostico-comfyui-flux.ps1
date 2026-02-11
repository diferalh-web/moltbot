# Diagnostico ComfyUI Flux - cuando ni web ni API generan imagenes
# Ejecuta: .\scripts\diagnostico-comfyui-flux.ps1

$comfyUrl = "http://localhost:7860"
$outDir = "${env:USERPROFILE}\comfyui-output"
$ckptDir = "${env:USERPROFILE}\comfyui-models\checkpoints"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Diagnostico ComfyUI + Flux" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. ComfyUI responde
Write-Host "[1] ComfyUI responde?" -ForegroundColor Yellow
try {
    $r = Invoke-WebRequest -Uri "$comfyUrl/object_info" -TimeoutSec 10 -UseBasicParsing
    Write-Host "    [OK] Si" -ForegroundColor Green
} catch {
    Write-Host "    [X] No - docker start comfyui" -ForegroundColor Red
    exit 1
}

# 2. Checkpoint Flux
Write-Host "[2] Checkpoint Flux en ComfyUI?" -ForegroundColor Yellow
$fluxCkpt = "flux1-schnell-fp8.safetensors"
$ckptPath = Join-Path $ckptDir $fluxCkpt
if (Test-Path $ckptPath) {
    $sizeMB = [math]::Round((Get-Item $ckptPath).Length / 1MB, 1)
    Write-Host "    [OK] $fluxCkpt existe ($sizeMB MB)" -ForegroundColor Green
} else {
    Write-Host "    [X] No encontrado en $ckptDir" -ForegroundColor Red
}
try {
    $objInfo = Invoke-RestMethod -Uri "$comfyUrl/object_info/CheckpointLoaderSimple" -TimeoutSec 10
    $list = $objInfo.CheckpointLoaderSimple.input.required.ckpt_name[0]
    if ($fluxCkpt -in $list) {
        Write-Host "    [OK] ComfyUI lo ve en la lista" -ForegroundColor Green
    } else {
        Write-Host "    [!] ComfyUI NO lo ve. Reinicia: docker restart comfyui" -ForegroundColor Yellow
        Write-Host "    Vistos: $($list -join ', ')" -ForegroundColor Gray
    }
} catch { Write-Host "    [!] No se pudo verificar object_info" -ForegroundColor Yellow }

# 3. Carpeta output
Write-Host "[3] Carpeta output escribible?" -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$testFile = Join-Path $outDir "_test_write_$(Get-Random).tmp"
try {
    "test" | Out-File $testFile -Encoding utf8
    Remove-Item $testFile -Force
    Write-Host "    [OK] Si" -ForegroundColor Green
} catch {
    Write-Host "    [X] No - revisa permisos de $outDir" -ForegroundColor Red
}

# 4. Cola actual
Write-Host "[4] Estado de la cola?" -ForegroundColor Yellow
try {
    $queue = Invoke-RestMethod -Uri "$comfyUrl/queue" -Method GET -TimeoutSec 5
    $running = if ($queue.queue_running) { $queue.queue_running.Count } else { 0 }
    $pending = if ($queue.queue_pending) { $queue.queue_pending.Count } else { 0 }
    Write-Host "    Ejecutando: $running, Pendientes: $pending" -ForegroundColor Gray
    if ($running -gt 0 -or $pending -gt 5) {
        Write-Host "    [!] Cola cargada - prueba: Invoke-RestMethod -Uri '$comfyUrl/queue' -Method POST -Body '{\"clear\":true}' -ContentType 'application/json'" -ForegroundColor Yellow
    }
} catch { Write-Host "    [!] No se pudo leer cola" -ForegroundColor Yellow }

# 5. Probar SD 1.5 primero (menos VRAM - si falla Flux pero SD funciona, es tema de memoria)
$sd15Ckpt = "v1-5-pruned-emaonly.safetensors"
$testCkpt = $fluxCkpt
if (Test-Path (Join-Path $ckptDir $sd15Ckpt)) {
    Write-Host "[5a] Probando SD 1.5 primero (256x256, ~2GB VRAM)..." -ForegroundColor Yellow
    $testCkpt = $sd15Ckpt
} else {
    Write-Host "[5] Workflow Flux (256x256)..." -ForegroundColor Yellow
}

# Limpiar cola primero (NO interrupt - solo clear para evitar matar ejecucion)
try {
    Invoke-RestMethod -Uri "$comfyUrl/queue" -Method POST -Body '{"clear":true}' -ContentType "application/json" -TimeoutSec 5 | Out-Null
    Start-Sleep -Seconds 2
} catch {}

$isFlux = $testCkpt -like "*flux*"
$steps = if ($isFlux) { 4 } else { 20 }
$cfgVal = if ($isFlux) { 1 } else { 7.5 }

$workflow = @{
    "1" = @{ class_type = "CheckpointLoaderSimple"; inputs = @{ ckpt_name = $testCkpt } }
    "2" = @{ class_type = "CLIPTextEncode"; inputs = @{ text = "a red apple"; clip = @("1", 1) } }
    "3" = @{ class_type = "CLIPTextEncode"; inputs = @{ text = "blurry, low quality"; clip = @("1", 1) } }
    "4" = @{ class_type = "EmptyLatentImage"; inputs = @{ width = 256; height = 256; batch_size = 1 } }
    "5" = @{ class_type = "KSampler"; inputs = @{ model = @("1", 0); positive = @("2", 0); negative = @("3", 0); latent_image = @("4", 0); seed = 12345; steps = $steps; cfg = $cfgVal; sampler_name = "euler"; scheduler = "simple"; denoise = 1 } }
    "6" = @{ class_type = "VAEDecode"; inputs = @{ samples = @("5", 0); vae = @("1", 2) } }
    "7" = @{ class_type = "SaveImage"; inputs = @{ images = @("6", 0); filename_prefix = "diag_test" } }
}
$body = @{ prompt = $workflow } | ConvertTo-Json -Depth 10 -Compress

try {
    $resp = Invoke-RestMethod -Uri "$comfyUrl/prompt" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 30
    $promptId = $resp.prompt_id
    Write-Host "    Prompt ID: $promptId | Modelo: $testCkpt" -ForegroundColor Gray
    Write-Host "    Esperando 90s..." -ForegroundColor Gray
    
    $found = $false
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Seconds 3
        $new = Get-ChildItem $outDir -Filter "diag_test_*.png" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($new -and $new.LastWriteTime -gt (Get-Date).AddSeconds(-100)) {
            Write-Host "    [OK] Imagen generada: $($new.FullName)" -ForegroundColor Green
            $found = $true
            break
        }
        Write-Host "    ... $((($i+1)*3))s" -ForegroundColor DarkGray
    }
    if (-not $found) {
        Write-Host "    [X] No se genero imagen en 90s" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Ejecuta en otra terminal DURANTE el proximo intento:" -ForegroundColor Yellow
        Write-Host "    docker logs comfyui -f" -ForegroundColor White
        Write-Host "  Busca: Traceback, Error, exception, OOM, killed" -ForegroundColor Gray
    }
} catch {
    Write-Host "    [X] Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) { Write-Host "    $($_.ErrorDetails.Message)" -ForegroundColor Gray }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Fin diagnostico" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
