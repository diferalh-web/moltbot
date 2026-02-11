# Script para configurar gateway de APIs externas (Gemini, Hugging Face)
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar Gateway de APIs Externas" -ForegroundColor Cyan
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

# Obtener IP local
Write-Host "[2/6] Obteniendo IP local..." -ForegroundColor Yellow
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -notlike "192.168.56.*" -and $_.IPAddress -notlike "172.20.*"} | Select-Object -First 1).IPAddress
if (-not $ipAddress) {
    $ipAddress = "192.168.100.42"
}
Write-Host "[OK] IP: $ipAddress" -ForegroundColor Green
Write-Host ""

# Crear directorio para gateway
Write-Host "[3/6] Creando gateway de APIs..." -ForegroundColor Yellow
$gatewayPath = "${env:USERPROFILE}\external-apis-data"
New-Item -ItemType Directory -Force -Path $gatewayPath | Out-Null

# Copiar archivo del gateway (si existe en el proyecto)
$sourceGatewayFile = ".\external-apis-data\api_gateway.py"
if (Test-Path $sourceGatewayFile) {
    Copy-Item -Path $sourceGatewayFile -Destination "$gatewayPath\api_gateway.py" -Force
    Write-Host "[OK] Archivo del gateway copiado" -ForegroundColor Green
} else {
    Write-Host "[!] Archivo api_gateway.py no encontrado en .\external-apis-data\" -ForegroundColor Yellow
    Write-Host "    El contenedor creará el archivo automáticamente" -ForegroundColor Yellow
}
Write-Host ""

# Leer API keys (opcionales)
$geminiKey = $env:GEMINI_API_KEY
$huggingfaceKey = $env:HUGGINGFACE_API_KEY

if (-not $geminiKey) {
    Write-Host "[!] GEMINI_API_KEY no configurada (opcional)" -ForegroundColor Yellow
    Write-Host "    Puedes configurarla después con: `$env:GEMINI_API_KEY='tu_key'" -ForegroundColor Yellow
}

if (-not $huggingfaceKey) {
    Write-Host "[!] HUGGINGFACE_API_KEY no configurada (opcional)" -ForegroundColor Yellow
    Write-Host "    Algunos modelos de Hugging Face funcionan sin API key" -ForegroundColor Yellow
}
Write-Host ""

# Crear contenedor external-apis-gateway
Write-Host "[4/6] Creando contenedor external-apis-gateway..." -ForegroundColor Yellow

# Detener y eliminar si existe
docker stop external-apis-gateway 2>$null | Out-Null
docker rm external-apis-gateway 2>$null | Out-Null

# Crear nuevo contenedor
docker run -d `
  --name external-apis-gateway `
  -p 5004:5004 `
  -v "${env:USERPROFILE}/external-apis-data:/app" `
  --restart unless-stopped `
  -e PORT=5004 `
  -e GEMINI_API_KEY=$geminiKey `
  -e HUGGINGFACE_API_KEY=$huggingfaceKey `
  -w /app `
  python:3.11-slim `
  bash -c "apt-get update && apt-get install -y git curl && pip install --no-cache-dir flask flask-cors requests google-generativeai huggingface_hub && python /app/api_gateway.py"

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Contenedor external-apis-gateway creado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "[5/6] Esperando a que el servicio inicie (10 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Configurar firewall
Write-Host "[6/6] Configurando firewall para puerto 5004..." -ForegroundColor Yellow
try {
    $existingRule = Get-NetFirewallRule -DisplayName "External-APIs-Gateway" -ErrorAction SilentlyContinue
    if ($existingRule) {
        Write-Host "[OK] Regla de firewall ya existe" -ForegroundColor Green
    } else {
        New-NetFirewallRule -DisplayName "External-APIs-Gateway" -Direction Inbound -Protocol TCP -LocalPort 5004 -Action Allow -ErrorAction SilentlyContinue | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Regla de firewall creada" -ForegroundColor Green
        } else {
            Write-Host "[!] No se pudo crear regla de firewall automáticamente" -ForegroundColor Yellow
            Write-Host "    Ejecuta manualmente como Administrador:" -ForegroundColor Yellow
            Write-Host "    netsh advfirewall firewall add rule name=`"External-APIs-Gateway`" dir=in action=allow protocol=TCP localport=5004" -ForegroundColor White
        }
    }
} catch {
    Write-Host "[!] Error al configurar firewall: $_" -ForegroundColor Yellow
    Write-Host "    Ejecuta manualmente como Administrador:" -ForegroundColor Yellow
    Write-Host "    netsh advfirewall firewall add rule name=`"External-APIs-Gateway`" dir=in action=allow protocol=TCP localport=5004" -ForegroundColor White
}
Write-Host ""

# Verificar estado
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Gateway de APIs Externas configurado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Estado del contenedor:" -ForegroundColor Yellow
docker ps --filter "name=external-apis-gateway" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Verificar que el servicio está funcionando:" -ForegroundColor White
Write-Host "     curl http://localhost:5004/health" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Ver proveedores disponibles:" -ForegroundColor White
Write-Host "     curl http://localhost:5004/api/providers" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Probar Gemini (requiere API key):" -ForegroundColor White
Write-Host "     curl -X POST http://localhost:5004/api/gemini -H 'Content-Type: application/json' -d '{\"prompt\":\"Hola\",\"model\":\"gemini-pro\"}'" -ForegroundColor Gray
Write-Host ""
Write-Host "  4. Probar Hugging Face:" -ForegroundColor White
Write-Host "     curl -X POST http://localhost:5004/api/huggingface -H 'Content-Type: application/json' -d '{\"model\":\"gpt2\",\"prompt\":\"Hello world\"}'" -ForegroundColor Gray
Write-Host ""
Write-Host "Nota: Configura las API keys como variables de entorno:" -ForegroundColor Yellow
Write-Host "      `$env:GEMINI_API_KEY='tu_key'" -ForegroundColor Gray
Write-Host "      `$env:HUGGINGFACE_API_KEY='tu_key'" -ForegroundColor Gray
Write-Host ""

