# Script para configurar Coqui TTS para síntesis de voz
# Ejecutar en PowerShell de Windows como Administrador

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurar Coqui TTS (Síntesis de Voz)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Docker
Write-Host "[1/7] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    Write-Host "[OK] Docker instalado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "[X] Docker no está instalado" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Obtener IP local
Write-Host "[2/7] Obteniendo IP local..." -ForegroundColor Yellow
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -notlike "192.168.56.*" -and $_.IPAddress -notlike "172.20.*"} | Select-Object -First 1).IPAddress
if (-not $ipAddress) {
    $ipAddress = "192.168.100.42"
}
Write-Host "[OK] IP: $ipAddress" -ForegroundColor Green
Write-Host ""

# Crear directorio para servidor TTS
Write-Host "[3/7] Creando servidor TTS..." -ForegroundColor Yellow
$ttsServerPath = "${env:USERPROFILE}\coqui-tts-data"
New-Item -ItemType Directory -Force -Path $ttsServerPath | Out-Null

# Crear archivo tts_server.py
$ttsServerContent = @'
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
from TTS.api import TTS
import os
import tempfile
import io

app = Flask(__name__)
CORS(app)

# Inicializar TTS
print("Inicializando Coqui TTS...")
tts = TTS(model_name="tts_models/es/css10/vits", gpu=True)
print("TTS inicializado correctamente")

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok", "service": "coqui-tts"})

@app.route('/api/tts', methods=['POST'])
def generate_speech():
    try:
        data = request.json
        text = data.get('text', '')
        language = data.get('language', 'es')
        voice = data.get('voice', 'default')
        
        if not text:
            return jsonify({"error": "Text is required"}), 400
        
        # Seleccionar modelo según idioma
        if language == 'es':
            model_name = "tts_models/es/css10/vits"
        elif language == 'en':
            model_name = "tts_models/en/ljspeech/tacotron2-DDC"
        else:
            model_name = "tts_models/es/css10/vits"
        
        # Generar audio
        output_path = os.path.join(tempfile.gettempdir(), f"tts_output_{os.getpid()}.wav")
        tts.tts_to_file(text=text, file_path=output_path)
        
        # Leer archivo y enviarlo
        with open(output_path, 'rb') as f:
            audio_data = f.read()
        
        os.remove(output_path)
        
        return send_file(
            io.BytesIO(audio_data),
            mimetype='audio/wav',
            as_attachment=True,
            download_name='output.wav'
        )
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/models', methods=['GET'])
def list_models():
    return jsonify({
        "models": [
            {"id": "es", "name": "Español (CSS10)", "model": "tts_models/es/css10/vits"},
            {"id": "en", "name": "English (LJSpeech)", "model": "tts_models/en/ljspeech/tacotron2-DDC"}
        ]
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=False)
'@

$ttsServerFile = Join-Path $ttsServerPath "tts_server.py"
Set-Content -Path $ttsServerFile -Value $ttsServerContent -Encoding UTF8
Write-Host "[OK] Servidor TTS creado" -ForegroundColor Green
Write-Host ""

# Crear contenedor coqui-tts
Write-Host "[4/7] Creando contenedor coqui-tts..." -ForegroundColor Yellow

# Detener y eliminar si existe
docker stop coqui-tts 2>$null | Out-Null
docker rm coqui-tts 2>$null | Out-Null

# Crear nuevo contenedor
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
    Write-Host "[OK] Contenedor coqui-tts creado" -ForegroundColor Green
} else {
    Write-Host "[X] Error al crear contenedor" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Esperar a que inicie
Write-Host "[5/7] Esperando a que Coqui TTS inicie (60 segundos para descargar modelos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# Configurar firewall
Write-Host "[6/7] Configurando firewall para puerto 5002..." -ForegroundColor Yellow
try {
    $existingRule = Get-NetFirewallRule -DisplayName "Coqui-TTS" -ErrorAction SilentlyContinue
    if ($existingRule) {
        Write-Host "[OK] Regla de firewall ya existe" -ForegroundColor Green
    } else {
        New-NetFirewallRule -DisplayName "Coqui-TTS" -Direction Inbound -Protocol TCP -LocalPort 5002 -Action Allow -ErrorAction SilentlyContinue | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Regla de firewall creada" -ForegroundColor Green
        } else {
            Write-Host "[!] No se pudo crear regla de firewall automáticamente" -ForegroundColor Yellow
            Write-Host "    Ejecuta manualmente como Administrador:" -ForegroundColor Yellow
            Write-Host "    netsh advfirewall firewall add rule name=`"Coqui-TTS`" dir=in action=allow protocol=TCP localport=5002" -ForegroundColor White
        }
    }
} catch {
    Write-Host "[!] Error al configurar firewall: $_" -ForegroundColor Yellow
    Write-Host "    Ejecuta manualmente como Administrador:" -ForegroundColor Yellow
    Write-Host "    netsh advfirewall firewall add rule name=`"Coqui-TTS`" dir=in action=allow protocol=TCP localport=5002" -ForegroundColor White
}
Write-Host ""

# Verificar estado
Write-Host "[7/7] Verificando estado..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
docker ps --filter "name=coqui-tts" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[OK] Coqui TTS configurado!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Estado del contenedor:" -ForegroundColor Yellow
docker ps --filter "name=coqui-tts" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Verificar que el servicio está funcionando:" -ForegroundColor White
Write-Host "     curl http://localhost:5002/health" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Probar síntesis de voz:" -ForegroundColor White
Write-Host "     curl -X POST http://localhost:5002/api/tts -H 'Content-Type: application/json' -d '{\"text\":\"Hola mundo\",\"language\":\"es\"}' --output output.wav" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Ver modelos disponibles:" -ForegroundColor White
Write-Host "     curl http://localhost:5002/api/models" -ForegroundColor Gray
Write-Host ""
Write-Host "Nota: Los modelos de voz se descargan automáticamente en el primer uso" -ForegroundColor Yellow
Write-Host "      y pueden tardar varios minutos." -ForegroundColor Yellow
Write-Host ""

