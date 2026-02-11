# Script para configurar Ollama-Code con modelos de programación
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar Ollama-Code (IA de Programación)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Docker
Write-Host "[1/6] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    Write-Host "[OK] Docker instalado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker no está instalado" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Verificar GPU NVIDIA
Write-Host "[2/6] Verificando GPU NVIDIA..." -ForegroundColor Yellow
try {
    $nvidiaSmi = nvidia-smi --query-gpu=name --format=csv,noheader 2>$null
    if ($nvidiaSmi) {
        Write-Host "[OK] GPU detectada: $nvidiaSmi" -ForegroundColor Green
    } else {
        Write-Host "[!] GPU NVIDIA no detectada, continuando sin GPU" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[!] nvidia-smi no disponible, continuando sin GPU" -ForegroundColor Yellow
}
Write-Host ""

# Obtener IP local
Write-Host "[3/6] Obteniendo IP local..." -ForegroundColor Yellow
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -notlike "192.168.56.*" -and $_.IPAddress -notlike "172.20.*"} | Select-Object -First 1).IPAddress
if (-not $ipAddress) {
    $ipAddress = "192.168.100.42"
}
Write-Host "[OK] IP: $ipAddress" -ForegroundColor Green
Write-Host ""

# Crear contenedor ollama-code
Write-Host "[4/6] Creando contenedor ollama-code..." -ForegroundColor Yellow

# Detener y eliminar si existe
docker stop ollama-code 2>$null | Out-Null
docker rm ollama-code 2>$null | Out-Null

# Crear nuevo contenedor
docker run -d `
  --name ollama-code `
  -p 11438:11434 `
  -v "${env:USERPROFILE}/ollama-code-data:/root/.ollama" `
  --restart unless-stopped `
  --gpus all `
  -e OLLAMA_HOST=0.0.0.0:11434 `
  ollama/ollama:latest

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Contenedor ollama-code creado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "[5/6] Esperando a que Ollama inicie (20 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Configurar firewall
Write-Host "[6/6] Configurando firewall para puerto 11438..." -ForegroundColor Yellow
try {
    $existingRule = Get-NetFirewallRule -DisplayName "Ollama-Code" -ErrorAction SilentlyContinue
    if ($existingRule) {
        Write-Host "[OK] Regla de firewall ya existe" -ForegroundColor Green
    } else {
        New-NetFirewallRule -DisplayName "Ollama-Code" -Direction Inbound -Protocol TCP -LocalPort 11438 -Action Allow -ErrorAction SilentlyContinue | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Regla de firewall creada" -ForegroundColor Green
        } else {
            Write-Host "[!] No se pudo crear regla de firewall automáticamente" -ForegroundColor Yellow
            Write-Host "    Ejecuta manualmente como Administrador:" -ForegroundColor Yellow
            Write-Host "    netsh advfirewall firewall add rule name=`"Ollama-Code`" dir=in action=allow protocol=TCP localport=11438" -ForegroundColor White
        }
    }
} catch {
    Write-Host "[!] Error al configurar firewall: $_" -ForegroundColor Yellow
    Write-Host "    Ejecuta manualmente como Administrador:" -ForegroundColor Yellow
    Write-Host "    netsh advfirewall firewall add rule name=`"Ollama-Code`" dir=in action=allow protocol=TCP localport=11438" -ForegroundColor White
}
Write-Host ""

# Verificar estado
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Ollama-Code configurado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Estado del contenedor:" -ForegroundColor Yellow
docker ps --filter "name=ollama-code" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Descargar modelos de programación:" -ForegroundColor White
Write-Host "     docker exec ollama-code ollama pull deepseek-coder:33b" -ForegroundColor Gray
Write-Host "     docker exec ollama-code ollama pull wizardcoder:34b" -ForegroundColor Gray
Write-Host "     docker exec ollama-code ollama pull codellama:34b" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Verificar modelos instalados:" -ForegroundColor White
Write-Host "     docker exec ollama-code ollama list" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Probar conexión:" -ForegroundColor White
Write-Host "     curl http://localhost:11438/api/tags" -ForegroundColor Gray
Write-Host "     curl http://$ipAddress:11438/api/tags" -ForegroundColor Gray
Write-Host ""
Write-Host "Nota: Los modelos grandes (33B-34B) requieren ~20GB cada uno" -ForegroundColor Yellow
Write-Host "      y tardan varios minutos en descargarse." -ForegroundColor Yellow
Write-Host ""

