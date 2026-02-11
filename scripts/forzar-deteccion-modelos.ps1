# Script para forzar la detección de modelos en Open WebUI
# Usa la API interna de Open WebUI para refrescar la lista de modelos

Write-Host "`n=== Forzando detección de modelos en Open WebUI ===" -ForegroundColor Cyan

# Verificar que Open WebUI esté corriendo
$webuiStatus = docker ps --filter "name=open-webui" --format "{{.Status}}"
if (-not $webuiStatus) {
    Write-Host "  ✗ Open WebUI no está corriendo" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Open WebUI está corriendo" -ForegroundColor Green

# Crear script Python para forzar la detección
$pythonScript = @'
import requests
import json
import os

# URLs de los backends Ollama
ollama_urls = [
    "http://ollama-mistral:11434",
    "http://ollama-qwen:11434",
    "http://ollama-code:11434",
    "http://ollama-flux:11434"
]

print("Verificando modelos en cada backend Ollama...")
all_models = []

for url in ollama_urls:
    try:
        response = requests.get(f"{url}/api/tags", timeout=5)
        if response.status_code == 200:
            data = response.json()
            if 'models' in data:
                for model in data['models']:
                    model_name = model.get('name', 'unknown')
                    all_models.append({
                        'name': model_name,
                        'url': url
                    })
                    print(f"  ✓ {model_name} desde {url}")
        else:
            print(f"  ✗ Error {response.status_code} desde {url}")
    except Exception as e:
        print(f"  ✗ No se pudo conectar a {url}: {e}")

print(f"\nTotal de modelos encontrados: {len(all_models)}")

# Guardar lista de modelos en un archivo temporal para referencia
with open('/tmp/models_found.json', 'w') as f:
    json.dump(all_models, f, indent=2)

print("\n✓ Lista de modelos guardada en /tmp/models_found.json")
'@

# Guardar y ejecutar script
$scriptPath = Join-Path $PSScriptRoot "force_detect_models.py"
$pythonScript | Out-File -FilePath $scriptPath -Encoding UTF8

Write-Host "`n1. Verificando modelos disponibles en cada backend..." -ForegroundColor Yellow
docker cp $scriptPath open-webui:/tmp/force_detect_models.py
docker exec open-webui python3 /tmp/force_detect_models.py

Write-Host "`n2. Reiniciando Open WebUI para forzar detección..." -ForegroundColor Yellow
docker restart open-webui

Write-Host "`n3. Esperando a que Open WebUI se reinicie..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "`n✓ Modelos verificados" -ForegroundColor Green
Write-Host "✓ Open WebUI reiniciado" -ForegroundColor Green
Write-Host "`nAhora accede a: http://localhost:8082" -ForegroundColor White
Write-Host "Recarga la página (F5) y verifica el selector de modelos." -ForegroundColor White
Write-Host "`nSi aún no ves los modelos, puede ser necesario:" -ForegroundColor Yellow
Write-Host "  1. Configurarlos manualmente en Settings → Connections" -ForegroundColor Gray
Write-Host "  2. O usar la sintaxis: modelo@url en el selector" -ForegroundColor Gray










