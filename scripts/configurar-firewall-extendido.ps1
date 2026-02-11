# Script para configurar firewall para todos los servicios extendidos
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar Firewall para Servicios Extendidos" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar permisos de administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[X] Este script requiere permisos de Administrador" -ForegroundColor Red
    Write-Host "    Ejecuta PowerShell como Administrador" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] Ejecutando como Administrador" -ForegroundColor Green
Write-Host ""

# Puertos a configurar (incluye acceso desde red Tailscale/LAN)
$ports = @(
    @{Port=8082; Name="Open-WebUI"; Service="Interfaz Web Principal"},
    @{Port=11436; Name="Ollama-Mistral"; Service="LLM Mistral"},
    @{Port=11437; Name="Ollama-Qwen"; Service="LLM Qwen"},
    @{Port=11438; Name="Ollama-Code"; Service="IA de Programación"},
    @{Port=11439; Name="Ollama-Flux"; Service="Generación de Imágenes"},
    @{Port=7860; Name="ComfyUI"; Service="Generación Avanzada de Imágenes"},
    @{Port=8000; Name="Stable-Video"; Service="Generación de Video"},
    @{Port=8001; Name="Draco-Core"; Service="Orquestación de Agentes"},
    @{Port=5002; Name="Coqui-TTS"; Service="Síntesis de Voz"},
    @{Port=5003; Name="Web-Search"; Service="Búsqueda Web"},
    @{Port=5004; Name="External-APIs"; Service="Gateway APIs Externas"}
)

Write-Host "[1/2] Configurando reglas de firewall..." -ForegroundColor Yellow
Write-Host ""

$created = 0
$existing = 0
$errors = 0

foreach ($portConfig in $ports) {
    $port = $portConfig.Port
    $name = $portConfig.Name
    $service = $portConfig.Service
    
    Write-Host "  Puerto $port ($name - $service)..." -ForegroundColor Cyan
    
    try {
        $existingRule = Get-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue
        if ($existingRule) {
            Write-Host "    [OK] Regla ya existe" -ForegroundColor Green
            $existing++
        } else {
            New-NetFirewallRule -DisplayName $name -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow -ErrorAction Stop | Out-Null
            Write-Host "    [OK] Regla creada" -ForegroundColor Green
            $created++
        }
    } catch {
        Write-Host "    [X] Error: $_" -ForegroundColor Red
        Write-Host "    [!] Ejecuta manualmente:" -ForegroundColor Yellow
        Write-Host "        netsh advfirewall firewall add rule name=`"$name`" dir=in action=allow protocol=TCP localport=$port" -ForegroundColor White
        $errors++
    }
}

Write-Host ""
Write-Host "[2/2] Resumen:" -ForegroundColor Yellow
Write-Host "  - Reglas creadas: $created" -ForegroundColor Green
Write-Host "  - Reglas existentes: $existing" -ForegroundColor Yellow
if ($errors -gt 0) {
    Write-Host "  - Errores: $errors" -ForegroundColor Red
}
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Configuración de firewall completada!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Puertos configurados:" -ForegroundColor Yellow
foreach ($portConfig in $ports) {
    Write-Host "  - Puerto $($portConfig.Port): $($portConfig.Name) ($($portConfig.Service))" -ForegroundColor Gray
}
Write-Host ""












