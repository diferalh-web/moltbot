#!/bin/bash

# Configura OpenClaw para desarrollo autónomo
# Fusiona la plantilla openclaw-desarrollo con la config existente
# Ejecutar en la VM: bash configurar-openclaw-desarrollo.sh [HOST_IP] [BRAVE_API_KEY]
#
# Parámetros (opcionales):
#   HOST_IP      - IP del host donde corre Ollama (default: 192.168.100.42)
#   BRAVE_API_KEY - API key de Brave Search (se puede configurar después con openclaw configure --section web)

set -e

HOST_IP="${1:-192.168.100.42}"
BRAVE_API_KEY="${2:-}"

OPENCLAW_DIR="$HOME/.openclaw"
OPENCLAW_FILE="$OPENCLAW_DIR/openclaw.json"
BACKUP_DIR="$OPENCLAW_DIR/backup"

# Ubicación del template (puede estar en shareFolder o en el mismo directorio)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_FILE="$SCRIPT_DIR/openclaw-desarrollo.json.template"

if [ ! -f "$TEMPLATE_FILE" ]; then
    TEMPLATE_FILE="$HOME/scripts/openclaw-desarrollo.json.template"
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "[X] No se encontró openclaw-desarrollo.json.template"
    echo "    Buscado en: $SCRIPT_DIR y ~/scripts"
    exit 1
fi

echo "========================================="
echo "Configurar OpenClaw para desarrollo"
echo "========================================="
echo ""
echo "HOST_IP (Ollama): $HOST_IP"
echo "BRAVE_API_KEY: ${BRAVE_API_KEY:+configurada}${BRAVE_API_KEY:-no configurada}"
echo ""

# Crear directorio y backup
mkdir -p "$BACKUP_DIR"

if [ -f "$OPENCLAW_FILE" ]; then
    BACKUP_FILE="$BACKUP_DIR/openclaw.json.$(date +%Y%m%d_%H%M%S)"
    cp "$OPENCLAW_FILE" "$BACKUP_FILE"
    echo "[1/4] Backup creado: $BACKUP_FILE"
else
    echo "[1/4] No existe openclaw.json previo, se creará uno nuevo"
    mkdir -p "$OPENCLAW_DIR"
fi
echo ""

# Fusionar template con config existente
echo "[2/4] Fusionando configuración de desarrollo..."

python3 << EOF
import json
import os

openclaw_file = os.path.expanduser("$OPENCLAW_FILE")
template_file = "$TEMPLATE_FILE"
host_ip = "$HOST_IP"

def deep_merge(base, overlay):
    """Merge overlay into base recursively. Overlay wins on conflict."""
    result = dict(base)
    for key, value in overlay.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = deep_merge(result[key], value)
        else:
            result[key] = value
    return result

# Cargar template
with open(template_file, 'r') as f:
    template = json.load(f)

# Cargar config existente o crear mínima
if os.path.exists(openclaw_file):
    with open(openclaw_file, 'r') as f:
        config = json.load(f)
else:
    config = {}

# Fusionar (template se aplica sobre config, template tiene prioridad en desarrollo)
config = deep_merge(config, template)

# Asegurar que models/providers/ollama tenga la URL correcta si existe
if "models" in config and "providers" in config.get("models", {}):
    if "ollama" in config["models"]["providers"]:
        base_url = f"http://{host_ip}:11436/v1"
        config["models"]["providers"]["ollama"]["baseUrl"] = base_url
        print(f"  Ollama baseUrl: {base_url}")

# Guardar
with open(openclaw_file, 'w') as f:
    json.dump(config, f, indent=2)

print("[OK] Configuración fusionada")
EOF

if [ $? -ne 0 ]; then
    echo "[X] Error al fusionar configuración"
    exit 1
fi
echo ""

# Validar JSON
echo "[3/4] Validando JSON..."
python3 -m json.tool "$OPENCLAW_FILE" > /dev/null && echo "[OK] openclaw.json válido" || {
    echo "[X] openclaw.json inválido"
    exit 1
}
echo ""

# BRAVE_API_KEY
echo "[4/4] Configuración de BRAVE_API_KEY..."
if [ -n "$BRAVE_API_KEY" ]; then
    echo "  Exporta en tu shell: export BRAVE_API_KEY='$BRAVE_API_KEY'"
    echo "  O agrégalo a ~/.bashrc para persistencia"
    echo ""
    echo "  Para configurar vía OpenClaw: openclaw configure --section web"
else
    echo "  Para habilitar búsqueda web (web_search):"
    echo "  1. Obtén API key en: https://brave.com/search/api"
    echo "  2. Configura: openclaw configure --section web"
    echo "  3. O exporta: export BRAVE_API_KEY='tu_api_key'"
fi
echo ""

echo "========================================="
echo "[OK] Configuración completada"
echo "========================================="
echo ""
echo "Herramientas habilitadas: web_search, web_fetch, browser, coding (fs, runtime, sessions)"
echo "Browser: headless, Chrome en /usr/bin/google-chrome-stable"
echo ""
echo "Próximo paso: openclaw onboard (si no lo has hecho) y openclaw gateway"
echo ""
