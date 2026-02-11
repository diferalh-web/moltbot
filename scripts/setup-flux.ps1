# Script para configurar Ollama-Flux para generación de imágenes
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar Ollama-Flux (Generación de Imágenes)" -ForegroundColor Cyan
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
    $nvidiaSmi = nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>$null
    if ($nvidiaSmi) {
        Write-Host "[OK] GPU detectada: $nvidiaSmi" -ForegroundColor Green
        $memory = ($nvidiaSmi -split ',')[1].Trim()
        Write-Host "[!] Flux requiere ~16GB VRAM. Tu GPU tiene: $memory" -ForegroundColor Yellow
    } else {
        Write-Host "[!] GPU NVIDIA no detectada" -ForegroundColor Yellow
        Write-Host "[!] Flux requiere GPU con al menos 16GB VRAM" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[!] nvidia-smi no disponible" -ForegroundColor Yellow
    Write-Host "[!] Flux requiere GPU con al menos 16GB VRAM" -ForegroundColor Red
    exit 1
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

# Crear contenedor ollama-flux
Write-Host "[4/6] Creando contenedor ollama-flux..." -ForegroundColor Yellow

# Detener y eliminar si existe
docker stop ollama-flux 2>$null | Out-Null
docker rm ollama-flux 2>$null | Out-Null

# Crear nuevo contenedor
docker run -d `
  --name ollama-flux `
  -p 11439:11434 `
  -v "${env:USERPROFILE}/ollama-flux-data:/root/.ollama" `
  --restart unless-stopped `
  --gpus all `
  -e OLLAMA_HOST=0.0.0.0:11434 `
  ollama/ollama:latest

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Contenedor ollama-flux creado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "[5/6] Esperando a que Ollama inicie (20 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Configurar firewall
Write-Host "[6/6] Configurando firewall para puerto 11439..." -ForegroundColor Yellow
try {
    $existingRule = Get-NetFirewallRule -DisplayName "Ollama-Flux" -ErrorAction SilentlyContinue
    if ($existingRule) {
        Write-Host "[OK] Regla de firewall ya existe" -ForegroundColor Green
    } else {
        New-NetFirewallRule -DisplayName "Ollama-Flux" -Direction Inbound -Protocol TCP -LocalPort 11439 -Action Allow -ErrorAction SilentlyContinue | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Regla de firewall creada" -ForegroundColor Green
        } else {
            Write-Host "[!] No se pudo crear regla de firewall automáticamente" -ForegroundColor Yellow
            Write-Host "    Ejecuta manualmente como Administrador:" -ForegroundColor Yellow
            Write-Host "    netsh advfirewall firewall add rule name=`"Ollama-Flux`" dir=in action=allow protocol=TCP localport=11439" -ForegroundColor White
        }
    }
} catch {
    Write-Host "[!] Error al configurar firewall: $_" -ForegroundColor Yellow
    Write-Host "    Ejecuta manualmente como Administrador:" -ForegroundColor Yellow
    Write-Host "    netsh advfirewall firewall add rule name=`"Ollama-Flux`" dir=in action=allow protocol=TCP localport=11439" -ForegroundColor White
}
Write-Host ""

# Verificar estado
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Ollama-Flux configurado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Estado del contenedor:" -ForegroundColor Yellow
docker ps --filter "name=ollama-flux" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Descargar modelo Flux (esto puede tardar 30-60 minutos):" -ForegroundColor White
Write-Host "     docker exec ollama-flux ollama pull flux" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Verificar modelo instalado:" -ForegroundColor White
Write-Host "     docker exec ollama-flux ollama list" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Probar generación de imagen:" -ForegroundColor White
Write-Host "     curl http://localhost:11439/api/generate -d '{\"model\":\"flux\",\"prompt\":\"a beautiful sunset\",\"stream\":false}'" -ForegroundColor Gray
Write-Host ""
Write-Host "Nota: El modelo Flux requiere ~12GB de espacio en disco" -ForegroundColor Yellow
Write-Host "      y ~16GB VRAM para funcionar correctamente." -ForegroundColor Yellow
Write-Host ""

