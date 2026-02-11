# Script para configurar Ollama con Qwen en Docker (Windows Host)
# Ejecuta este script en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurando Ollama-Qwen en Docker" -ForegroundColor Cyan
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
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*"} | Select-Object -First 1).IPAddress
Write-Host "[OK] IP local: $ipAddress" -ForegroundColor Green
Write-Host ""

# Crear directorio para datos
$ollamaQwenData = "$env:USERPROFILE\ollama-qwen-data"
Write-Host "[3/6] Creando directorio para datos: $ollamaQwenData" -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $ollamaQwenData | Out-Null
Write-Host "[OK] Directorio creado" -ForegroundColor Green
Write-Host ""

# Verificar si el contenedor ya existe
Write-Host "[4/6] Verificando contenedor ollama-qwen..." -ForegroundColor Yellow
$existing = docker ps -a --filter "name=ollama-qwen" --format "{{.Names}}" 2>$null
if ($existing -eq "ollama-qwen") {
    Write-Host "[!] Contenedor ollama-qwen ya existe" -ForegroundColor Yellow
    $response = Read-Host "¿Deseas eliminarlo y crear uno nuevo? (S/N)"
    if ($response -eq "S" -or $response -eq "s" -or $response -eq "Y" -or $response -eq "y") {
        docker stop ollama-qwen 2>$null
        docker rm ollama-qwen 2>$null
        Write-Host "[OK] Contenedor eliminado" -ForegroundColor Green
    } else {
        Write-Host "Usando contenedor existente" -ForegroundColor Gray
        docker start ollama-qwen 2>$null
        Write-Host "[OK] Contenedor iniciado" -ForegroundColor Green
        Write-Host ""
        Write-Host "IP para configurar en Moltbot: http://$ipAddress:11437" -ForegroundColor Cyan
        exit 0
    }
}
Write-Host ""

# Ejecutar Ollama para Qwen (puerto 11437)
Write-Host "[5/6] Ejecutando Ollama-Qwen en Docker (puerto 11437)..." -ForegroundColor Yellow
docker run -d `
  --name ollama-qwen `
  -p 11437:11434 `
  -v "${ollamaQwenData}:/root/.ollama" `
  --restart unless-stopped `
  ollama/ollama:latest

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Ollama-Qwen iniciado en Docker" -ForegroundColor Green
} else {
    Write-Host "[X] Error al iniciar Ollama-Qwen" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Esperando a que Ollama-Qwen esté listo..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Descargar Qwen
Write-Host "[6/6] Descargando modelo Qwen2.5:7b (esto puede tardar varios minutos, ~4.5GB)..." -ForegroundColor Yellow
docker exec ollama-qwen ollama pull qwen2.5:7b

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Qwen2.5:7b descargado correctamente" -ForegroundColor Green
} else {
    Write-Host "[X] Error al descargar Qwen2.5:7b" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Configuración completada!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuración:" -ForegroundColor Yellow
Write-Host "  Contenedor: ollama-qwen" -ForegroundColor Gray
Write-Host "  Puerto: 11437" -ForegroundColor Gray
Write-Host "  URL para Moltbot: http://$ipAddress:11437/v1" -ForegroundColor Cyan
Write-Host ""
Write-Host "Verificar modelos:" -ForegroundColor Yellow
Write-Host "  docker exec ollama-qwen ollama list" -ForegroundColor Gray
Write-Host ""
Write-Host "Probar conexión:" -ForegroundColor Yellow
Write-Host "  curl http://$ipAddress:11437/api/tags" -ForegroundColor Gray
Write-Host ""












