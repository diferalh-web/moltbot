#!/bin/bash
# Script para corregir la configuración - Verifica ambos puertos y corrige según lo que esté disponible
# Ejecutar desde la VM: cd /media/sf_shareFolder && chmod +x corregir-config-ollama-llama2.sh && ./corregir-config-ollama-llama2.sh

set -uo pipefail

HOST_IP="192.168.100.42"

# Verificar qué puerto/modelo está disponible
echo "Verificando qué modelo está disponible..."

# Probar puerto 11436 (Mistral)
if timeout 3 bash -c "echo > /dev/tcp/$HOST_IP/11436" 2>/dev/null; then
    MISTRAL_RESPONSE=$(curl -s -m 5 "http://${HOST_IP}:11436/v1/models" 2>&1)
    if echo "$MISTRAL_RESPONSE" | grep -qi "mistral\|model"; then
        OLLAMA_PORT="11436"
        BASE_URL="http://${HOST_IP}:${OLLAMA_PORT}/v1"
        MODEL_NAME="mistral"
        echo "[OK] Mistral está disponible en puerto 11436"
    fi
fi

# Si Mistral no está disponible, probar puerto 11435 (llama2)
if [ -z "${MODEL_NAME:-}" ]; then
    if timeout 3 bash -c "echo > /dev/tcp/$HOST_IP/11435" 2>/dev/null; then
        LLAMA_RESPONSE=$(curl -s -m 5 "http://${HOST_IP}:11435/api/tags" 2>&1)
        if echo "$LLAMA_RESPONSE" | grep -qi "llama2\|model"; then
            OLLAMA_PORT="11435"
            BASE_URL="http://${HOST_IP}:${OLLAMA_PORT}/v1"
            MODEL_NAME="llama2"
            echo "[OK] llama2 está disponible en puerto 11435"
        fi
    fi
fi

# Si nada está disponible, usar la configuración por defecto (Mistral en 11436)
if [ -z "${MODEL_NAME:-}" ]; then
    OLLAMA_PORT="11436"
    BASE_URL="http://${HOST_IP}:${OLLAMA_PORT}/v1"
    MODEL_NAME="mistral"
    echo "[!] No se pudo verificar, usando configuración por defecto: Mistral en 11436"
fi

AGENT_DIR="$HOME/.openclaw/agents/main/agent"
BACKUP_DIR="$HOME/.openclaw/backup"

echo "========================================="
echo "Corregir Configuración - Ollama llama2"
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

# Actualizar configuración de Ollama
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
        "contextWindow": 4096,
        "maxTokens": 2048
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
echo "  - Puerto: $OLLAMA_PORT (correcto)"
echo ""
echo "Prueba Moltbot:"
echo "  cd ~/moltbot"
echo "  pnpm start agent --session-id test --message 'hola' --local"
echo ""

