# Script para configurar Ollama en la VM
# Ejecutar: powershell -ExecutionPolicy Bypass -File .\scripts\configurar-ollama-vm.ps1

param(
    [string]$VMUser = "moltbot2",
    [string]$VMIP = "127.0.0.1",
    [int]$Port = 2222,
    [string]$OllamaHost = "192.168.100.42",
    [int]$OllamaPort = 11435,
    [string]$Password = ""
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurando Ollama en la VM" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Si no se proporcionó contraseña, pedirla
if ([string]::IsNullOrEmpty($Password)) {
    Write-Host "Ingresa la contraseña SSH para $VMUser@$VMIP`:$Port" -ForegroundColor Yellow
    $securePassword = Read-Host -AsSecureString "Password"
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

# Instalar sshpass si no está disponible (requiere WSL o Git Bash)
# Por ahora, usaremos comandos que el usuario puede ejecutar

Write-Host "[1/3] Creando directorio y archivo auth-profiles.json..." -ForegroundColor Yellow

$commands = @"
mkdir -p ~/.openclaw/agents/main/agent
echo '{"ollama":{"baseURL":"http://${OllamaHost}:${OllamaPort}","model":"llama2"}}' > ~/.openclaw/agents/main/agent/auth-profiles.json
cat ~/.openclaw/agents/main/agent/auth-profiles.json
"@

Write-Host ""
Write-Host "Ejecuta este comando en PowerShell (te pedira la contraseña):" -ForegroundColor Cyan
Write-Host ""
Write-Host "ssh ${VMUser}@${VMIP} -p ${Port} `"$($commands -replace "`n", "; " -replace "'", "''")`"" -ForegroundColor Gray
Write-Host ""

Write-Host "[2/3] Verificar variables de entorno..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Ejecuta en la VM:" -ForegroundColor Cyan
Write-Host "  echo `$OPENCLAW_MODEL_PROVIDER" -ForegroundColor Gray
Write-Host "  echo `$OPENCLAW_MODEL_NAME" -ForegroundColor Gray
Write-Host "  echo `$OPENCLAW_MODEL_BASE_URL" -ForegroundColor Gray
Write-Host ""

Write-Host "[3/3] Probar Moltbot..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Ejecuta en la VM:" -ForegroundColor Cyan
Write-Host '  cd ~/moltbot' -ForegroundColor Gray
Write-Host '  pnpm start agent --session-id test-session --message "hola" --local' -ForegroundColor Gray
Write-Host ""

Write-Host "=========================================" -ForegroundColor Green
Write-Host "Comandos Listos!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green












