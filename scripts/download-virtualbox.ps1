# Script para descargar VirtualBox
# Ejecuta este script para descargar VirtualBox automáticamente

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Descargando VirtualBox" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Crear carpeta de descargas
$downloadDir = "$env:USERPROFILE\Downloads\VirtualBox"
New-Item -ItemType Directory -Force -Path $downloadDir | Out-Null

# URL de VirtualBox (última versión estable)
$vboxUrl = "https://download.virtualbox.org/virtualbox/7.0.16/VirtualBox-7.0.16-162802-Win.exe"
$vboxPath = Join-Path $downloadDir "VirtualBox-installer.exe"

# URL de Extension Pack
$extPackUrl = "https://download.virtualbox.org/virtualbox/7.0.16/Oracle_VM_VirtualBox_Extension_Pack-7.0.16.vbox-extpack"
$extPackPath = Join-Path $downloadDir "VirtualBox-Extension-Pack.vbox-extpack"

Write-Host "Descargando VirtualBox..." -ForegroundColor Yellow
Write-Host "URL: $vboxUrl" -ForegroundColor Gray
Write-Host "Destino: $vboxPath" -ForegroundColor Gray
Write-Host ""

try {
    $ProgressPreference = 'Continue'
    Invoke-WebRequest -Uri $vboxUrl -OutFile $vboxPath -UseBasicParsing
    
    Write-Host "[OK] VirtualBox descargado!" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Descargando Extension Pack..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $extPackUrl -OutFile $extPackPath -UseBasicParsing
    
    Write-Host "[OK] Extension Pack descargado!" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "Descarga completada!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Archivos descargados:" -ForegroundColor Yellow
    Write-Host "  1. $vboxPath" -ForegroundColor Gray
    Write-Host "  2. $extPackPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Proximos pasos:" -ForegroundColor Yellow
    Write-Host "  1. Ejecuta el instalador: $vboxPath" -ForegroundColor Gray
    Write-Host "  2. Sigue el asistente (acepta todos los defaults)" -ForegroundColor Gray
    Write-Host "  3. IMPORTANTE: Acepta instalar los drivers de red" -ForegroundColor Yellow
    Write-Host "  4. Despues de instalar, abre VirtualBox" -ForegroundColor Gray
    Write-Host "  5. Ve a: Archivo -> Preferencias -> Extensiones" -ForegroundColor Gray
    Write-Host "  6. Agrega el Extension Pack: $extPackPath" -ForegroundColor Gray
    Write-Host ""
    
    # Preguntar si quiere abrir el instalador
    $response = Read-Host "Deseas abrir el instalador ahora? (S/N)"
    if ($response -eq "S" -or $response -eq "s" -or $response -eq "Y" -or $response -eq "y") {
        Start-Process $vboxPath
        Write-Host "Instalador abierto!" -ForegroundColor Green
    }
    
} catch {
    Write-Host "[X] Error al descargar: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Descarga manual:" -ForegroundColor Yellow
    Write-Host "  1. Ve a: https://www.virtualbox.org/wiki/Downloads" -ForegroundColor Gray
    Write-Host "  2. Descarga VirtualBox para Windows hosts" -ForegroundColor Gray
    Write-Host "  3. Descarga Extension Pack" -ForegroundColor Gray
    exit 1
}












