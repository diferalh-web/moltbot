# Script para instalar ComfyUI-Crystools (barra de progreso + resaltado de nodos)
# La nueva interfaz de ComfyUI no muestra progreso por defecto; Crystools lo corrige.
# Uso: .\scripts\setup-comfyui-crystools.ps1

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Instalar ComfyUI-Crystools" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Crystools agrega:" -ForegroundColor Gray
Write-Host "  - Barra de progreso en el menu superior" -ForegroundColor Gray
Write-Host "  - Tiempo transcurrido al finalizar" -ForegroundColor Gray
Write-Host "  - Clic en la barra para ver el nodo actual" -ForegroundColor Gray
Write-Host "  - Monitor de recursos (CPU, GPU, RAM, VRAM)" -ForegroundColor Gray
Write-Host ""

$comfyuiData = "${env:USERPROFILE}\comfyui-data"
$customNodesPath = Join-Path $comfyuiData "custom_nodes"
$crystoolsPath = Join-Path $customNodesPath "comfyui-crystools"

# 1. Verificar directorio custom_nodes
Write-Host "[1/3] Verificando directorios..." -ForegroundColor Yellow
if (!(Test-Path $comfyuiData)) {
    New-Item -ItemType Directory -Force -Path $comfyuiData | Out-Null
}
if (!(Test-Path $customNodesPath)) {
    New-Item -ItemType Directory -Force -Path $customNodesPath | Out-Null
}
Write-Host "  [OK] $customNodesPath" -ForegroundColor Green
Write-Host ""

# 2. Instalar/actualizar ComfyUI-Crystools
Write-Host "[2/3] Instalando ComfyUI-Crystools..." -ForegroundColor Yellow
if (Test-Path $crystoolsPath) {
    Write-Host "  [!] Crystools ya existe, actualizando..." -ForegroundColor Yellow
    Push-Location $crystoolsPath
    git pull 2>$null
    if ($LASTEXITCODE -eq 0) { Write-Host "  [OK] Actualizado" -ForegroundColor Green } else { Write-Host "  [!] git pull fallo, continuando..." -ForegroundColor Yellow }
    Pop-Location
} else {
    if (!(Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "  [X] git no encontrado. Instala Git o ejecuta manualmente:" -ForegroundColor Red
        Write-Host "      cd $customNodesPath" -ForegroundColor Gray
        Write-Host "      git clone https://github.com/crystian/comfyui-crystools.git" -ForegroundColor Gray
        exit 1
    }
    Push-Location $customNodesPath
    git clone https://github.com/crystian/comfyui-crystools.git
    Pop-Location
    Write-Host "  [OK] ComfyUI-Crystools clonado" -ForegroundColor Green
}
Write-Host ""

# 3. Instalar dependencias Python (dentro del contenedor si ComfyUI corre en Docker)
Write-Host "[3/3] Instalando dependencias..." -ForegroundColor Yellow
$crystoolsRequirements = Join-Path $crystoolsPath "requirements.txt"
if (Test-Path $crystoolsRequirements) {
    # Intentar instalar en el contenedor Docker si existe
    $dockerRunning = docker ps --filter "name=comfyui" --format "{{.Names}}" 2>$null
    if ($dockerRunning -eq "comfyui") {
        Write-Host "  Detectado ComfyUI en Docker, instalando dependencias dentro del contenedor..." -ForegroundColor Gray
        docker exec comfyui pip install --no-cache-dir -r /root/ComfyUI/custom_nodes/comfyui-crystools/requirements.txt 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-Host "  [OK] Dependencias instaladas" -ForegroundColor Green } else { Write-Host "  [!] Verifica: docker exec comfyui pip install -r /root/ComfyUI/custom_nodes/comfyui-crystools/requirements.txt" -ForegroundColor Yellow }
    } else {
        Write-Host "  [!] ComfyUI no esta corriendo. Al reiniciar, las dependencias se instalaran automaticamente." -ForegroundColor Yellow
        Write-Host "      O ejecuta: docker exec comfyui pip install -r /root/ComfyUI/custom_nodes/comfyui-crystools/requirements.txt" -ForegroundColor Gray
    }
} else {
    Write-Host "  [!] requirements.txt no encontrado, omitiendo" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] ComfyUI-Crystools instalado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Reinicia ComfyUI: docker restart comfyui" -ForegroundColor White
Write-Host "  2. Recarga la pagina (F5) en http://localhost:7860" -ForegroundColor White
Write-Host "  3. La barra de progreso aparecera en la parte superior del menu" -ForegroundColor White
Write-Host ""
Write-Host "Alternativa (interfaz antigua):" -ForegroundColor Gray
Write-Host "  Settings (engranaje) -> Comfy -> Menu -> Use new menu: disabled" -ForegroundColor Gray
Write-Host "  La interfaz antigua puede mostrar progreso de otra forma." -ForegroundColor Gray
Write-Host ""
