#!/bin/bash
# Script para corregir openclaw.json y usar Mistral
# Ejecutar en la terminal SSH de la VM

echo "========================================="
echo "Corregir openclaw.json para usar Mistral"
echo "========================================="
echo ""

OPENCLAW_FILE="$HOME/.openclaw/openclaw.json"
BACKUP_FILE="$HOME/.openclaw/backup/openclaw.json.$(date +%Y%m%d_%H%M%S)"

echo "[1/3] Creando backup..."
mkdir -p "$HOME/.openclaw/backup"
cp "$OPENCLAW_FILE" "$BACKUP_FILE"
echo "[OK] Backup creado: $BACKUP_FILE"
echo ""

echo "[2/3] Actualizando openclaw.json..."
python3 << 'EOF'
import json
import os

openclaw_file = os.path.expanduser("~/.openclaw/openclaw.json")

# Leer el archivo
with open(openclaw_file, 'r') as f:
    data = json.load(f)

# Actualizar modelo del agente main
if "agents" in data:
    if isinstance(data["agents"], list):
        # Si es una lista
        for agent in data["agents"]:
            if agent.get("id") == "main":
                agent["model"] = "ollama/mistral"
                print(f"[OK] Modelo del agente main actualizado a: ollama/mistral")
    elif isinstance(data["agents"], dict):
        # Si es un diccionario
        if "main" in data["agents"]:
            data["agents"]["main"]["model"] = "ollama/mistral"
            print(f"[OK] Modelo del agente main actualizado a: ollama/mistral")

# Actualizar baseUrl de Ollama en models.providers si existe
if "models" in data and "providers" in data["models"]:
    if "ollama" in data["models"]["providers"]:
        data["models"]["providers"]["ollama"]["baseUrl"] = "http://192.168.100.42:11436/v1"
        print(f"[OK] baseUrl de Ollama actualizado a: http://192.168.100.42:11436/v1")

# Escribir el archivo actualizado
with open(openclaw_file, 'w') as f:
    json.dump(data, f, indent=2)

print("[OK] openclaw.json actualizado")
EOF

if [ $? -ne 0 ]; then
    echo "[X] Error al actualizar openclaw.json"
    exit 1
fi

echo ""
echo "[3/3] Validando JSON..."
python3 -m json.tool "$OPENCLAW_FILE" > /dev/null && echo "[OK] openclaw.json válido" || echo "[X] Error en openclaw.json"

echo ""
echo "========================================="
echo "[OK] Configuración completada!"
echo "========================================="
echo ""
echo "Verificar:"
echo "  cat ~/.openclaw/openclaw.json | python3 -m json.tool | grep -A 5 '\"main\"'"
echo ""
echo "Probar Moltbot:"
echo "  cd ~/moltbot"
echo "  pnpm start agent --session-id test-session --message 'hola' --local"
echo ""












