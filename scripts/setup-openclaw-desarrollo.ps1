# Configura OpenClaw para desarrollo autónomo en la VM
# Ejecutar desde la carpeta del proyecto: .\scripts\setup-openclaw-desarrollo.ps1
#
# Requisitos: VM encendida, SSH accesible, OpenSSH Client en Windows

param(
    [string]$VMUser = "moltbot",
    [string]$VMIP = "127.0.0.1",
    [int]$Port = 2222,
    [string]$HostIP = "192.168.100.42",
    [string]$BraveApiKey = "",
    [switch]$SkipInstallOpenClaw,
    [switch]$SkipTransfer
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
if (-not $ProjectRoot) { $ProjectRoot = "c:\code\moltbot" }

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Setup OpenClaw Desarrollo" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "VM: ${VMUser}@${VMIP}:$Port" -ForegroundColor Yellow
Write-Host "Ollama Host: $HostIP" -ForegroundColor Yellow
Write-Host ""

# 1. Transferir scripts y shareFolder
if (-not $SkipTransfer) {
    Write-Host "[1/5] Transfiriendo scripts a la VM..." -ForegroundColor Yellow
    
    $scriptsPath = Join-Path $ProjectRoot "scripts"
    $sharePath = Join-Path $ProjectRoot "shareFolder"
    
    # Crear directorios en VM y transferir
    $sshCmd = "mkdir -p ~/scripts ~/shareFolder"
    ssh -o StrictHostKeyChecking=no -p $Port "${VMUser}@${VMIP}" $sshCmd 2>$null
    
    scp -P $Port -r "$scriptsPath\*.sh" "${VMUser}@${VMIP}:~/scripts/" 2>$null
    scp -P $Port -r "$sharePath\*" "${VMUser}@${VMIP}:~/shareFolder/" 2>$null
    
    ssh -o StrictHostKeyChecking=no -p $Port "${VMUser}@${VMIP}" "chmod +x ~/scripts/*.sh ~/shareFolder/*.sh 2>/dev/null"
    
    Write-Host "  [OK] Archivos transferidos" -ForegroundColor Green
} else {
    Write-Host "[1/5] Omitiendo transferencia (SkipTransfer)" -ForegroundColor Gray
}

# 2. Instalar OpenClaw (opcional)
if (-not $SkipInstallOpenClaw) {
    Write-Host ""
    Write-Host "[2/5] Instalando OpenClaw..." -ForegroundColor Yellow
    ssh -o StrictHostKeyChecking=no -p $Port "${VMUser}@${VMIP}" "bash ~/scripts/install-openclaw.sh"
    Write-Host "  [OK] OpenClaw instalado" -ForegroundColor Green
} else {
    Write-Host "[2/5] Omitiendo instalación OpenClaw (SkipInstallOpenClaw)" -ForegroundColor Gray
}

# 3. Instalar dependencias del browser
Write-Host ""
Write-Host "[3/5] Instalando dependencias del browser..." -ForegroundColor Yellow
ssh -o StrictHostKeyChecking=no -p $Port "${VMUser}@${VMIP}" "bash ~/scripts/install-browser-deps.sh"
Write-Host "  [OK] Browser deps instalados" -ForegroundColor Green

# 4. Configurar openclaw.json (desarrollo)
if (-not $BraveApiKey) {
    $BraveApiKey = Read-Host "BRAVE_API_KEY (Enter para omitir, configurar después)"
}

Write-Host ""
Write-Host "[4/5] Configurando openclaw.json para desarrollo..." -ForegroundColor Yellow
$configCmd = "cd ~/shareFolder && bash configurar-openclaw-desarrollo.sh '$HostIP' '$BraveApiKey'"
ssh -o StrictHostKeyChecking=no -p $Port "${VMUser}@${VMIP}" $configCmd
Write-Host "  [OK] Configuración aplicada" -ForegroundColor Green

# 5. Crear workspace
Write-Host ""
Write-Host "[5/5] Creando workspace de desarrollo..." -ForegroundColor Yellow
ssh -o StrictHostKeyChecking=no -p $Port "${VMUser}@${VMIP}" "bash ~/shareFolder/crear-workspace-desarrollo.sh"
Write-Host "  [OK] Workspace listo" -ForegroundColor Green

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Setup completado" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Conecta por SSH: ssh ${VMUser}@${VMIP} -p $Port" -ForegroundColor Gray
Write-Host "  2. Configura canales: openclaw channels login whatsapp" -ForegroundColor Gray
Write-Host "     O Telegram: openclaw channels add --channel telegram --token <BOT_TOKEN>" -ForegroundColor Gray
Write-Host "  3. Inicia Gateway: openclaw gateway" -ForegroundColor Gray
Write-Host ""
Write-Host "Documentación: docs/AGENTE_DESARROLLO_OPENCLAW.md" -ForegroundColor Cyan
Write-Host ""
