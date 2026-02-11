# Script maestro para implementar todo el ecosistema de IA
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Implementación Completa del Ecosistema de IA" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Este script configurará:" -ForegroundColor Yellow
Write-Host "  - IA de Programación (Ollama-Code)" -ForegroundColor White
Write-Host "  - Generación de Imágenes (Ollama-Flux)" -ForegroundColor White
Write-Host "  - Generación Avanzada (ComfyUI)" -ForegroundColor White
Write-Host "  - Generación de Video (Stable Video)" -ForegroundColor White
Write-Host "  - Síntesis de Voz (Coqui TTS)" -ForegroundColor White
Write-Host "  - Interfaz Unificada (Open WebUI Extendido)" -ForegroundColor White
Write-Host ""
Write-Host "Tiempo estimado: 2-3 horas (incluyendo descarga de modelos)" -ForegroundColor Yellow
Write-Host ""

# Verificar permisos de administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[X] Este script requiere permisos de Administrador" -ForegroundColor Red
    Write-Host "    Ejecuta PowerShell como Administrador" -ForegroundColor Yellow
    exit 1
}

# Confirmar
$confirm = Read-Host "¿Deseas continuar? (S/N)"
if ($confirm -ne "S" -and $confirm -ne "s") {
    Write-Host "Cancelado por el usuario" -ForegroundColor Yellow
    exit 0
}
Write-Host ""

# Cambiar al directorio del proyecto
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath
Set-Location $projectRoot

Write-Host "Directorio de trabajo: $projectRoot" -ForegroundColor Gray
Write-Host ""

# Fase 1: IA de Programación
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "FASE 1: IA de Programación" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
& "$scriptPath\setup-coder-llm.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error en Fase 1, continuando..." -ForegroundColor Yellow
}
Write-Host ""

# Fase 2: Flux
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "FASE 2: Flux (Generación de Imágenes)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
& "$scriptPath\setup-flux.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error en Fase 2, continuando..." -ForegroundColor Yellow
}
Write-Host ""

# Fase 3: Coqui TTS
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "FASE 3: Coqui TTS (Síntesis de Voz)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
& "$scriptPath\setup-coqui-tts.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error en Fase 3, continuando..." -ForegroundColor Yellow
}
Write-Host ""

# Fase 4: ComfyUI
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "FASE 4: ComfyUI (Generación Avanzada)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
& "$scriptPath\setup-comfyui.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error en Fase 4, continuando..." -ForegroundColor Yellow
}
Write-Host ""

# Fase 5: Stable Video
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "FASE 5: Stable Video Diffusion" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
& "$scriptPath\setup-stable-video.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error en Fase 5, continuando..." -ForegroundColor Yellow
}
Write-Host ""

# Fase 6: Firewall
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "FASE 6: Configurar Firewall" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
& "$scriptPath\configurar-firewall-extendido.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error en Fase 6, continuando..." -ForegroundColor Yellow
}
Write-Host ""

# Fase 7: Open WebUI Extendido
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "FASE 7: Open WebUI Extendido" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
& "$scriptPath\configure-open-webui-extended.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error en Fase 7" -ForegroundColor Yellow
}
Write-Host ""

# Resumen final
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "IMPLEMENTACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Descargar modelos (esto puede tardar 2-3 horas):" -ForegroundColor White
Write-Host "   .\scripts\download-models.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Verificar todos los servicios:" -ForegroundColor White
Write-Host "   .\scripts\verificar-servicios-extendidos.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Acceder a Open WebUI:" -ForegroundColor White
Write-Host "   http://localhost:8082" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Leer la documentación:" -ForegroundColor White
Write-Host "   GUIA_IMPLEMENTACION_COMPLETA.md" -ForegroundColor Gray
Write-Host ""
Write-Host "Servicios configurados:" -ForegroundColor Yellow
Write-Host "  - Ollama-Code (11438): IA de Programación" -ForegroundColor Gray
Write-Host "  - Ollama-Flux (11439): Generación de Imágenes" -ForegroundColor Gray
Write-Host "  - ComfyUI (7860): Generación Avanzada" -ForegroundColor Gray
Write-Host "  - Stable Video (8000): Generación de Video" -ForegroundColor Gray
Write-Host "  - Coqui TTS (5002): Síntesis de Voz" -ForegroundColor Gray
Write-Host "  - Open WebUI (8082): Interfaz Unificada" -ForegroundColor Gray
Write-Host ""












