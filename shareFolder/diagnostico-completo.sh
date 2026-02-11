#!/bin/bash
# Script de diagnóstico completo
# Ejecutar en la terminal SSH de la VM

echo "========================================="
echo "Diagnóstico Completo de Configuración"
echo "========================================="
echo ""

HOST_IP="192.168.100.42"

echo "[1/5] Verificando conectividad con Ollama-Mistral..."
echo "Probando: http://$HOST_IP:11436/v1/models"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" "http://$HOST_IP:11436/v1/models" 2>&1)
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE")

if [ "$HTTP_CODE" = "200" ]; then
    echo "[OK] Conectividad OK (HTTP 200)"
    echo "Respuesta:"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
else
    echo "[X] Error de conectividad (HTTP $HTTP_CODE)"
    echo "Respuesta: $BODY"
fi
echo ""

echo "[2/5] Verificando config.json del agente..."
AGENT_DIR="$HOME/.openclaw/agents/main/agent"
if [ -f "$AGENT_DIR/config.json" ]; then
    echo "Contenido:"
    cat "$AGENT_DIR/config.json" | python3 -m json.tool
else
    echo "[!] config.json no existe"
fi
echo ""

echo "[3/5] Verificando openclaw.json global..."
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
        agent = data["agents"]["main"]
        model = agent.get("model", "NO CONFIGURADO")
        print(f"  Modelo: {model}")
        
        # Verificar si hay configuración de Ollama en models.providers
        if "models" in data and "providers" in data["models"]:
            if "ollama" in data["models"]["providers"]:
                ollama = data["models"]["providers"]["ollama"]
                base_url = ollama.get("baseUrl", "NO CONFIGURADO")
                print(f"  baseUrl en openclaw.json: {base_url}")
            else:
                print("  [!] No hay sección ollama en models.providers")
    else:
        print("  [!] Agente main no encontrado")
except Exception as e:
    print(f"  [X] Error: {e}")
EOF
else
    echo "[!] openclaw.json no existe"
fi
echo ""

echo "[4/5] Verificando auth-profiles.json..."
if [ -f "$AGENT_DIR/auth-profiles.json" ]; then
    echo "lastGood:"
    python3 << EOF
import json
import os

auth_file = os.path.expanduser("$AGENT_DIR/auth-profiles.json")
try:
    with open(auth_file, 'r') as f:
        data = json.load(f)
    
    if "lastGood" in data:
        print(f"  {data['lastGood']}")
    else:
        print("  No hay lastGood configurado")
    
    if "profiles" in data:
        print("  Perfiles disponibles:")
        for profile_name in data["profiles"]:
            profile = data["profiles"][profile_name]
            provider = profile.get("provider", "unknown")
            print(f"    - {profile_name} (provider: {provider})")
except Exception as e:
    print(f"  [X] Error: {e}")
EOF
else
    echo "[!] auth-profiles.json no existe"
fi
echo ""

echo "[5/5] Verificando models.json (sección ollama)..."
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
        print(f"  baseUrl: {ollama.get('baseUrl', 'NO CONFIGURADO')}")
        print(f"  api: {ollama.get('api', 'NO CONFIGURADO')}")
        if "models" in ollama and len(ollama["models"]) > 0:
            print(f"  modelo: {ollama['models'][0].get('id', 'NO CONFIGURADO')}")
        else:
            print("  modelo: NO CONFIGURADO")
    else:
        print("  [!] Sección ollama no encontrada")
except Exception as e:
    print(f"  [X] Error: {e}")
EOF
else
    echo "[!] models.json no existe"
fi
echo ""

echo "========================================="
echo "Resumen"
echo "========================================="
echo ""
echo "Si ves errores de conectividad, verifica:"
echo "  1. Que el contenedor ollama-mistral esté corriendo en el host"
echo "  2. Que el firewall permita el puerto 11436"
echo "  3. Prueba: curl http://$HOST_IP:11436/v1/models"
echo ""
echo "Si la configuración está correcta pero sigue usando llama2:"
echo "  1. Verifica openclaw.json (puede sobrescribir la configuración)"
echo "  2. Ejecuta: pnpm start agents list (para ver qué modelo está configurado)"
echo ""












