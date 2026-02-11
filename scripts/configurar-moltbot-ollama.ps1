# Script para configurar Moltbot con Ollama
# Ejecutar: powershell -ExecutionPolicy Bypass -File .\scripts\configurar-moltbot-ollama.ps1

param(
    [string]$VMUser = "moltbot2",
    [string]$VMIP = "127.0.0.1",
    [int]$Port = 2222,
    [string]$OllamaHost = "192.168.100.42",
    [int]$OllamaPort = 11435
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurando Moltbot con Ollama" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que Docker está corriendo
Write-Host "[1/4] Verificando Docker..." -ForegroundColor Yellow
$dockerStatus = docker ps --filter "name=ollama-moltbot" --format "{{.Names}}" 2>&1
if ($dockerStatus -match "ollama-moltbot") {
    Write-Host "[OK] Contenedor ollama-moltbot está corriendo" -ForegroundColor Green
} else {
    Write-Host "[!] Contenedor ollama-moltbot no está corriendo" -ForegroundColor Red
    Write-Host "    Ejecuta: docker run -d --name ollama-moltbot -p 11435:11434 ollama/ollama" -ForegroundColor Yellow
    exit 1
}

# Verificar modelo
Write-Host ""
Write-Host "[2/4] Verificando modelo llama2..." -ForegroundColor Yellow
$models = docker exec ollama-moltbot ollama list 2>&1
if ($models -match "llama2") {
    Write-Host "[OK] Modelo llama2 está instalado" -ForegroundColor Green
} else {
    Write-Host "[!] Modelo llama2 no encontrado" -ForegroundColor Yellow
    Write-Host "    Descargando modelo (esto puede tomar varios minutos)..." -ForegroundColor Yellow
    docker exec ollama-moltbot ollama pull llama2
}

# Configurar firewall (requiere admin)
Write-Host ""
Write-Host "[3/4] Configurando firewall..." -ForegroundColor Yellow
$firewallRule = Get-NetFirewallRule -DisplayName "Ollama Moltbot" -ErrorAction SilentlyContinue
if ($firewallRule) {
    Write-Host "[OK] Regla de firewall ya existe" -ForegroundColor Green
} else {
    Write-Host "[!] Creando regla de firewall (requiere permisos de administrador)" -ForegroundColor Yellow
    try {
        netsh advfirewall firewall add rule name="Ollama Moltbot" dir=in action=allow protocol=TCP localport=$OllamaPort | Out-Null
        Write-Host "[OK] Regla de firewall creada" -ForegroundColor Green
    } catch {
        Write-Host "[!] No se pudo crear la regla automáticamente" -ForegroundColor Red
        Write-Host "    Ejecuta manualmente como Administrador:" -ForegroundColor Yellow
        Write-Host "    netsh advfirewall firewall add rule name=`"Ollama Moltbot`" dir=in action=allow protocol=TCP localport=$OllamaPort" -ForegroundColor Gray
    }
}

# Configurar Moltbot en la VM
Write-Host ""
Write-Host "[4/4] Configurando Moltbot en la VM..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Ejecuta estos comandos en tu terminal SSH conectado a la VM:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  cd ~/moltbot" -ForegroundColor Gray
Write-Host "  pnpm start config set models.default.provider ollama" -ForegroundColor Gray
Write-Host "  pnpm start config set models.default.model llama2" -ForegroundColor Gray
Write-Host "  pnpm start config set models.default.baseURL http://${OllamaHost}:${OllamaPort}" -ForegroundColor Gray
Write-Host ""
Write-Host "O ejecuta este comando completo:" -ForegroundColor Cyan
Write-Host ""
$sshCommand = "ssh ${VMUser}@${VMIP} -p ${Port} `"cd ~/moltbot && pnpm start config set models.default.provider ollama && pnpm start config set models.default.model llama2 && pnpm start config set models.default.baseURL http://${OllamaHost}:${OllamaPort} && echo 'Configuracion completada'`""
Write-Host "  $sshCommand" -ForegroundColor Gray
Write-Host ""

# Probar conexión
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Probar Conexion" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Despues de configurar, prueba la conexion desde la VM:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  curl http://${OllamaHost}:${OllamaPort}/api/tags" -ForegroundColor Gray
Write-Host ""
Write-Host "Y luego prueba Moltbot:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  cd ~/moltbot" -ForegroundColor Gray
Write-Host "  pnpm start agent --message 'Hola' --local" -ForegroundColor Gray
Write-Host ""

Write-Host "=========================================" -ForegroundColor Green
Write-Host "Configuracion Lista!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green












