# Script para agregar modelos Ollama a Open WebUI automáticamente
# Modifica la base de datos SQLite directamente

Write-Host "`n=== Agregando modelos Ollama a Open WebUI automáticamente ===" -ForegroundColor Cyan

# Verificar que Open WebUI esté corriendo
Write-Host "`n1. Verificando que Open WebUI esté corriendo..." -ForegroundColor Yellow
$webuiStatus = docker ps --filter "name=open-webui" --format "{{.Status}}"
if (-not $webuiStatus) {
    Write-Host "  ✗ Open WebUI no está corriendo" -ForegroundColor Red
    Write-Host "    Ejecuta: docker-compose -f docker-compose-extended.yml up -d open-webui" -ForegroundColor Yellow
    exit 1
}
Write-Host "  ✓ Open WebUI está corriendo" -ForegroundColor Green

Write-Host "`n2. Modificando base de datos de Open WebUI..." -ForegroundColor Yellow

# Copiar script Python al contenedor y ejecutarlo
$scriptPath = Join-Path $PSScriptRoot "modify_webui_db.py"
docker cp $scriptPath open-webui:/tmp/modify_webui_db.py
$result = docker exec open-webui python3 /tmp/modify_webui_db.py 2>&1

Write-Host $result

# Reiniciar Open WebUI para aplicar cambios
Write-Host "`n3. Reiniciando Open WebUI para aplicar cambios..." -ForegroundColor Yellow
docker restart open-webui

Write-Host "`n4. Esperando a que Open WebUI se reinicie..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Verificar que Open WebUI esté listo
$maxRetries = 30
$retry = 0
$ready = $false
while ($retry -lt $maxRetries -and -not $ready) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8082/api/version" -Method GET -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✓ Open WebUI está listo" -ForegroundColor Green
            $ready = $true
        }
    } catch {
        $retry++
        if ($retry -lt $maxRetries) {
            Start-Sleep -Seconds 2
        } else {
            Write-Host "  ⚠ Open WebUI puede tardar más en iniciar" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "`n✓ Base de datos modificada" -ForegroundColor Green
Write-Host "✓ Open WebUI reiniciado" -ForegroundColor Green
Write-Host "`nAhora accede a: http://localhost:8082" -ForegroundColor White
Write-Host "Los modelos deberían aparecer automáticamente en el selector." -ForegroundColor White
Write-Host "`nSi aún no ves los modelos, recarga la página (F5) y verifica en Settings → Connections" -ForegroundColor Yellow

