# Script para extender Coqui TTS con clonación de voz (XTTS)
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar Clonación de Voz (XTTS)" -ForegroundColor Cyan
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

# Verificar si coqui-tts existe
Write-Host "[2/6] Verificando contenedor Coqui TTS..." -ForegroundColor Yellow
$coquiExists = docker ps -a --filter "name=coqui-tts" --format "{{.Names}}" 2>$null
if ($coquiExists -eq "coqui-tts") {
    Write-Host "[OK] Contenedor coqui-tts encontrado" -ForegroundColor Green
    Write-Host "[!] Se actualizará el servidor TTS con soporte XTTS" -ForegroundColor Yellow
} else {
    Write-Host "[!] Contenedor coqui-tts no encontrado" -ForegroundColor Yellow
    Write-Host "    Ejecuta primero: .\scripts\setup-coqui-tts.ps1" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Crear directorio para servidor TTS actualizado
Write-Host "[3/6] Actualizando servidor TTS con XTTS..." -ForegroundColor Yellow
$ttsServerPath = "${env:USERPROFILE}\coqui-tts-data"
New-Item -ItemType Directory -Force -Path $ttsServerPath | Out-Null

# Copiar archivo del servidor actualizado (si existe en el proyecto)
$sourceServerFile = ".\coqui-tts-data\tts_server.py"
if (Test-Path $sourceServerFile) {
    Copy-Item -Path $sourceServerFile -Destination "$ttsServerPath\tts_server.py" -Force
    Write-Host "[OK] Servidor TTS actualizado con XTTS" -ForegroundColor Green
} else {
    Write-Host "[!] Archivo tts_server.py no encontrado en .\coqui-tts-data\" -ForegroundColor Yellow
    Write-Host "    El contenedor usará el archivo existente" -ForegroundColor Yellow
}
Write-Host ""

# Detener y recrear contenedor con XTTS
Write-Host "[4/6] Recreando contenedor con soporte XTTS..." -ForegroundColor Yellow
docker stop coqui-tts 2>$null | Out-Null
docker rm coqui-tts 2>$null | Out-Null

# Crear nuevo contenedor con XTTS
docker run -d `
  --name coqui-tts `
  -p 5002:5002 `
  -v "${env:USERPROFILE}/coqui-tts-data:/app" `
  -v "${env:USERPROFILE}/coqui-tts-models:/root/.local/share/tts" `
  --restart unless-stopped `
  --gpus all `
  -w /app `
  python:3.11-slim `
  bash -c "apt-get update && apt-get install -y git curl build-essential espeak-ng libespeak-ng-dev portaudio19-dev && pip install --no-cache-dir TTS flask flask-cors torch torchaudio && python /app/tts_server.py"

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Contenedor coqui-tts recreado con XTTS" -ForegroundColor Green
} else {
    Write-Host "[X] Error al recrear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "[5/6] Esperando a que Coqui TTS inicie (60 segundos para cargar modelos)..." -ForegroundColor Yellow
Write-Host "      Nota: XTTS se carga bajo demanda en el primer uso" -ForegroundColor Gray
Start-Sleep -Seconds 60

# Verificar estado
Write-Host "[6/6] Verificando estado..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
docker ps --filter "name=coqui-tts" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Clonación de Voz (XTTS) configurada!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Estado del contenedor:" -ForegroundColor Yellow
docker ps --filter "name=coqui-tts" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Verificar que el servicio está funcionando:" -ForegroundColor White
Write-Host "     curl http://localhost:5002/health" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Ver modelos disponibles (incluyendo XTTS):" -ForegroundColor White
Write-Host "     curl http://localhost:5002/api/models" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Probar clonación de voz:" -ForegroundColor White
Write-Host "     curl -X POST http://localhost:5002/api/clone-voice -H 'Content-Type: application/json' -d '{\"text\":\"Hola mundo\",\"reference_audio_path\":\"/ruta/al/audio.wav\",\"language\":\"es\"}'" -ForegroundColor Gray
Write-Host ""
Write-Host "Nota: XTTS se carga automáticamente en el primer uso de clonación" -ForegroundColor Yellow
Write-Host "      y puede tardar varios minutos la primera vez." -ForegroundColor Yellow
Write-Host ""









