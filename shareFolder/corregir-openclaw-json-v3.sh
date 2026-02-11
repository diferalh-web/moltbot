#!/bin/bash
# Script para corregir openclaw.json - Versión corregida
# Ejecutar en la terminal SSH de la VM

echo "========================================="
echo "Corregir openclaw.json para usar Mistral (v3)"
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

# Buscar y actualizar el agente main
updated = False

if "agents" in data:
    # La estructura es agents.list (lista) o agents.main (dict)
    if isinstance(data["agents"], dict):
        # Si es un diccionario, puede tener "list" o "main"
        if "list" in data["agents"]:
            # Buscar en la lista
            for agent in data["agents"]["list"]:
                if agent.get("id") == "main":
                    old_model = agent.get("model", "NO CONFIGURADO")
                    agent["model"] = "ollama/mistral"
                    print(f"[OK] Modelo actualizado de '{old_model}' a 'ollama/mistral'")
                    updated = True
                    break
        elif "main" in data["agents"]:
            # Si main está directamente en agents
            old_model = data["agents"]["main"].get("model", "NO CONFIGURADO")
            data["agents"]["main"]["model"] = "ollama/mistral"
            print(f"[OK] Modelo actualizado de '{old_model}' a 'ollama/mistral'")
            updated = True
    elif isinstance(data["agents"], list):
        # Si es una lista directamente
        for agent in data["agents"]:
            if agent.get("id") == "main":
                old_model = agent.get("model", "NO CONFIGURADO")
                agent["model"] = "ollama/mistral"
                print(f"[OK] Modelo actualizado de '{old_model}' a 'ollama/mistral'")
                updated = True
                break

if not updated:
    print("[X] No se encontró el agente 'main' para actualizar")
    print("    Estructura encontrada:")
    if "agents" in data:
        print(f"    Tipo de agents: {type(data['agents'])}")
        if isinstance(data["agents"], dict):
            print(f"    Claves en agents: {list(data['agents'].keys())}")
            if "list" in data["agents"]:
                print(f"    IDs en agents.list: {[a.get('id') for a in data['agents']['list']]}")
    exit(1)

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
echo "[3/3] Verificando actualización..."
python3 << 'EOF'
import json
import os

openclaw_file = os.path.expanduser("~/.openclaw/openclaw.json")
with open(openclaw_file, 'r') as f:
    data = json.load(f)

found = False
if "agents" in data:
    if isinstance(data["agents"], dict):
        if "list" in data["agents"]:
            for agent in data["agents"]["list"]:
                if agent.get("id") == "main":
                    model = agent.get("model")
                    found = True
                    if model == "ollama/mistral":
                        print(f"[OK] Modelo del agente main: {model} ✓")
                    else:
                        print(f"[X] Modelo del agente main: {model} (debería ser ollama/mistral)")
        elif "main" in data["agents"]:
            model = data["agents"]["main"].get("model")
            found = True
            if model == "ollama/mistral":
                print(f"[OK] Modelo del agente main: {model} ✓")
            else:
                print(f"[X] Modelo del agente main: {model} (debería ser ollama/mistral)")
    elif isinstance(data["agents"], list):
        for agent in data["agents"]:
            if agent.get("id") == "main":
                model = agent.get("model")
                found = True
                if model == "ollama/mistral":
                    print(f"[OK] Modelo del agente main: {model} ✓")
                else:
                    print(f"[X] Modelo del agente main: {model} (debería ser ollama/mistral)")

if not found:
    print("[!] No se encontró el agente main para verificar")
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












