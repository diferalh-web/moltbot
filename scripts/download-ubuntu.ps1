# Script para descargar Ubuntu Server
# Ejecuta este script para descargar Ubuntu Server automáticamente

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Descargando Ubuntu Server 22.04 LTS" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Crear carpeta de descargas
$downloadDir = "$env:USERPROFILE\Downloads\Ubuntu"
New-Item -ItemType Directory -Force -Path $downloadDir | Out-Null

# URL de Ubuntu Server 22.04 LTS (usando mirror alternativo)
# Intentamos varias URLs posibles
$ubuntuUrls = @(
    "https://cdimage.ubuntu.com/ubuntu-server/releases/22.04/release/ubuntu-22.04.3-live-server-amd64.iso",
    "https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-live-server-amd64.iso",
    "https://old-releases.ubuntu.com/releases/22.04.3/ubuntu-22.04.3-live-server-amd64.iso"
)
$ubuntuPath = Join-Path $downloadDir "ubuntu-22.04-server.iso"

Write-Host "Descargando Ubuntu Server 22.04 LTS..." -ForegroundColor Yellow
Write-Host "URL: $ubuntuUrl" -ForegroundColor Gray
Write-Host "Destino: $ubuntuPath" -ForegroundColor Gray
Write-Host "Tamaño aproximado: 4.8 GB" -ForegroundColor Yellow
Write-Host "Esto puede tomar varios minutos..." -ForegroundColor Yellow
Write-Host ""

# Verificar si ya existe
if (Test-Path $ubuntuPath) {
    $fileSize = (Get-Item $ubuntuPath).Length / 1GB
    Write-Host "[!] El archivo ya existe: $ubuntuPath" -ForegroundColor Yellow
    Write-Host "    Tamaño: $([math]::Round($fileSize, 2)) GB" -ForegroundColor Gray
    $response = Read-Host "Deseas descargarlo de nuevo? (S/N)"
    if ($response -ne "S" -and $response -ne "s" -and $response -ne "Y" -and $response -ne "y") {
        Write-Host "Descarga cancelada. Usando archivo existente." -ForegroundColor Green
        exit 0
    }
}

$downloadSuccess = $false
foreach ($ubuntuUrl in $ubuntuUrls) {
    try {
        Write-Host "Intentando descargar desde: $ubuntuUrl" -ForegroundColor Yellow
        $ProgressPreference = 'Continue'
        Write-Host "Iniciando descarga..." -ForegroundColor Green
        Invoke-WebRequest -Uri $ubuntuUrl -OutFile $ubuntuPath -UseBasicParsing
        
        $fileSize = (Get-Item $ubuntuPath).Length / 1GB
        Write-Host ""
        Write-Host "[OK] Ubuntu Server descargado!" -ForegroundColor Green
        Write-Host "Ubicacion: $ubuntuPath" -ForegroundColor Gray
        Write-Host "Tamaño: $([math]::Round($fileSize, 2)) GB" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Proximo paso: Crear la maquina virtual" -ForegroundColor Yellow
        $downloadSuccess = $true
        break
    } catch {
        Write-Host "[!] Error con esta URL, intentando siguiente..." -ForegroundColor Yellow
        continue
    }
}

if (-not $downloadSuccess) {
    Write-Host "[X] No se pudo descargar automaticamente" -ForegroundColor Red
    Write-Host ""
    Write-Host "Descarga manual:" -ForegroundColor Yellow
    Write-Host "  1. Ve a: https://ubuntu.com/download/server" -ForegroundColor Gray
    Write-Host "  2. Descarga Ubuntu Server 22.04 LTS o 24.04 LTS" -ForegroundColor Gray
    Write-Host "  3. Guarda el archivo .iso en: $downloadDir" -ForegroundColor Gray
    Write-Host ""
    Write-Host "O usa este comando para abrir la pagina de descarga:" -ForegroundColor Cyan
    Write-Host "  Start-Process 'https://ubuntu.com/download/server'" -ForegroundColor Gray
    Write-Host ""
    $response = Read-Host "Deseas abrir la pagina de descarga ahora? (S/N)"
    if ($response -eq "S" -or $response -eq "s" -or $response -eq "Y" -or $response -eq "y") {
        Start-Process "https://ubuntu.com/download/server"
    }
    exit 1
}

