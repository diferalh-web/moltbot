# Script para agregar modelos Ollama a Open WebUI via API
# Este script agrega los backends de Ollama como "connections" en Open WebUI

Write-Host "`n=== Agregando modelos Ollama a Open WebUI via API ===" -ForegroundColor Cyan

$openWebUIUrl = "http://localhost:8082"
$apiUrl = "$openWebUIUrl/api/v1/configs/ollama"

# Esperar a que Open WebUI esté listo
Write-Host "`n1. Esperando a que Open WebUI esté listo..." -ForegroundColor Yellow
$maxRetries = 30
$retry = 0
do {
    try {
        $response = Invoke-WebRequest -Uri "$openWebUIUrl/api/version" -Method GET -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✓ Open WebUI está listo" -ForegroundColor Green
            break
        }
    } catch {
        $retry++
        if ($retry -lt $maxRetries) {
            Start-Sleep -Seconds 2
        } else {
            Write-Host "  ✗ Open WebUI no responde después de $($maxRetries * 2) segundos" -ForegroundColor Red
            exit 1
        }
    }
} while ($retry -lt $maxRetries)

# Configuraciones de los backends Ollama
$backends = @(
    @{
        Name = "Qwen"
        Url = "http://localhost:11437"
        Description = "Qwen 2.5 7B - Modelo general chino"
    },
    @{
        Name = "Code"
        Url = "http://localhost:11438"
        Description = "CodeLlama y DeepSeek-Coder - Modelos de programación"
    },
    @{
        Name = "Flux"
        Url = "http://localhost:11439"
        Description = "Flux - Generación de imágenes"
    }
)

Write-Host "`n2. Agregando backends Ollama..." -ForegroundColor Yellow

# NOTA: Open WebUI puede requerir autenticación para modificar configuraciones
# Por ahora, proporcionamos instrucciones manuales
Write-Host "`n=== INSTRUCCIONES MANUALES ===" -ForegroundColor Cyan
Write-Host "`nOpen WebUI requiere agregar los modelos manualmente desde la interfaz web:" -ForegroundColor Yellow
Write-Host "`n1. Accede a: $openWebUIUrl" -ForegroundColor White
Write-Host "2. Haz clic en el ícono de Configuración (⚙️) en la parte inferior izquierda" -ForegroundColor White
Write-Host "3. Ve a la sección 'Connections' o 'External Tools'" -ForegroundColor White
Write-Host "4. Haz clic en 'Add Connection' o '+' " -ForegroundColor White
Write-Host "5. Agrega cada backend con estos datos:" -ForegroundColor White
Write-Host "`n   Backend 1 - Qwen:" -ForegroundColor Cyan
Write-Host "   - Name: Qwen" -ForegroundColor Gray
Write-Host "   - Type: Ollama" -ForegroundColor Gray
Write-Host "   - URL: http://localhost:11437" -ForegroundColor Gray
Write-Host "`n   Backend 2 - Code:" -ForegroundColor Cyan
Write-Host "   - Name: Code" -ForegroundColor Gray
Write-Host "   - Type: Ollama" -ForegroundColor Gray
Write-Host "   - URL: http://localhost:11438" -ForegroundColor Gray
Write-Host "`n   Backend 3 - Flux:" -ForegroundColor Cyan
Write-Host "   - Name: Flux" -ForegroundColor Gray
Write-Host "   - Type: Ollama" -ForegroundColor Gray
Write-Host "   - URL: http://localhost:11439" -ForegroundColor Gray

Write-Host "`n=== ALTERNATIVA: Usar solo Mistral ===" -ForegroundColor Yellow
Write-Host "Si prefieres, puedes usar solo Mistral que ya está funcionando." -ForegroundColor Gray
Write-Host "Mistral es muy versátil y puede hacer programación, chat, y más." -ForegroundColor Gray

Write-Host "`n=== Verificando modelos disponibles ===" -ForegroundColor Cyan
Write-Host "`nModelos disponibles en cada backend:" -ForegroundColor Yellow

$backends | ForEach-Object {
    Write-Host "`n  $_($_.Name) (puerto $($_.Url -replace '.*:(\d+)', '$1')):" -ForegroundColor Cyan
    try {
        $models = Invoke-RestMethod -Uri "$($_.Url)/api/tags" -Method GET -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($models.models) {
            $models.models | ForEach-Object {
                Write-Host "    - $($_.name)" -ForegroundColor Green
            }
        } else {
            Write-Host "    (sin modelos aún)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "    (no disponible o sin modelos)" -ForegroundColor Red
    }
}

Write-Host "`n✓ Proceso completado" -ForegroundColor Green











