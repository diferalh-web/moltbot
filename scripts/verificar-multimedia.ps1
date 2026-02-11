# Script para verificar servicios multimedia
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Verificacion de Servicios Multimedia" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar servicios
$services = @(
    @{Name="ComfyUI"; Port=7860; URL="http://localhost:7860"},
    @{Name="Stable Video"; Port=8000; URL="http://localhost:8000"},
    @{Name="Coqui TTS"; Port=5002; URL="http://localhost:5002"},
    @{Name="Ollama Flux"; Port=11439; URL="http://localhost:11439"}
)

Write-Host "Estado de Servicios:" -ForegroundColor Yellow
Write-Host ""

foreach ($service in $services) {
    $containerName = $service.Name.ToLower().Replace(' ', '-')
    $container = docker ps --filter "name=$containerName" --format "{{.Names}}" 2>$null
    if ($container) {
        Write-Host "[OK] $($service.Name)" -ForegroundColor Green
        Write-Host "    Contenedor: $container" -ForegroundColor Gray
        Write-Host "    URL: $($service.URL)" -ForegroundColor Gray
        
        # Verificar puerto
        $portTest = Test-NetConnection -ComputerName localhost -Port $service.Port -WarningAction SilentlyContinue -InformationLevel Quiet 2>$null
        if ($portTest) {
            Write-Host "    Puerto $($service.Port): Accesible" -ForegroundColor Green
        } else {
            Write-Host "    Puerto $($service.Port): No accesible" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[X] $($service.Name)" -ForegroundColor Red
        Write-Host "    No esta corriendo" -ForegroundColor Gray
    }
    Write-Host ""
}

# Verificar Open WebUI
Write-Host "Open WebUI:" -ForegroundColor Yellow
$webui = docker ps --filter "name=open-webui" --format "{{.Names}}" 2>$null
if ($webui) {
    Write-Host "[OK] Open WebUI esta corriendo" -ForegroundColor Green
    Write-Host "    URL: http://localhost:8082" -ForegroundColor Cyan
} else {
    Write-Host "[X] Open WebUI no esta corriendo" -ForegroundColor Red
}
Write-Host ""

# Verificar Knowledge Base
Write-Host "Knowledge Base (RAG):" -ForegroundColor Yellow
Write-Host "[INFO] Open WebUI tiene soporte nativo para Knowledge Base" -ForegroundColor Cyan
Write-Host "    Accede a: http://localhost:8082" -ForegroundColor White
Write-Host "    Ve a: Settings -> Features -> Habilita 'Knowledge Base'" -ForegroundColor White
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Guia de Uso:" -ForegroundColor Yellow
Write-Host "  Ver: GUIA_USO_MULTIMEDIA_Y_RAG.md" -ForegroundColor White
Write-Host "=========================================" -ForegroundColor Cyan

