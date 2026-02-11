#!/bin/bash
# Script para corregir la configuración para usar Mistral en el puerto 11436
# Ejecutar: cd /media/sf_shareFolder && chmod +x corregir-config-mistral.sh && ./corregir-config-mistral.sh

set -uo pipefail

HOST_IP="192.168.100.42"
MISTRAL_PORT="11436"
BASE_URL="http://${HOST_IP}:${MISTRAL_PORT}/v1"
MODEL_NAME="mistral"

AGENT_DIR="$HOME/.openclaw/agents/main/agent"
BACKUP_DIR="$HOME/.openclaw/backup"

echo "========================================="
echo "Corregir Configuración - Mistral"
echo "========================================="
echo ""

# Crear backups
mkdir -p "$BACKUP_DIR"
if [ -f "$AGENT_DIR/config.json" ]; then
    cp "$AGENT_DIR/config.json" "$BACKUP_DIR/config.json.$(date +%Y%m%d_%H%M%S)"
    echo "[OK] Backup de config.json creado"
fi

if [ -f "$AGENT_DIR/models.json" ]; then
    cp "$AGENT_DIR/models.json" "$BACKUP_DIR/models.json.$(date +%Y%m%d_%H%M%S)"
    echo "[OK] Backup de models.json creado"
fi

echo ""

# ============================================
# Corregir config.json
# ============================================
echo "[1/2] Corrigiendo config.json..."

python3 << PYTHON_SCRIPT
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
print(f"  - Modelo: $MODEL_NAME")
print(f"  - URL: $BASE_URL")
PYTHON_SCRIPT

if [ $? -ne 0 ]; then
    echo "[X] Error al actualizar config.json"
    exit 1
fi

echo ""

# ============================================
# Corregir models.json
# ============================================
echo "[2/2] Corrigiendo models.json..."

python3 << PYTHON_SCRIPT
import json
import os

agent_dir = os.path.expanduser("$AGENT_DIR")
models_file = os.path.join(agent_dir, "models.json")

# Leer el archivo actual
try:
    with open(models_file, 'r') as f:
        data = json.load(f)
except FileNotFoundError:
    data = {}

# Asegurar que existe la estructura
if "providers" not in data:
    data["providers"] = {}

if "ollama" not in data["providers"]:
    data["providers"]["ollama"] = {}

# Actualizar configuración de Ollama para Mistral
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

# Guardar
with open(models_file, 'w') as f:
    json.dump(data, f, indent=2)

print("[OK] models.json actualizado")
print(f"  - baseUrl: $BASE_URL")
print(f"  - modelo: $MODEL_NAME")
PYTHON_SCRIPT

if [ $? -ne 0 ]; then
    echo "[X] Error al actualizar models.json"
    exit 1
fi

echo ""

# Validar JSON
echo "Validando JSON..."
python3 -m json.tool "$AGENT_DIR/config.json" > /dev/null && echo "[OK] config.json válido" || echo "[X] Error en config.json"
python3 -m json.tool "$AGENT_DIR/models.json" > /dev/null && echo "[OK] models.json válido" || echo "[X] Error en models.json"

echo ""
echo "========================================="
echo "[OK] Configuración corregida"
echo "========================================="
echo ""
echo "Configuración actualizada:"
echo "  - Modelo: $MODEL_NAME"
echo "  - URL: $BASE_URL"
echo "  - Puerto: $MISTRAL_PORT (correcto para Mistral)"
echo ""
echo "Prueba Moltbot:"
echo "  cd ~/moltbot"
echo "  pnpm start agent --session-id test --message 'hola' --local"
echo ""












