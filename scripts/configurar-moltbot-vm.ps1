# Script para configurar Moltbot en la VM
# Ejecutar: powershell -ExecutionPolicy Bypass -File .\scripts\configurar-moltbot-vm.ps1

param(
    [string]$VMUser = "moltbot2",
    [string]$VMIP = "127.0.0.1",
    [int]$Port = 2222,
    [string]$OllamaHost = "192.168.100.42",
    [int]$OllamaPort = 11435
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurando Moltbot en la VM" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Crear archivo de configuración
Write-Host "[1/3] Creando archivo de configuracion..." -ForegroundColor Yellow

$configJson = @"
{
  "models": {
    "llama2": {
      "provider": "ollama",
      "model": "llama2",
      "baseURL": "http://${OllamaHost}:${OllamaPort}"
    }
  },
  "model": "llama2"
}
"@

# Guardar JSON temporalmente
$tempFile = [System.IO.Path]::GetTempFileName()
$configJson | Out-File -FilePath $tempFile -Encoding UTF8

Write-Host "Ejecutando comandos en la VM..." -ForegroundColor Yellow
Write-Host ""

# Comando SSH para crear configuración
$sshCommands = @"
mkdir -p ~/.openclaw && cat > ~/.openclaw/openclaw.json << 'EOFCONFIG'
$configJson
EOFCONFIG
echo 'Configuracion creada'
cat ~/.openclaw/openclaw.json
"@

Write-Host "Ejecuta este comando en PowerShell (te pedira la contraseña):" -ForegroundColor Cyan
Write-Host ""
Write-Host "ssh ${VMUser}@${VMIP} -p ${Port} `"$($sshCommands -replace "`n", "; " -replace "'", "''")`"" -ForegroundColor Gray
Write-Host ""

# Limpiar archivo temporal
Remove-Item $tempFile -ErrorAction SilentlyContinue

Write-Host "[2/3] Probar conexion a Ollama..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Ejecuta en la VM:" -ForegroundColor Cyan
Write-Host "  curl http://${OllamaHost}:${OllamaPort}/api/tags" -ForegroundColor Gray
Write-Host ""

Write-Host "[3/3] Probar Moltbot..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Ejecuta en la VM:" -ForegroundColor Cyan
Write-Host "  cd ~/moltbot" -ForegroundColor Gray
Write-Host "  pnpm start agent --message 'Hola' --local" -ForegroundColor Gray
Write-Host ""

Write-Host "=========================================" -ForegroundColor Green
Write-Host "Comandos Listos!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green












