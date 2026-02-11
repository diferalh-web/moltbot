# Script de PowerShell para transferir archivos a la VM
# Uso: .\transfer-to-vm.ps1 -VMUser "moltbot" -VMIP "10.0.2.15" -SourcePath "C:\moltbot" -DestPath "/home/moltbot/moltbot-project"

param(
    [Parameter(Mandatory=$true)]
    [string]$VMUser,
    
    [Parameter(Mandatory=$false)]
    [string]$VMIP = "127.0.0.1",
    
    [Parameter(Mandatory=$false)]
    [string]$SourcePath = ".",
    
    [Parameter(Mandatory=$false)]
    [string]$DestPath = "/home/$VMUser/scripts",
    
    [Parameter(Mandatory=$false)]
    [int]$Port = 2222
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Transferiendo archivos a la VM" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Usuario VM: $VMUser" -ForegroundColor Yellow
Write-Host "IP VM: $VMIP" -ForegroundColor Yellow
Write-Host "Puerto: $Port" -ForegroundColor Yellow
Write-Host "Origen: $SourcePath" -ForegroundColor Yellow
Write-Host "Destino: $DestPath" -ForegroundColor Yellow
Write-Host ""

# Verificar que SCP esté disponible
if (-not (Get-Command scp -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Error: SCP no está disponible" -ForegroundColor Red
    Write-Host "Instala OpenSSH Client en Windows:" -ForegroundColor Yellow
    Write-Host "  Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0" -ForegroundColor Gray
    exit 1
}

# Transferir archivos
Write-Host "Transferiendo archivos..." -ForegroundColor Green

try {
    if ($Port -eq 22) {
        scp -r "$SourcePath\*" "${VMUser}@${VMIP}:${DestPath}"
    } else {
        scp -P $Port -r "$SourcePath\*" "${VMUser}@${VMIP}:${DestPath}"
    }
    
    Write-Host ""
    Write-Host "✅ Archivos transferidos correctamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Para conectarte a la VM:" -ForegroundColor Cyan
    if ($Port -eq 22) {
        Write-Host "  ssh ${VMUser}@${VMIP}" -ForegroundColor Gray
    } else {
        Write-Host "  ssh ${VMUser}@${VMIP} -p $Port" -ForegroundColor Gray
    }
} catch {
    Write-Host ""
    Write-Host "❌ Error al transferir archivos: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifica:" -ForegroundColor Yellow
    Write-Host "  1. Que la VM esté encendida" -ForegroundColor Gray
    Write-Host "  2. Que SSH esté configurado en la VM" -ForegroundColor Gray
    Write-Host "  3. Que la IP sea correcta" -ForegroundColor Gray
    Write-Host "  4. Que tengas la contraseña correcta" -ForegroundColor Gray
    exit 1
}

