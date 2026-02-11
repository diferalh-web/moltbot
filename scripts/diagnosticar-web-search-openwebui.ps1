# Diagnóstico: Búsqueda Web y Open WebUI
# Ejecutar en PowerShell desde c:\code\moltbot

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Diagnóstico: Búsqueda Web + Open WebUI" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Conectividad Open WebUI -> web-search
Write-Host "[1/5] Conectividad Open WebUI -> web-search" -ForegroundColor Yellow
$running = docker ps --filter "name=open-webui" --format "{{.Names}}" 2>$null
if ($running -eq "open-webui") {
    try {
        $result = docker exec open-webui curl -s -X POST http://web-search:5003/search `
            -H "Content-Type: application/json" `
            -d '{"query":"test IA","count":3}' 2>$null
        if ($result -and $result.Trim().Length -gt 2) {
            Write-Host "[OK] Open WebUI puede alcanzar web-search (respuesta recibida)" -ForegroundColor Green
        } else {
            Write-Host "[!] Respuesta vacía [] - puede ser timeout o DuckDuckGo sin resultados" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[X] Error: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "[SKIP] open-webui no está corriendo" -ForegroundColor Yellow
}
Write-Host ""

# 2. Red Docker
Write-Host "[2/5] Contenedores en red ai-network" -ForegroundColor Yellow
try {
    $out = docker network inspect ai-network --format "{{range .Containers}}{{.Name}} {{end}}" 2>$null
    if ($out -match "open-webui" -and $out -match "web-search") {
        Write-Host "[OK] open-webui y web-search están en ai-network" -ForegroundColor Green
    } else {
        Write-Host "[!] Contenedores: $out" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[!] No se pudo inspeccionar la red" -ForegroundColor Yellow
}
Write-Host ""

# 3. Prueba /api/search (desde host)
Write-Host "[3/5] Prueba /api/search desde host" -ForegroundColor Yellow
try {
    $resp = Invoke-RestMethod -Uri "http://localhost:5003/api/search" -Method POST `
        -ContentType "application/json" -Body '{"query":"noticias IA","max_results":2}' -UseBasicParsing -TimeoutSec 15
    if ($resp.success -and $resp.results) {
        Write-Host "[OK] /api/search devuelve $($resp.count) resultados" -ForegroundColor Green
    } else {
        Write-Host "[!] Sin resultados o error" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[X] Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 4. Variables de entorno de open-webui
Write-Host "[4/5] Variables Open WebUI (WEB_SEARCH, DRACO)" -ForegroundColor Yellow
$envOut = docker exec open-webui printenv 2>$null
$lines = $envOut -split "`n"
$relevant = $lines | Where-Object { $_ -match "WEB_SEARCH|DRACO" }
foreach ($line in $relevant) { Write-Host "     $line" -ForegroundColor Gray }
if (-not $relevant) { Write-Host "     (ninguna encontrada)" -ForegroundColor Gray }
Write-Host ""

# 5. Logs recientes
Write-Host "[5/5] Últimos logs Open WebUI (errores/search)" -ForegroundColor Yellow
$logs = docker logs open-webui --tail 80 2>&1
$searchLines = $logs | Select-String -Pattern "search|web.search|error|fail|refused|timeout" -CaseSensitive:$false
if ($searchLines) {
    $searchLines | Select-Object -First 8 | ForEach-Object { Write-Host "     $_" -ForegroundColor Gray }
} else {
    Write-Host "     Sin líneas relevantes en las últimas 80" -ForegroundColor Gray
}
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configuración recomendada (Admin Panel)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Web Search Engine: external" -ForegroundColor White
Write-Host "  External Search URL: http://web-search:5003/search" -ForegroundColor White
Write-Host "  API Key: opcional (o vacío)" -ForegroundColor White
Write-Host "  Result Count: 5 o más" -ForegroundColor White
Write-Host "  Activa 'Web Search' en cada mensaje (botón +)" -ForegroundColor Yellow
Write-Host ""
