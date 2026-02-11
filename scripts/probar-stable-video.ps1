# Prueba Stable Video Diffusion
# Envia una imagen y genera un video corto
# Uso: .\scripts\probar-stable-video.ps1 [-ImagePath "ruta\imagen.png"] [-Duration 5] [-Fps 24]

param(
    [string]$ImagePath = "",
    [int]$Duration = 5,
    [int]$Fps = 7   # SVD genera 14-25 frames; fps=7 da ~3.5s de video
)

$videoUrl = "http://localhost:8000"
$outFile = "$env:TEMP\stable_video_test.mp4"
$maxPollWait = 600  # 10 min para generacion de video

Write-Host ""
Write-Host "=== Prueba Stable Video Diffusion ===" -ForegroundColor Cyan
Write-Host "  URL: $videoUrl" -ForegroundColor Gray
Write-Host "  Duracion: $Duration s, FPS: $Fps" -ForegroundColor Gray
Write-Host ""

# Resolver imagen de entrada
if ($ImagePath -and (Test-Path $ImagePath)) {
    $imgFile = $ImagePath
} else {
    # Buscar imagen de prueba
    $outPng = Get-ChildItem "$env:USERPROFILE\comfyui-output" -Filter "*.png" -ErrorAction SilentlyContinue | Select-Object -First 1
    $modelsPng = Get-ChildItem "$env:USERPROFILE\comfyui-models" -Recurse -Filter "*.png" -ErrorAction SilentlyContinue | Select-Object -First 1
    $candidates = @(
        "$env:TEMP\comfyui_flux_test.png",
        "$env:TEMP\comfyui_test.png"
    )
    if ($outPng) { $candidates += $outPng.FullName }
    if ($modelsPng) { $candidates += $modelsPng.FullName }
    $imgFile = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
}

if (-not $imgFile -or -not (Test-Path $imgFile)) {
    Write-Host "[X] No se encontro imagen de prueba" -ForegroundColor Red
    Write-Host "    Proporciona una con: .\probar-stable-video.ps1 -ImagePath 'ruta\imagen.png'" -ForegroundColor White
    Write-Host ""
    Write-Host "    O genera una primero con: .\scripts\probar-flux-comfyui.ps1" -ForegroundColor Gray
    Write-Host "    (guardara en %TEMP%\comfyui_flux_test.png)" -ForegroundColor Gray
    exit 1
}

Write-Host "[1] Imagen de entrada: $imgFile" -ForegroundColor Green
Write-Host ""

# 1. Verificar health
Write-Host "[2] Verificando Stable Video..." -ForegroundColor Yellow
try {
    $r = Invoke-RestMethod -Uri "$videoUrl/health" -TimeoutSec 15
    Write-Host "    OK $($r.service)" -ForegroundColor Green
} catch {
    Write-Host "    ERROR: No responde en $videoUrl" -ForegroundColor Red
    Write-Host "    Detalle: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "    Levanta el servicio: docker compose -f docker-compose-unified.yml up -d stable-video" -ForegroundColor White
    exit 1
}

# 2. Enviar imagen y generar video
Write-Host "[3] Enviando imagen (puede tardar varios minutos)..." -ForegroundColor Yellow
try {
    # Usar curl.exe para multipart (PowerShell 5.1 no tiene -Form en Invoke-RestMethod)
    $imgPath = (Resolve-Path $imgFile).Path -replace '\\', '/'
    $json = & curl.exe -s -S -X POST `
        -F "file=@$imgPath" `
        -F "duration=$Duration" `
        -F "fps=$Fps" `
        "$videoUrl/api/generate" 2>&1
    $resp = $json | ConvertFrom-Json

    if ($resp.video_url) {
        Write-Host "    OK Video listo (URL directa)" -ForegroundColor Green
        $videoUri = $resp.video_url
        if ($videoUri -notmatch "^https?://") {
            $videoUri = "$videoUrl$videoUri"
        }
        Write-Host "[4] Descargando video..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $videoUri -OutFile $outFile -UseBasicParsing -TimeoutSec 120
        Write-Host ""
        Write-Host "OK - Video guardado en: $outFile" -ForegroundColor Green
        exit 0
    }
    elseif ($resp.job_id) {
        Write-Host "    OK Job ID: $($resp.job_id)" -ForegroundColor Green
        $jobId = $resp.job_id

        Write-Host "[4] Esperando generacion (poll cada 10s, max $($maxPollWait/60) min)..." -ForegroundColor Yellow
        $elapsed = 0
        while ($elapsed -lt $maxPollWait) {
            Start-Sleep -Seconds 10
            $elapsed += 10
            Write-Host "    ... $elapsed s" -ForegroundColor Gray

            $status = Invoke-RestMethod -Uri "$videoUrl/api/status/$jobId" -TimeoutSec 30
            if ($status.video_url) {
                $videoUri = $status.video_url
                if ($videoUri -notmatch "^https?://") {
                    $videoUri = "$videoUrl$videoUri"
                }
                Write-Host "    OK Video listo" -ForegroundColor Green
                Invoke-WebRequest -Uri $videoUri -OutFile $outFile -UseBasicParsing -TimeoutSec 120
                Write-Host ""
                Write-Host "OK - Video guardado en: $outFile" -ForegroundColor Green
                exit 0
            }
            if ($status.status -eq "error" -or $status.error) {
                Write-Host "    ERROR: $($status.error)" -ForegroundColor Red
                exit 1
            }
        }
        Write-Host ""
        Write-Host "TIMEOUT: No se recibio video en $($maxPollWait/60) minutos." -ForegroundColor Red
        exit 1
    }
    else {
        Write-Host "    Respuesta:" -ForegroundColor Yellow
        Write-Host ($resp | ConvertTo-Json) -ForegroundColor Gray
        Write-Host ""
        if ($resp.message -match "placeholder|pending|Implementation pending") {
            Write-Host "[!] La API esta en modo placeholder." -ForegroundColor Yellow
            Write-Host "    El servicio responde pero no genera video aun." -ForegroundColor Gray
            Write-Host "    Ver IMPLEMENTAR_STABLE_VIDEO.md para integrar el modelo completo." -ForegroundColor Gray
        }
        exit 0
    }
} catch {
    Write-Host "    ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "    $($_.ErrorDetails.Message)" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "    Revisa: docker logs stable-video --tail 50" -ForegroundColor Yellow
    exit 1
}
