#!/bin/bash
# Configura OpenClaw para usar Qwen 2.5 7B (ollama-qwen, puerto 11437)
# Ejecutar en la VM: bash configurar-openclaw-qwen.sh [HOST_IP]
#
# Parámetros:
#   HOST_IP - IP del host donde corre Ollama (default: 10.0.2.2 para VirtualBox NAT)

set -e

HOST_IP="${1:-10.0.2.2}"
PORT="11437"
MODEL_ID="qwen2.5:7b"
# IMPORTANTE: Usar provider "ollama" (no custom-*). El provider ollama tiene soporte
# correcto para tool calling; los custom providers no pasan tools a Ollama.
PROVIDER_ID="ollama"
BASE_URL="http://${HOST_IP}:${PORT}/v1"

OPENCLAW_DIR="$HOME/.openclaw"
OPENCLAW_FILE="$OPENCLAW_DIR/openclaw.json"
AUTH_PROFILES_FILE="$OPENCLAW_DIR/agents/main/agent/auth-profiles.json"
BACKUP_DIR="$OPENCLAW_DIR/backup"

echo "========================================="
echo "Configurar OpenClaw con Qwen 2.5 7B"
echo "========================================="
echo ""
echo "Host IP: $HOST_IP"
echo "Puerto:  $PORT (ollama-qwen)"
echo "Modelo:  $MODEL_ID"
echo ""

# Verificar conectividad
echo "[0/5] Verificando conectividad a Ollama..."
if curl -s -f --connect-timeout 5 "http://${HOST_IP}:${PORT}/api/tags" > /dev/null 2>&1; then
    echo "[OK] Ollama responde en ${HOST_IP}:${PORT}"
else
    echo "[!] No se pudo conectar a http://${HOST_IP}:${PORT}/api/tags"
    echo "    Verifica que Docker y ollama-qwen estén corriendo en el host."
    echo "    Para VirtualBox: usa 10.0.2.2"
    read -p "¿Continuar de todos modos? (s/N): " respuesta
    if [ "$respuesta" != "s" ] && [ "$respuesta" != "S" ]; then
        exit 1
    fi
fi
echo ""

# Backup
echo "[1/5] Creando backup..."
mkdir -p "$BACKUP_DIR"
if [ -f "$OPENCLAW_FILE" ]; then
    cp "$OPENCLAW_FILE" "$BACKUP_DIR/openclaw.json.$(date +%Y%m%d_%H%M%S)"
    echo "[OK] Backup de openclaw.json creado"
else
    echo "[!] openclaw.json no existe, se creará"
fi
if [ -f "$AUTH_PROFILES_FILE" ]; then
    cp "$AUTH_PROFILES_FILE" "$BACKUP_DIR/auth-profiles.json.$(date +%Y%m%d_%H%M%S)"
fi
mkdir -p "$(dirname "$AUTH_PROFILES_FILE")"
echo ""

# Actualizar openclaw.json
echo "[2/5] Añadiendo provider Qwen a openclaw.json..."

python3 << EOF
import json
import os

openclaw_file = os.path.expanduser("$OPENCLAW_FILE")
provider_id = "$PROVIDER_ID"
base_url = "$BASE_URL"
model_id = "$MODEL_ID"

# Cargar o crear config
if os.path.exists(openclaw_file):
    with open(openclaw_file, 'r') as f:
        config = json.load(f)
else:
    config = {}

# Asegurar estructura models.providers
if "models" not in config:
    config["models"] = {}
if "providers" not in config["models"]:
    config["models"]["providers"] = {}

# Añadir/actualizar provider ollama (requiere api para tool calling)
config["models"]["providers"][provider_id] = {
    "baseUrl": base_url,
    "apiKey": "ollama-local",
    "api": "openai-completions",
    "models": [
        {
            "id": model_id,
            "name": "Qwen 2.5 7B",
            "contextWindow": 32768,
            "maxTokens": 8192,
            "input": ["text"],
            "cost": {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0},
            "reasoning": False
        }
    ]
}

# Establecer modelo primario
if "agents" not in config:
    config["agents"] = {}
if "defaults" not in config["agents"]:
    config["agents"]["defaults"] = {}
if "model" not in config["agents"]["defaults"]:
    config["agents"]["defaults"]["model"] = {}

config["agents"]["defaults"]["model"]["primary"] = f"{provider_id}/{model_id}"

with open(openclaw_file, 'w') as f:
    json.dump(config, f, indent=2)

print(f"[OK] Provider {provider_id} añadido, modelo primario: {provider_id}/{model_id}")
EOF

if [ $? -ne 0 ]; then
    echo "[X] Error al actualizar openclaw.json"
    exit 1
fi
echo ""

# Actualizar auth-profiles.json
echo "[3/5] Actualizando auth-profiles.json..."

python3 << EOF
import json
import os

auth_file = os.path.expanduser("$AUTH_PROFILES_FILE")
provider_id = "$PROVIDER_ID"

if os.path.exists(auth_file):
    with open(auth_file, 'r') as f:
        auth = json.load(f)
else:
    auth = {}

auth[provider_id] = {"apiKey": "ollama-local"}

os.makedirs(os.path.dirname(auth_file), exist_ok=True)
with open(auth_file, 'w') as f:
    json.dump(auth, f, indent=2)

print(f"[OK] apiKey configurado para {provider_id}")
EOF

if [ $? -ne 0 ]; then
    echo "[X] Error al actualizar auth-profiles.json"
    exit 1
fi
echo ""

# Validar
echo "[4/5] Validando configuración..."
python3 -m json.tool "$OPENCLAW_FILE" > /dev/null && echo "[OK] openclaw.json válido" || {
    echo "[X] openclaw.json inválido"
    exit 1
}
python3 -m json.tool "$AUTH_PROFILES_FILE" > /dev/null && echo "[OK] auth-profiles.json válido" || {
    echo "[X] auth-profiles.json inválido"
    exit 1
}
echo ""

# Resumen
echo "[5/5] Resumen"
echo "========================================="
echo "[OK] OpenClaw configurado con Qwen 2.5 7B"
echo "========================================="
echo ""
echo "Provider:  $PROVIDER_ID"
echo "URL:       $BASE_URL"
echo "Modelo:    $MODEL_ID"
echo ""
echo "Reinicia el gateway para aplicar:"
echo "  # Si está en foreground: Ctrl+C y luego"
echo "  openclaw gateway"
echo ""
echo "Verificación:"
echo "  openclaw doctor"
echo "  openclaw models list"
echo ""
