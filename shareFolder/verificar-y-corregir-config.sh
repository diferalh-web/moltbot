#!/bin/bash
# Script para verificar y corregir la configuración de Moltbot
# Ejecutar en la terminal SSH de la VM

echo "========================================="
echo "Verificar y Corregir Configuración"
echo "========================================="
echo ""

AGENT_DIR="$HOME/.openclaw/agents/main/agent"
HOST_IP="192.168.100.42"

echo "[1/4] Verificando config.json..."
if [ -f "$AGENT_DIR/config.json" ]; then
    echo "Contenido actual de config.json:"
    cat "$AGENT_DIR/config.json" | python3 -m json.tool 2>/dev/null || cat "$AGENT_DIR/config.json"
else
    echo "[!] config.json no existe"
fi
echo ""

echo "[2/4] Verificando models.json (sección ollama)..."
if [ -f "$AGENT_DIR/models.json" ]; then
    echo "Sección ollama en models.json:"
    python3 << EOF
import json
import os

models_file = os.path.expanduser("$AGENT_DIR/models.json")
try:
    with open(models_file, 'r') as f:
        data = json.load(f)
    
    if "providers" in data and "ollama" in data["providers"]:
        ollama = data["providers"]["ollama"]
        print(f"baseUrl: {ollama.get('baseUrl', 'NO CONFIGURADO')}")
        print(f"api: {ollama.get('api', 'NO CONFIGURADO')}")
        if "models" in ollama and len(ollama["models"]) > 0:
            print(f"modelo: {ollama['models'][0].get('id', 'NO CONFIGURADO')}")
        else:
            print("modelo: NO CONFIGURADO")
    else:
        print("Sección ollama NO encontrada en models.json")
except Exception as e:
    print(f"Error al leer: {e}")
EOF
else
    echo "[!] models.json no existe"
fi
echo ""

echo "[3/4] Verificando openclaw.json..."
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    echo "Modelo del agente main:"
    python3 << EOF
import json
import os

openclaw_file = os.path.expanduser("$HOME/.openclaw/openclaw.json")
try:
    with open(openclaw_file, 'r') as f:
        data = json.load(f)
    
    if "agents" in data and "main" in data["agents"]:
        model = data["agents"]["main"].get("model", "NO CONFIGURADO")
        print(f"Modelo: {model}")
    else:
        print("Agente main NO encontrado")
except Exception as e:
    print(f"Error al leer: {e}")
EOF
else
    echo "[!] openclaw.json no existe"
fi
echo ""

echo "[4/4] Proponiendo corrección..."
echo ""

# Verificar qué necesita corregirse
python3 << EOF
import json
import os

needs_fix = False
fixes = []

# Verificar config.json
config_file = os.path.expanduser("$AGENT_DIR/config.json")
if os.path.exists(config_file):
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    model_config = config.get("model", {})
    base_url = model_config.get("baseURL", "")
    model_name = model_config.get("name", "")
    
    if "11435" in base_url or model_name == "llama2":
        needs_fix = True
        fixes.append("config.json usa llama2 (puerto 11435) en lugar de Mistral (11436)")

# Verificar models.json
models_file = os.path.expanduser("$AGENT_DIR/models.json")
if os.path.exists(models_file):
    with open(models_file, 'r') as f:
        models_data = json.load(f)
    
    if "providers" in models_data and "ollama" in models_data["providers"]:
        ollama = models_data["providers"]["ollama"]
        base_url = ollama.get("baseUrl", "")
        if "11435" in base_url:
            needs_fix = True
            fixes.append("models.json usa puerto 11435 en lugar de 11436")

if needs_fix:
    print("[!] Se encontraron problemas:")
    for fix in fixes:
        print(f"  - {fix}")
    print("")
    print("Ejecuta el script de configuración de Mistral:")
    print("  cd /media/sf_shareFolder")
    print("  ./configurar-moltbot-mistral-vm.sh")
else:
    print("[OK] La configuración parece correcta")
    print("")
    print("Si aún ves errores, verifica:")
    print("  1. Que el contenedor ollama-mistral esté corriendo en el host")
    print("  2. Que el firewall permita el puerto 11436")
    print("  3. Prueba: curl http://$HOST_IP:11436/v1/models")
EOF

echo ""
echo "========================================="












