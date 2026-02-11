#!/bin/bash
# Script para verificar la configuración de Mistral en Moltbot
# Ejecutar: cd /media/sf_shareFolder && chmod +x verificar-config-mistral.sh && ./verificar-config-mistral.sh

AGENT_DIR="$HOME/.openclaw/agents/main/agent"

echo "========================================="
echo "Verificar Configuración de Mistral"
echo "========================================="
echo ""

# Verificar config.json
echo "[1/2] Configuración en config.json:"
echo "-----------------------------------"
if [ -f "$AGENT_DIR/config.json" ]; then
    cat "$AGENT_DIR/config.json" | python3 -m json.tool
else
    echo "❌ config.json no existe"
fi

echo ""
echo ""

# Verificar models.json
echo "[2/2] Configuración en models.json (sección ollama):"
echo "----------------------------------------------------"
if [ -f "$AGENT_DIR/models.json" ]; then
    python3 << EOF
import json
import os

models_file = os.path.expanduser("$AGENT_DIR/models.json")
try:
    with open(models_file, 'r') as f:
        data = json.load(f)
    
    if "providers" in data and "ollama" in data["providers"]:
        ollama = data["providers"]["ollama"]
        print("baseUrl:", ollama.get("baseUrl", "NO CONFIGURADO"))
        print("api:", ollama.get("api", "NO CONFIGURADO"))
        print("apiKey:", ollama.get("apiKey", "NO CONFIGURADO"))
        print("")
        if "models" in ollama and len(ollama["models"]) > 0:
            print("Modelos configurados:")
            for model in ollama["models"]:
                print(f"  - id: {model.get('id', 'NO ID')}")
                print(f"    name: {model.get('name', 'NO NAME')}")
        else:
            print("❌ No hay modelos configurados")
    else:
        print("❌ Sección 'ollama' no encontrada en providers")
        print("")
        print("Estructura completa de providers:")
        if "providers" in data:
            print("  Providers disponibles:", list(data["providers"].keys()))
        else:
            print("  ❌ No hay sección 'providers'")
except Exception as e:
    print(f"❌ Error al leer models.json: {e}")
EOF
else
    echo "❌ models.json no existe"
fi

echo ""
echo "========================================="
echo "Verificación de Coincidencia"
echo "========================================="
echo ""

# Verificar que el modelo coincida
python3 << EOF
import json
import os

config_file = os.path.expanduser("$AGENT_DIR/config.json")
models_file = os.path.expanduser("$AGENT_DIR/models.json")

try:
    # Leer config.json
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    config_model = config.get("model", {}).get("name", "")
    config_url = config.get("model", {}).get("baseURL", "")
    
    # Leer models.json
    with open(models_file, 'r') as f:
        models_data = json.load(f)
    
    ollama_models = []
    ollama_url = ""
    if "providers" in models_data and "ollama" in models_data["providers"]:
        ollama = models_data["providers"]["ollama"]
        ollama_url = ollama.get("baseUrl", "")
        if "models" in ollama:
            ollama_models = [m.get("id", "") for m in ollama["models"]]
    
    print("Comparación:")
    print(f"  config.json -> modelo: {config_model}, URL: {config_url}")
    print(f"  models.json -> modelos: {ollama_models}, URL: {ollama_url}")
    print("")
    
    # Verificar coincidencias
    issues = []
    
    if config_model not in ollama_models and ollama_models:
        issues.append(f"❌ El modelo '{config_model}' en config.json no está en models.json")
        issues.append(f"   Modelos disponibles en models.json: {ollama_models}")
    
    if config_url != ollama_url and ollama_url:
        issues.append(f"⚠️  Las URLs no coinciden:")
        issues.append(f"   config.json: {config_url}")
        issues.append(f"   models.json: {ollama_url}")
    
    if not issues:
        print("✅ La configuración parece correcta")
    else:
        print("Problemas encontrados:")
        for issue in issues:
            print(f"  {issue}")
            
except Exception as e:
    print(f"❌ Error al comparar: {e}")
EOF

echo ""
echo "========================================="












