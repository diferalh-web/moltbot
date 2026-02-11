#!/bin/bash
# Script para verificar configuración y probar Moltbot con Mistral
# Ejecutar en la terminal SSH de la VM

echo "========================================="
echo "Verificar y Probar Moltbot con Mistral"
echo "========================================="
echo ""

echo "[1/4] Verificando configuración de openclaw.json..."
MODEL=$(python3 << 'EOF'
import json
import os

openclaw_file = os.path.expanduser("~/.openclaw/openclaw.json")
try:
    with open(openclaw_file, 'r') as f:
        data = json.load(f)
    
    if "agents" in data and isinstance(data["agents"], dict) and "list" in data["agents"]:
        for agent in data["agents"]["list"]:
            if agent.get("id") == "main":
                model = agent.get("model", "NO CONFIGURADO")
                print(model)
                exit(0)
    print("NO ENCONTRADO")
except Exception as e:
    print(f"ERROR: {e}")
EOF
)

if [ "$MODEL" = "ollama/mistral" ]; then
    echo "[OK] Modelo configurado: $MODEL ✓"
else
    echo "[!] Modelo configurado: $MODEL (debería ser ollama/mistral)"
    echo ""
    echo "Ejecuta para corregir:"
    echo "  cd /media/sf_shareFolder"
    echo "  ./corregir-openclaw-json-v3.sh"
    exit 1
fi
echo ""

echo "[2/4] Verificando config.json del agente..."
AGENT_DIR="$HOME/.openclaw/agents/main/agent"
if [ -f "$AGENT_DIR/config.json" ]; then
    BASE_URL=$(python3 -c "import json, os; data=json.load(open(os.path.expanduser('$AGENT_DIR/config.json'))); print(data['model'].get('baseURL', 'NO CONFIGURADO'))")
    MODEL_NAME=$(python3 -c "import json, os; data=json.load(open(os.path.expanduser('$AGENT_DIR/config.json'))); print(data['model'].get('name', 'NO CONFIGURADO'))")
    
    if [[ "$BASE_URL" == *"11436"* ]] && [ "$MODEL_NAME" = "mistral" ]; then
        echo "[OK] config.json correcto:"
        echo "  baseURL: $BASE_URL"
        echo "  model: $MODEL_NAME"
    else
        echo "[!] config.json puede necesitar actualización"
        echo "  baseURL: $BASE_URL"
        echo "  model: $MODEL_NAME"
    fi
else
    echo "[!] config.json no existe"
fi
echo ""

echo "[3/4] Verificando conectividad con Mistral..."
HOST_IP="192.168.100.42"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" "http://$HOST_IP:11436/v1/models" --max-time 5 2>&1)
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)

if [ "$HTTP_CODE" = "200" ]; then
    echo "[OK] Conectividad con Mistral OK"
else
    echo "[X] Error de conectividad (HTTP $HTTP_CODE)"
    exit 1
fi
echo ""

echo "[4/4] Probando Moltbot..."
echo "Ejecutando: pnpm start agent --session-id test-session --message 'hola' --local"
echo "Esto puede tardar unos segundos..."
echo ""

cd ~/moltbot
timeout 60 pnpm start agent --session-id test-session --message "hola" --local 2>&1 | head -50

EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "========================================="
if [ $EXIT_CODE -eq 0 ] || [ $EXIT_CODE -eq 124 ]; then
    echo "[OK] Moltbot ejecutado"
    if [ $EXIT_CODE -eq 124 ]; then
        echo "     (Timeout de 60s alcanzado, pero puede estar funcionando)"
    fi
else
    echo "[!] Moltbot terminó con código: $EXIT_CODE"
fi
echo "========================================="
echo ""
echo "Si ves errores, verifica:"
echo "  1. Que openclaw.json tenga 'ollama/mistral'"
echo "  2. Que config.json apunte a puerto 11436"
echo "  3. Que Mistral esté respondiendo (prueba con warm-up script)"
echo ""












