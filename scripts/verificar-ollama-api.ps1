# Script para verificar la API de Ollama
Write-Host "Verificando API de Ollama..." -ForegroundColor Cyan
Write-Host ""

# Probar API estándar
Write-Host "[1] Probando API estandar /api/tags..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:11438/api/tags" -UseBasicParsing -TimeoutSec 5
    $json = $response.Content | ConvertFrom-Json
    Write-Host "  [OK] API responde" -ForegroundColor Green
    Write-Host "  Modelos:" -ForegroundColor Gray
    foreach ($model in $json.models) {
        Write-Host ("    - " + $model.name) -ForegroundColor White
    }
} catch {
    Write-Host "  [X] Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Probar /v1/models (OpenAI compatible)
Write-Host "[2] Probando /v1/models (OpenAI compatible)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:11438/v1/models" -UseBasicParsing -TimeoutSec 5
    Write-Host "  [OK] /v1/models responde" -ForegroundColor Green
    Write-Host "  Respuesta:" -ForegroundColor Gray
    Write-Host $response.Content -ForegroundColor White
} catch {
    Write-Host "  [!] /v1/models no responde (puede ser normal)" -ForegroundColor Yellow
    Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Gray
}
Write-Host ""

# Probar generación directa
Write-Host "[3] Probando generacion directa..." -ForegroundColor Yellow
try {
    $body = @{
        model = "deepseek-coder:33b"
        prompt = "test"
        stream = $false
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "http://localhost:11438/api/generate" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing -TimeoutSec 10
    Write-Host "  [OK] Generacion funciona" -ForegroundColor Green
} catch {
    Write-Host "  [!] Error en generacion: $($_.Exception.Message)" -ForegroundColor Yellow
}
Write-Host ""


