# Espera a que stable-video termine de arrancar y ejecuta la prueba
# Uso: .\scripts\esperar-y-probar-stable-video.ps1

$videoUrl = "http://localhost:8000"
$maxWait = 600  # 10 min max esperando arranque

Write-Host ""
Write-Host "=== Esperando Stable Video Diffusion ===" -ForegroundColor Cyan
Write-Host "  El contenedor instala ~2GB de dependencias en el primer arranque." -ForegroundColor Gray
Write-Host "  Puede tardar 5-10 minutos." -ForegroundColor Gray
Write-Host ""

$elapsed = 0
while ($elapsed -lt $maxWait) {
    try {
        $r = Invoke-RestMethod -Uri "$videoUrl/health" -TimeoutSec 5 -ErrorAction Stop
        Write-Host "[OK] Servicio listo: $($r.service)" -ForegroundColor Green
        Write-Host ""
        & "$PSScriptRoot\probar-stable-video.ps1"
        exit $LASTEXITCODE
    } catch {
        Write-Host "  ... esperando ($elapsed s) - $($_.Exception.Message)" -ForegroundColor DarkGray
    }
    Start-Sleep -Seconds 15
    $elapsed += 15
}

Write-Host ""
Write-Host "[X] Timeout: el servicio no respondio en $($maxWait/60) minutos." -ForegroundColor Red
Write-Host "    Revisa: docker logs stable-video --tail 80" -ForegroundColor Yellow
exit 1
