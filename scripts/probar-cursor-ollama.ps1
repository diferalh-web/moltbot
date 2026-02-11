# Script para probar la conexión de Cursor con Ollama
# Ejecutar en PowerShell

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Probar Conexion Cursor - Ollama" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar contenedor
Write-Host "[1/4] Verificando contenedor ollama-code..." -ForegroundColor Yellow
$container = docker ps --filter "name=ollama-code" --format "{{.Names}}" 2>$null
if ($container -eq "ollama-code") {
    Write-Host "  [OK] Contenedor corriendo" -ForegroundColor Green
} else {
    Write-Host "  [X] Contenedor no esta corriendo" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Probar API estándar
Write-Host "[2/4] Probando API estandar de Ollama..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:11438/api/tags" -UseBasicParsing -TimeoutSec 5
    Write-Host "  [OK] API estandar responde" -ForegroundColor Green
    $models = ($response.Content | ConvertFrom-Json).models
    Write-Host "  Modelos disponibles:" -ForegroundColor Gray
    foreach ($model in $models) {
        Write-Host ("    - " + $model.name) -ForegroundColor White
    }
} catch {
    Write-Host "  [X] Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Probar API compatible con OpenAI (/v1)
Write-Host "[3/4] Probando API compatible con OpenAI (/v1)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:11438/v1/models" -UseBasicParsing -TimeoutSec 5
    Write-Host "  [OK] API /v1 responde" -ForegroundColor Green
    $json = $response.Content | ConvertFrom-Json
    if ($json.data) {
        Write-Host ("  Modelos encontrados: " + $json.data.Count) -ForegroundColor Gray
        foreach ($model in $json.data) {
            Write-Host ("    - " + $model.id) -ForegroundColor White
        }
    }
} catch {
    Write-Host "  [!] API /v1 no responde (esto puede ser normal)" -ForegroundColor Yellow
    Write-Host "      Ollama puede requerir configuracion adicional para /v1" -ForegroundColor Gray
}
Write-Host ""

# Verificar configuración de Cursor
Write-Host "[4/4] Verificando configuracion de Cursor..." -ForegroundColor Yellow
$settingsPath = "$env:APPDATA\Cursor\User\settings.json"
if (Test-Path $settingsPath) {
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
    Write-Host "  Configuracion actual:" -ForegroundColor Gray
    if ($settings.'cursor.model') {
        Write-Host ("    Model: " + $settings.'cursor.model') -ForegroundColor White
    }
    if ($settings.'cursor.modelBaseUrl') {
        Write-Host ("    Base URL: " + $settings.'cursor.modelBaseUrl') -ForegroundColor White
    }
    if ($settings.'cursor.modelProvider') {
        Write-Host ("    Provider: " + $settings.'cursor.modelProvider') -ForegroundColor White
    }
} else {
    Write-Host "  [!] Archivo de configuracion no encontrado" -ForegroundColor Yellow
}
Write-Host ""

# Resumen
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Resumen" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Siguiente paso:" -ForegroundColor Yellow
Write-Host "  1. Reinicia Cursor completamente" -ForegroundColor White
Write-Host "  2. Abre el chat (Ctrl + L)" -ForegroundColor White
Write-Host "  3. Escribe una pregunta y verifica los logs:" -ForegroundColor White
Write-Host "     docker logs ollama-code --tail 20 -f" -ForegroundColor Gray
Write-Host ""
Write-Host "Nota: Los modelos pueden no aparecer en la lista," -ForegroundColor Yellow
Write-Host "      pero deberian funcionar si la configuracion es correcta." -ForegroundColor Yellow
Write-Host ""






