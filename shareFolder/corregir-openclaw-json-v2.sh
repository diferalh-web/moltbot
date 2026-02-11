#!/bin/bash
# Script para corregir openclaw.json - Versión mejorada
# Ejecutar en la terminal SSH de la VM

echo "========================================="
echo "Corregir openclaw.json para usar Mistral (v2)"
echo "========================================="
echo ""

OPENCLAW_FILE="$HOME/.openclaw/openclaw.json"
BACKUP_FILE="$HOME/.openclaw/backup/openclaw.json.$(date +%Y%m%d_%H%M%S)"

echo "[1/4] Creando backup..."
mkdir -p "$HOME/.openclaw/backup"
cp "$OPENCLAW_FILE" "$BACKUP_FILE"
echo "[OK] Backup creado: $BACKUP_FILE"
echo ""

echo "[2/4] Mostrando estructura actual..."
echo "Estructura de agents:"
python3 << 'EOF'
import json
import os

openclaw_file = os.path.expanduser("~/.openclaw/openclaw.json")
with open(openclaw_file, 'r') as f:
    data = json.load(f)

print("Claves en data:", list(data.keys()))
if "agents" in data:
    print("Tipo de agents:", type(data["agents"]))
    if isinstance(data["agents"], list):
        print("agents es una lista con", len(data["agents]), "elementos")
        for i, agent in enumerate(data["agents"]):
            print(f"  [{i}] id: {agent.get('id')}, model: {agent.get('model')}")
    elif isinstance(data["agents"], dict):
        print("agents es un diccionario con claves:", list(data["agents"].keys()))
        if "main" in data["agents"]:
            print(f"  main.model: {data['agents']['main'].get('model')}")
EOF

echo ""
echo "[3/4] Actualizando openclaw.json..."
python3 << 'EOF'
import json
import os

openclaw_file = os.path.expanduser("~/.openclaw/openclaw.json")

# Leer el archivo
with open(openclaw_file, 'r') as f:
    data = json.load(f)

# Buscar y actualizar el agente main
updated = False

if "agents" in data:
    if isinstance(data["agents"], list):
        # Si es una lista, buscar el agente con id "main"
        for agent in data["agents"]:
            if agent.get("id") == "main":
                old_model = agent.get("model", "NO CONFIGURADO")
                agent["model"] = "ollama/mistral"
                print(f"[OK] Modelo actualizado de '{old_model}' a 'ollama/mistral'")
                updated = True
                break
    elif isinstance(data["agents"], dict):
        # Si es un diccionario
        if "main" in data["agents"]:
            old_model = data["agents"]["main"].get("model", "NO CONFIGURADO")
            data["agents"]["main"]["model"] = "ollama/mistral"
            print(f"[OK] Modelo actualizado de '{old_model}' a 'ollama/mistral'")
            updated = True

if not updated:
    print("[!] No se encontró el agente 'main' para actualizar")
    print("    Estructura encontrada:")
    if "agents" in data:
        print(f"    Tipo: {type(data['agents'])}")
        if isinstance(data["agents"], list):
            print(f"    Elementos: {[a.get('id') for a in data['agents']]}")
        elif isinstance(data["agents"], dict):
            print(f"    Claves: {list(data['agents'].keys())}")

# Actualizar baseUrl de Ollama en models.providers si existe
if "models" in data and "providers" in data["models"]:
    if "ollama" in data["models"]["providers"]:
        old_url = data["models"]["providers"]["ollama"].get("baseUrl", "NO CONFIGURADO")
        data["models"]["providers"]["ollama"]["baseUrl"] = "http://192.168.100.42:11436/v1"
        if old_url != "http://192.168.100.42:11436/v1":
            print(f"[OK] baseUrl actualizado de '{old_url}' a 'http://192.168.100.42:11436/v1'")

# Escribir el archivo actualizado
with open(openclaw_file, 'w') as f:
    json.dump(data, f, indent=2)

print("[OK] openclaw.json guardado")
EOF

if [ $? -ne 0 ]; then
    echo "[X] Error al actualizar openclaw.json"
    exit 1
fi

echo ""
echo "[4/4] Verificando actualización..."
python3 << 'EOF'
import json
import os

openclaw_file = os.path.expanduser("~/.openclaw/openclaw.json")
with open(openclaw_file, 'r') as f:
    data = json.load(f)

if "agents" in data:
    if isinstance(data["agents"], list):
        for agent in data["agents"]:
            if agent.get("id") == "main":
                model = agent.get("model")
                if model == "ollama/mistral":
                    print(f"[OK] Modelo del agente main: {model} ✓")
                else:
                    print(f"[X] Modelo del agente main: {model} (debería ser ollama/mistral)")
    elif isinstance(data["agents"], dict):
        if "main" in data["agents"]:
            model = data["agents"]["main"].get("model")
            if model == "ollama/mistral":
                print(f"[OK] Modelo del agente main: {model} ✓")
            else:
                print(f"[X] Modelo del agente main: {model} (debería ser ollama/mistral)")
EOF

echo ""
echo "========================================="
echo "[OK] Proceso completado!"
echo "========================================="
echo ""
echo "Verificar manualmente:"
echo "  cat ~/.openclaw/openclaw.json | python3 -m json.tool | grep -A 5 '\"main\"'"
echo ""
echo "Probar Moltbot:"
echo "  cd ~/moltbot"
echo "  pnpm start agent --session-id test-session --message 'hola' --local"
echo ""












