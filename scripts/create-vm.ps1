# Script para crear la máquina virtual en VirtualBox
# Ejecuta este script DESPUÉS de instalar VirtualBox

param(
    [string]$VMName = "moltbot-vm",
    [int]$VMRam = 4096,
    [int]$VMDisk = 30720,
    [string]$UbuntuIso = ""
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Creando Maquina Virtual" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Ruta de VirtualBox
$vboxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

# Verificar que VirtualBox está instalado
if (-not (Test-Path $vboxManage)) {
    Write-Host "[X] VirtualBox no esta instalado." -ForegroundColor Red
    Write-Host "    Por favor instala VirtualBox primero." -ForegroundColor Yellow
    Write-Host "    Ejecuta: .\scripts\download-virtualbox.ps1" -ForegroundColor Gray
    exit 1
}

Write-Host "Configuracion de la VM:" -ForegroundColor Yellow
Write-Host "  Nombre: $VMName" -ForegroundColor Gray
Write-Host "  RAM: $VMRam MB ($([math]::Round($VMRam/1024, 2)) GB)" -ForegroundColor Gray
Write-Host "  Disco: $VMDisk MB ($([math]::Round($VMDisk/1024, 2)) GB)" -ForegroundColor Gray
Write-Host ""

# Buscar ISO de Ubuntu si no se especificó
if ([string]::IsNullOrEmpty($UbuntuIso)) {
    $possiblePaths = @(
        "$env:USERPROFILE\Downloads\Ubuntu\ubuntu-22.04-server.iso",
        "$env:USERPROFILE\Downloads\ubuntu-22.04-server.iso",
        "$env:USERPROFILE\Downloads\Ubuntu\ubuntu-22.04.3-live-server-amd64.iso"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $UbuntuIso = $path
            Write-Host "[OK] ISO encontrada: $UbuntuIso" -ForegroundColor Green
            break
        }
    }
    
    if ([string]::IsNullOrEmpty($UbuntuIso)) {
        Write-Host "[!] ISO de Ubuntu no encontrada automaticamente" -ForegroundColor Yellow
        $UbuntuIso = Read-Host "Ingresa la ruta completa al archivo .iso de Ubuntu"
        
        if (-not (Test-Path $UbuntuIso)) {
            Write-Host "[X] El archivo no existe: $UbuntuIso" -ForegroundColor Red
            Write-Host "    Descarga Ubuntu primero: .\scripts\download-ubuntu.ps1" -ForegroundColor Yellow
            exit 1
        }
    }
}

Write-Host "ISO de Ubuntu: $UbuntuIso" -ForegroundColor Gray
Write-Host ""

# Verificar si la VM ya existe
$existingVMs = & $vboxManage list vms
if ($existingVMs -match "`"$VMName`"") {
    Write-Host "[!] La VM '$VMName' ya existe" -ForegroundColor Yellow
    $response = Read-Host "Deseas eliminarla y crear una nueva? (S/N)"
    if ($response -eq "S" -or $response -eq "s" -or $response -eq "Y" -or $response -eq "y") {
        Write-Host "Eliminando VM existente..." -ForegroundColor Yellow
        & $vboxManage controlvm $VMName poweroff 2>$null
        Start-Sleep -Seconds 2
        & $vboxManage unregistervm $VMName --delete 2>$null
        Write-Host "[OK] VM eliminada" -ForegroundColor Green
    } else {
        Write-Host "Operacion cancelada." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "Creando maquina virtual..." -ForegroundColor Yellow

try {
    # Crear VM
    & $vboxManage createvm --name $VMName --ostype "Ubuntu_64" --register
    Write-Host "[OK] VM creada" -ForegroundColor Green
    
    # Configurar RAM
    & $vboxManage modifyvm $VMName --memory $VMRam
    Write-Host "[OK] RAM configurada: $VMRam MB" -ForegroundColor Green
    
    # Configurar CPU (2 procesadores)
    & $vboxManage modifyvm $VMName --cpus 2
    Write-Host "[OK] CPU configurado: 2 procesadores" -ForegroundColor Green
    
    # Configurar red (NAT)
    & $vboxManage modifyvm $VMName --nic1 nat
    Write-Host "[OK] Red configurada: NAT" -ForegroundColor Green
    
    # Configurar port forwarding para SSH
    & $vboxManage modifyvm $VMName --natpf1 "ssh,tcp,,2222,,22"
    Write-Host "[OK] Port forwarding SSH: 2222 -> 22" -ForegroundColor Green

    # Port forwarding para desarrollo (apps web del agente)
    & $vboxManage modifyvm $VMName --natpf2 "dev3000,tcp,,3000,,3000"
    & $vboxManage modifyvm $VMName --natpf3 "dev5173,tcp,,5173,,5173"
    & $vboxManage modifyvm $VMName --natpf4 "dev8080,tcp,,8080,,8080"
    Write-Host "[OK] Port forwarding desarrollo: 3000, 5173, 8080" -ForegroundColor Green
    
    # Obtener ruta de máquinas virtuales
    $vmPath = & $vboxManage list systemproperties | Select-String "Default machine folder" | ForEach-Object { $_.Line.Split(":")[1].Trim() }
    $diskPath = Join-Path (Join-Path $vmPath $VMName) "$VMName.vdi"
    
    # Crear disco duro
    & $vboxManage createhd --filename $diskPath --size $VMDisk --format VDI --variant Standard
    Write-Host "[OK] Disco creado: $([math]::Round($VMDisk/1024, 2)) GB" -ForegroundColor Green
    
    # Conectar disco a la VM
    & $vboxManage storagectl $VMName --name "SATA Controller" --add sata --controller IntelAHCI
    & $vboxManage storageattach $VMName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $diskPath
    Write-Host "[OK] Disco conectado" -ForegroundColor Green
    
    # Montar ISO de Ubuntu
    & $vboxManage storagectl $VMName --name "IDE Controller" --add ide
    & $vboxManage storageattach $VMName --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $UbuntuIso
    Write-Host "[OK] ISO de Ubuntu montada" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "[OK] Maquina virtual creada exitosamente!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Proximos pasos:" -ForegroundColor Yellow
    Write-Host "  1. Abre VirtualBox" -ForegroundColor Gray
    Write-Host "  2. Selecciona '$VMName' y haz clic en 'Iniciar'" -ForegroundColor Gray
    Write-Host "  3. Sigue la instalacion de Ubuntu Server" -ForegroundColor Gray
    Write-Host "  4. IMPORTANTE: Marca 'Install OpenSSH server' durante la instalacion" -ForegroundColor Yellow
    Write-Host "  5. Crea usuario: moltbot (o el que prefieras)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Para conectarte via SSH:" -ForegroundColor Cyan
    Write-Host "  ssh moltbot@127.0.0.1 -p 2222" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Para acceder a apps del agente (desde el host):" -ForegroundColor Cyan
    Write-Host "  http://localhost:3000  (React, Next.js)" -ForegroundColor Gray
    Write-Host "  http://localhost:5173  (Vite)" -ForegroundColor Gray
    Write-Host "  http://localhost:8080  (Node/Express)" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-Host "[X] Error al crear la VM: $_" -ForegroundColor Red
    exit 1
}

