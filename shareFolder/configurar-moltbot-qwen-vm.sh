#!/bin/bash
# Script para configurar Moltbot con Qwen en la VM
# Ejecutar en la terminal SSH de la VM

set -e

HOST_IP="192.168.100.42"
MODEL_NAME="qwen2.5:7b"
PORT="11437"
BASE_URL="http://${HOST_IP}:${PORT}/v1"

echo "========================================="
echo "Configurar Moltbot con Qwen"
echo "========================================="
echo ""

# Verificar que los archivos existen
AGENT_DIR="$HOME/.openclaw/agents/main/agent"
if [ ! -d "$AGENT_DIR" ]; then
    echo "[X] Directorio del agente no existe: $AGENT_DIR"
    exit 1
fi

echo "[1/4] Respaldando archivos de configuración..."
mkdir -p "$HOME/.openclaw/backup"
cp "$AGENT_DIR/models.json" "$HOME/.openclaw/backup/models.json.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
cp "$AGENT_DIR/config.json" "$HOME/.openclaw/backup/config.json.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
echo "[OK] Respaldos creados"
echo ""

echo "[2/4] Actualizando models.json..."
# Crear un archivo temporal con la configuración de Ollama actualizada
python3 << EOF
import json
import sys
import os

agent_dir = os.path.expanduser("$AGENT_DIR")
models_file = os.path.join(agent_dir, "models.json")

# Leer el archivo actual
try:
    with open(models_file, 'r') as f:
        data = json.load(f)
except FileNotFoundError:
    print(f"[X] Archivo no encontrado: {models_file}")
    sys.exit(1)
except json.JSONDecodeError as e:
    print(f"[X] Error al leer JSON: {e}")
    sys.exit(1)

# Actualizar la sección de Ollama
if "providers" not in data:
    data["providers"] = {}

if "ollama" not in data["providers"]:
    data["providers"]["ollama"] = {}

data["providers"]["ollama"]["baseUrl"] = "$BASE_URL"
data["providers"]["ollama"]["api"] = "openai-completions"
data["providers"]["ollama"]["models"] = [
    {
        "id": "$MODEL_NAME",
        "name": "$MODEL_NAME",
        "reasoning": False,
        "input": ["text"],
        "cost": {
            "input": 0,
            "output": 0,
            "cacheRead": 0,
            "cacheWrite": 0
        },
        "contextWindow": 32000,
        "maxTokens": 8192
    }
]
data["providers"]["ollama"]["apiKey"] = "ollama"

# Escribir el archivo actualizado
with open(models_file, 'w') as f:
    json.dump(data, f, indent=2)

print("[OK] models.json actualizado")
EOF

if [ $? -ne 0 ]; then
    echo "[X] Error al actualizar models.json"
    exit 1
fi

echo ""
echo "[3/4] Actualizando config.json..."
python3 << EOF
import json
import os

agent_dir = os.path.expanduser("$AGENT_DIR")
config_file = os.path.join(agent_dir, "config.json")

config = {
    "model": {
        "provider": "ollama",
        "name": "$MODEL_NAME",
        "baseURL": "$BASE_URL"
    }
}

with open(config_file, 'w') as f:
    json.dump(config, f, indent=4)

print("[OK] config.json actualizado")
EOF

if [ $? -ne 0 ]; then
    echo "[X] Error al actualizar config.json"
    exit 1
fi

echo ""
echo "[4/4] Validando JSON..."
python3 -m json.tool "$AGENT_DIR/models.json" > /dev/null && echo "[OK] models.json válido" || echo "[X] Error en models.json"
python3 -m json.tool "$AGENT_DIR/config.json" > /dev/null && echo "[OK] config.json válido" || echo "[X] Error en config.json"

echo ""
echo "========================================="
echo "[OK] Configuración completada!"
echo "========================================="
echo ""
echo "Configuración:"
echo "  Modelo: $MODEL_NAME"
echo "  URL: $BASE_URL"
echo ""
echo "Prueba con:"
echo "  cd ~/moltbot"
echo "  pnpm start agent --session-id test-session --message 'hola' --local"
echo ""

