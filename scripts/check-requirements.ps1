# Script de verificación de requisitos
# Ejecuta este script para verificar qué tienes instalado

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Verificación de Requisitos" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Verificar VirtualBox
Write-Host "1. VirtualBox:" -ForegroundColor Yellow
$vboxPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
if (Test-Path $vboxPath) {
    $version = & $vboxPath --version 2>$null
    Write-Host "   [OK] Instalado - Version: $version" -ForegroundColor Green
} else {
    Write-Host "   [X] NO instalado" -ForegroundColor Red
    Write-Host "   Descargar: https://www.virtualbox.org/wiki/Downloads" -ForegroundColor Gray
    $allGood = $false
}
Write-Host ""

# Verificar Docker
Write-Host "2. Docker:" -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    Write-Host "   [OK] Instalado - $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "   [X] NO instalado" -ForegroundColor Red
    $allGood = $false
}
Write-Host ""

# Verificar SSH
Write-Host "3. SSH Client:" -ForegroundColor Yellow
try {
    $sshVersion = ssh -V 2>&1
    Write-Host "   [OK] Disponible - $sshVersion" -ForegroundColor Green
} catch {
    Write-Host "   [X] NO disponible" -ForegroundColor Red
    Write-Host "   Instalar: Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0" -ForegroundColor Gray
    $allGood = $false
}
Write-Host ""

# Verificar RAM disponible
Write-Host "4. RAM disponible:" -ForegroundColor Yellow
$ram = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB
    Write-Host "   RAM total: $([math]::Round($ram, 2)) GB" -ForegroundColor Cyan
if ($ram -ge 8) {
    Write-Host "   [OK] Suficiente para VM (recomendado: 8GB+)" -ForegroundColor Green
} else {
    Write-Host "   [!] RAM limitada (minimo 8GB recomendado)" -ForegroundColor Yellow
}
Write-Host ""

# Verificar espacio en disco
Write-Host "5. Espacio en disco:" -ForegroundColor Yellow
$disk = Get-PSDrive C
$freeSpaceGB = $disk.Free / 1GB
    Write-Host "   Espacio libre en C:: $([math]::Round($freeSpaceGB, 2)) GB" -ForegroundColor Cyan
if ($freeSpaceGB -ge 50) {
    Write-Host "   [OK] Suficiente espacio (recomendado: 50GB+)" -ForegroundColor Green
} else {
    Write-Host "   [!] Espacio limitado (minimo 50GB recomendado)" -ForegroundColor Yellow
}
Write-Host ""

# Resumen
Write-Host "=========================================" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "[OK] Todos los requisitos basicos estan listos!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Proximo paso: Instalar VirtualBox" -ForegroundColor Yellow
} else {
    Write-Host "[!] Algunos requisitos faltan" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Sigue las instrucciones arriba para instalar lo que falta" -ForegroundColor Gray
}
Write-Host "=========================================" -ForegroundColor Cyan

