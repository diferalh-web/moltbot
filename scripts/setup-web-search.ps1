# Script para configurar servicio de búsqueda web
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar Servicio de Búsqueda Web" -ForegroundColor Cyan
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

# Crear directorio para servidor de búsqueda
Write-Host "[3/6] Creando servidor de búsqueda web..." -ForegroundColor Yellow
$webSearchPath = "${env:USERPROFILE}\web-search-data"
New-Item -ItemType Directory -Force -Path $webSearchPath | Out-Null

# Copiar archivo del servidor (si existe en el proyecto)
$sourceServerFile = ".\web-search-data\web_search_server.py"
if (Test-Path $sourceServerFile) {
    Copy-Item -Path $sourceServerFile -Destination "$webSearchPath\web_search_server.py" -Force
    Write-Host "[OK] Archivo del servidor copiado" -ForegroundColor Green
} else {
    Write-Host "[!] Archivo web_search_server.py no encontrado en .\web-search-data\" -ForegroundColor Yellow
    Write-Host "    El contenedor creará el archivo automáticamente" -ForegroundColor Yellow
}
Write-Host ""

# Crear contenedor web-search
Write-Host "[4/6] Creando contenedor web-search..." -ForegroundColor Yellow

# Detener y eliminar si existe
docker stop web-search 2>$null | Out-Null
docker rm web-search 2>$null | Out-Null

# Leer API key de Tavily si existe
$tavilyKey = $env:TAVILY_API_KEY
if (-not $tavilyKey) {
    Write-Host "[!] TAVILY_API_KEY no configurada (opcional)" -ForegroundColor Yellow
    Write-Host "    DuckDuckGo funcionará sin API key" -ForegroundColor Yellow
}

# Crear nuevo contenedor
docker run -d `
  --name web-search `
  -p 5003:5003 `
  -v "${env:USERPROFILE}/web-search-data:/app" `
  --restart unless-stopped `
  -e PORT=5003 `
  -e TAVILY_API_KEY=$tavilyKey `
  -w /app `
  python:3.11-slim `
  bash -c "apt-get update && apt-get install -y git curl && pip install --no-cache-dir flask flask-cors requests duckduckgo-search tavily-python && python /app/web_search_server.py"

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Contenedor web-search creado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "[5/6] Esperando a que el servicio inicie (10 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Configurar firewall
Write-Host "[6/6] Configurando firewall para puerto 5003..." -ForegroundColor Yellow
try {
    $existingRule = Get-NetFirewallRule -DisplayName "Web-Search" -ErrorAction SilentlyContinue
    if ($existingRule) {
        Write-Host "[OK] Regla de firewall ya existe" -ForegroundColor Green
    } else {
        New-NetFirewallRule -DisplayName "Web-Search" -Direction Inbound -Protocol TCP -LocalPort 5003 -Action Allow -ErrorAction SilentlyContinue | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Regla de firewall creada" -ForegroundColor Green
        } else {
            Write-Host "[!] No se pudo crear regla de firewall automáticamente" -ForegroundColor Yellow
            Write-Host "    Ejecuta manualmente como Administrador:" -ForegroundColor Yellow
            Write-Host "    netsh advfirewall firewall add rule name=`"Web-Search`" dir=in action=allow protocol=TCP localport=5003" -ForegroundColor White
        }
    }
} catch {
    Write-Host "[!] Error al configurar firewall: $_" -ForegroundColor Yellow
    Write-Host "    Ejecuta manualmente como Administrador:" -ForegroundColor Yellow
    Write-Host "    netsh advfirewall firewall add rule name=`"Web-Search`" dir=in action=allow protocol=TCP localport=5003" -ForegroundColor White
}
Write-Host ""

# Verificar estado
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Servicio de Búsqueda Web configurado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Estado del contenedor:" -ForegroundColor Yellow
docker ps --filter "name=web-search" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Verificar que el servicio está funcionando:" -ForegroundColor White
Write-Host "     curl http://localhost:5003/health" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Probar búsqueda web:" -ForegroundColor White
Write-Host "     curl -X POST http://localhost:5003/api/search -H 'Content-Type: application/json' -d '{\"query\":\"IA local\",\"provider\":\"duckduckgo\"}'" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Ver proveedores disponibles:" -ForegroundColor White
Write-Host "     curl http://localhost:5003/api/providers" -ForegroundColor Gray
Write-Host ""
Write-Host "Nota: Para usar Tavily, configura la variable de entorno TAVILY_API_KEY" -ForegroundColor Yellow
Write-Host ""

