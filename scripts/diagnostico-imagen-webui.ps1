# Diagnostico: por que Open WebUI no genera imagen (solo texto)
Write-Host "`n=== Diagnostico generacion de imagenes ===" -ForegroundColor Cyan

# 1. ComfyUI accesible desde el host
Write-Host "`n[1] ComfyUI desde el host (puerto 7860)..." -ForegroundColor Yellow
try {
    $r = Invoke-WebRequest -Uri "http://localhost:7860/system_stats" -UseBasicParsing -TimeoutSec 5
    Write-Host "    OK ComfyUI responde" -ForegroundColor Green
} catch {
    Write-Host "    FALLO: $($_.Exception.Message)" -ForegroundColor Red
}

# 2. Open WebUI puede alcanzar ComfyUI (desde dentro del contenedor)
Write-Host "`n[2] Open WebUI alcanza ComfyUI (red Docker)..." -ForegroundColor Yellow
$curlTest = docker exec open-webui curl -s -o /dev/null -w "%{http_code}" http://comfyui:8188/system_stats 2>$null
if ($curlTest -eq "200") {
    Write-Host "    OK open-webui puede conectar a comfyui:8188" -ForegroundColor Green
} else {
    Write-Host "    FALLO o no 200 (codigo: $curlTest). ComfyUI debe estar en la misma red (ai-network)." -ForegroundColor Red
}

# 3. Probar el endpoint nativo de imagenes (POST /api/v1/images/generations)
#    NOTA: La extension /api/v1/multimedia/image/generate suele devolver 405 porque
#    Open WebUI no monta routers de extensiones por defecto. Usa el endpoint nativo.
Write-Host "`n[3] Endpoint nativo de imagenes (POST /api/v1/images/generations)..." -ForegroundColor Yellow
$jsonBody = '{"prompt":"un gato simple","model":"flux1-schnell.safetensors","n":1}'
try {
    $resp = Invoke-WebRequest -Uri "http://localhost:8082/api/v1/images/generations" `
        -Method POST -ContentType "application/json" -Body $jsonBody `
        -TimeoutSec 120 -UseBasicParsing
    if ($resp.StatusCode -eq 200) {
        $parsed = $resp.Content | ConvertFrom-Json
        if ($parsed -and $parsed[0].url) {
            Write-Host "    OK El endpoint nativo devolvio una imagen" -ForegroundColor Green
        } else {
            Write-Host "    Respuesta 200 pero sin URL de imagen: $($resp.Content.Substring(0, [Math]::Min(100, $resp.Content.Length)))..." -ForegroundColor Yellow
        }
    } else {
        Write-Host "    StatusCode=$($resp.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 401) {
        Write-Host "    401 Unauthorized - Necesitas estar logueado. Prueba desde el chat con el icono de imagen." -ForegroundColor Yellow
    } elseif ($statusCode -eq 403) {
        Write-Host "    403 - Image Generation no activada o sin permiso. Revisa Settings > Images." -ForegroundColor Yellow
    } else {
        Write-Host "    FALLO: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 4. Red de contenedores
Write-Host "`n[4] Red de contenedores..." -ForegroundColor Yellow
$net = docker inspect comfyui --format "{{range .NetworkSettings.Networks}}{{.NetworkID}}{{end}}" 2>$null
$netWeb = docker inspect open-webui --format "{{range .NetworkSettings.Networks}}{{.NetworkID}}{{end}}" 2>$null
if ($net -and $netWeb -and $net -eq $netWeb) {
    Write-Host "    OK comfyui y open-webui en la misma red" -ForegroundColor Green
} else {
    Write-Host "    Comfyui y open-webui pueden estar en redes distintas" -ForegroundColor Yellow
}

Write-Host "`n=== Fin diagnostico ===" -ForegroundColor Cyan
Write-Host ""
