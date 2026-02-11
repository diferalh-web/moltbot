# Prueba de integración: Web Search + Open WebUI (sin depender de Draco)
# Ejecutar desde c:\code\moltbot

$ErrorActionPreference = "Stop"
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Prueba integración Web Search" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Servicio web-search
Write-Host "[1/4] Servicio web-search (puerto 5003)" -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:5003/health" -TimeoutSec 5 -UseBasicParsing
    Write-Host "  [OK] web-search: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "  [X] web-search no responde: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Búsqueda directa (/api/search)
Write-Host ""
Write-Host "[2/4] Búsqueda directa POST /api/search" -ForegroundColor Yellow
try {
    $search = Invoke-RestMethod -Uri "http://localhost:5003/api/search" -Method POST `
        -ContentType "application/json" `
        -Body '{"query":"noticias IA 2025","max_results":2}' `
        -TimeoutSec 15 -UseBasicParsing
    if ($search.success -and $search.results) {
        Write-Host "  [OK] $($search.count) resultados" -ForegroundColor Green
        Write-Host "       Ejemplo: $($search.results[0].title)" -ForegroundColor Gray
    } else {
        Write-Host "  [!] Sin resultados" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [X] Error: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Endpoint Open WebUI (/search)
Write-Host ""
Write-Host "[3/4] Endpoint Open WebUI POST /search" -ForegroundColor Yellow
try {
    $owu = Invoke-RestMethod -Uri "http://localhost:5003/search" -Method POST `
        -ContentType "application/json" `
        -Body '{"query":"noticias IA","count":2}' `
        -TimeoutSec 20 -UseBasicParsing
    if ($owu -is [array] -and $owu.Count -gt 0) {
        Write-Host "  [OK] $($owu.Count) resultados (formato Open WebUI)" -ForegroundColor Green
    } else {
        Write-Host "  [!] Array vacío o sin resultados" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [X] Error: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Desde contenedor open-webui (como cuando Open WebUI llama al servicio)
Write-Host ""
Write-Host "[4/4] Llamada desde open-webui -> web-search" -ForegroundColor Yellow
$running = docker ps --filter "name=open-webui" --format "{{.Names}}" 2>$null
if ($running -eq "open-webui") {
    try {
        $fromWebui = docker exec open-webui curl -s -X POST http://web-search:5003/api/search `
            -H "Content-Type: application/json" `
            -d '{"query":"test","max_results":2}' 2>$null
        if ($fromWebui -and $fromWebui.Length -gt 20) {
            $parsed = $fromWebui | ConvertFrom-Json
            if ($parsed.success) {
                Write-Host "  [OK] open-webui alcanza web-search: $($parsed.count) resultados" -ForegroundColor Green
            } else {
                Write-Host "  [!] Respuesta sin success" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  [!] Respuesta vacía o corta (DuckDuckGo puede devolver [] a veces)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  [X] $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "  [SKIP] open-webui no está corriendo" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Resumen" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  - Las tools web_search y search_and_summarize llaman a web-search DIRECTAMENTE (sin Draco)." -ForegroundColor White
Write-Host "  - Reinicia open-webui para cargar el cambio: docker restart open-webui" -ForegroundColor Yellow
Write-Host "  - En el chat: activa Web Search (botón +) o usa un modelo con la tool web_search habilitada." -ForegroundColor White
Write-Host ""
