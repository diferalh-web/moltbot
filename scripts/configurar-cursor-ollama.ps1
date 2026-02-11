# Script para configurar Cursor IDE con modelos Ollama en Docker
# Ejecutar en PowerShell

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar Cursor para Ollama Docker" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que Docker está corriendo
Write-Host "[1/6] Verificando Docker..." -ForegroundColor Yellow
$dockerRunning = docker ps 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Docker no está corriendo" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Docker está corriendo" -ForegroundColor Green
Write-Host ""

# Verificar contenedores de Ollama
Write-Host "[2/6] Verificando contenedores de Ollama..." -ForegroundColor Yellow
$containers = @(
    @{Name="ollama-code"; Port=11438; Description="IA de Programación"},
    @{Name="ollama-mistral"; Port=11436; Description="LLM General"},
    @{Name="ollama-qwen"; Port=11437; Description="LLM Alternativo"}
)

$runningContainers = @()
foreach ($container in $containers) {
    $status = docker ps --filter "name=$($container.Name)" --format "{{.Names}}" 2>$null
    if ($status -eq $container.Name) {
        Write-Host "  [OK] $($container.Name) - Puerto $($container.Port)" -ForegroundColor Green
        $runningContainers += $container
    } else {
        Write-Host "  [!] $($container.Name) no está corriendo" -ForegroundColor Yellow
    }
}

if ($runningContainers.Count -eq 0) {
    Write-Host "[X] No hay contenedores de Ollama corriendo" -ForegroundColor Red
    Write-Host "    Ejecuta: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Verificar modelos disponibles
Write-Host "[3/6] Verificando modelos disponibles..." -ForegroundColor Yellow
$models = @{}

foreach ($container in $runningContainers) {
    Write-Host "  Modelos en $($container.Name):" -ForegroundColor Gray
    $modelList = docker exec $container.Name ollama list 2>$null
    if ($LASTEXITCODE -eq 0) {
        $modelNames = $modelList | Select-String -Pattern "^\w" | ForEach-Object { $_.Line.Split()[0] }
        $models[$container.Name] = $modelNames
        foreach ($model in $modelNames) {
            Write-Host "    - $model" -ForegroundColor White
        }
    } else {
        Write-Host "    [!] No se pudieron obtener modelos" -ForegroundColor Yellow
    }
}
Write-Host ""

# Probar conexiones
Write-Host "[4/6] Probando conexiones..." -ForegroundColor Yellow
foreach ($container in $runningContainers) {
    $url = "http://localhost:$($container.Port)/api/tags"
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-Host "  [OK] $($container.Name) responde en puerto $($container.Port)" -ForegroundColor Green
    } catch {
        Write-Host "  [!] $($container.Name) no responde en puerto $($container.Port)" -ForegroundColor Yellow
    }
}
Write-Host ""

# Mostrar configuración recomendada
Write-Host "[5/6] Configuración recomendada para Cursor:" -ForegroundColor Yellow
Write-Host ""

# Recomendación para desarrollo de código
if ($models.ContainsKey("ollama-code")) {
    $codeModel = $models["ollama-code"][0]
    Write-Host "  Para DESARROLLO DE CÓDIGO (recomendado):" -ForegroundColor Cyan
    Write-Host '  {' -ForegroundColor Gray
    Write-Host '    "cursor.modelBaseUrl": "http://localhost:11438",' -ForegroundColor White
    Write-Host ('    "cursor.model": "' + $codeModel + '",') -ForegroundColor White
    Write-Host '    "cursor.apiKey": "ollama"' -ForegroundColor White
    Write-Host '  }' -ForegroundColor Gray
    Write-Host ""
}

# Recomendación para chat general
if ($models.ContainsKey("ollama-mistral")) {
    Write-Host "  Para CHAT GENERAL:" -ForegroundColor Cyan
    Write-Host '  {' -ForegroundColor Gray
    Write-Host '    "cursor.modelBaseUrl": "http://localhost:11436",' -ForegroundColor White
    Write-Host '    "cursor.model": "mistral:latest",' -ForegroundColor White
    Write-Host '    "cursor.apiKey": "ollama"' -ForegroundColor White
    Write-Host '  }' -ForegroundColor Gray
    Write-Host ""
}

# Instrucciones
Write-Host "[6/6] Instrucciones:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Abre Cursor Settings:" -ForegroundColor White
Write-Host "     - Presiona Ctrl + ," -ForegroundColor Gray
Write-Host "     - O File → Preferences → Settings" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Abre settings.json:" -ForegroundColor White
Write-Host "     - Presiona Ctrl + Shift + P" -ForegroundColor Gray
Write-Host "     - Escribe: Preferences: Open User Settings (JSON)" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Agrega la configuración mostrada arriba" -ForegroundColor White
Write-Host ""
Write-Host "  4. Si Cursor requiere /v1, usa:" -ForegroundColor White
Write-Host '     "cursor.modelBaseUrl": "http://localhost:11438/v1"' -ForegroundColor Gray
Write-Host ""

# Crear archivo de configuración de ejemplo
$configFile = "cursor-ollama-config.json"
Write-Host "  Creando archivo de ejemplo: $configFile" -ForegroundColor Yellow

$exampleConfig = @{
    "cursor.modelBaseUrl" = "http://localhost:11438"
    "cursor.model" = if ($models.ContainsKey("ollama-code")) { $models["ollama-code"][0] } else { "deepseek-coder:33b" }
    "cursor.apiKey" = "ollama"
    "cursor.modelTimeout" = 60000
    "cursor.modelRetry" = 3
}

$exampleConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath $configFile -Encoding UTF8
Write-Host "  [OK] Archivo creado: $configFile" -ForegroundColor Green
Write-Host "     Copia el contenido a tu settings.json de Cursor" -ForegroundColor Gray
Write-Host ""

# Resumen
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Resumen" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Contenedores activos: $($runningContainers.Count)" -ForegroundColor White
foreach ($container in $runningContainers) {
    $modelCount = if ($models.ContainsKey($container.Name)) { $models[$container.Name].Count } else { 0 }
    Write-Host ('  - ' + $container.Name + ': ' + $modelCount + ' modelo(s) en puerto ' + $container.Port) -ForegroundColor Gray
}
Write-Host ""
Write-Host 'Siguiente paso:' -ForegroundColor Yellow
Write-Host '  1. Abre Cursor Settings (JSON)' -ForegroundColor White
Write-Host ('  2. Copia la configuracion de ' + $configFile) -ForegroundColor White
Write-Host '  3. Reinicia Cursor si es necesario' -ForegroundColor White
Write-Host ""

