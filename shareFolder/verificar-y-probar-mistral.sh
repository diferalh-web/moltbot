#!/bin/bash
# Script para verificar configuración y probar Mistral
# Ejecutar en la terminal SSH de la VM

echo "========================================="
echo "Verificar Configuración y Probar Mistral"
echo "========================================="
echo ""

HOST_IP="192.168.100.42"

echo "[1/4] Verificando modelo en openclaw.json..."
MODEL=$(python3 << 'EOF'
import json
import os

openclaw_file = os.path.expanduser("~/.openclaw/openclaw.json")
with open(openclaw_file, 'r') as f:
    data = json.load(f)

if "agents" in data and isinstance(data["agents"], dict) and "list" in data["agents"]:
    for agent in data["agents"]["list"]:
        if agent.get("id") == "main":
            print(agent.get("model", "NO CONFIGURADO"))
            exit(0)
print("NO ENCONTRADO")
EOF
)

if [ "$MODEL" = "ollama/mistral" ]; then
    echo "[OK] Modelo configurado: $MODEL ✓"
else
    echo "[X] Modelo configurado: $MODEL (debería ser ollama/mistral)"
fi
echo ""

echo "[2/4] Probando conectividad con Ollama-Mistral..."
echo "Endpoint: http://$HOST_IP:11436/v1/models"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" --max-time 5 "http://$HOST_IP:11436/v1/models" 2>&1)
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE")

if [ "$HTTP_CODE" = "200" ]; then
    echo "[OK] Conectividad OK (HTTP 200)"
    echo "Modelos disponibles:"
    echo "$BODY" | python3 -m json.tool 2>/dev/null | grep -E '"id"|"object"' || echo "$BODY"
else
    echo "[X] Error de conectividad (HTTP $HTTP_CODE)"
    echo "Respuesta: $BODY"
    echo ""
    echo "Verifica:"
    echo "  1. Que el contenedor ollama-mistral esté corriendo en el host"
    echo "  2. Que el firewall permita el puerto 11436"
    echo "  3. Prueba desde el host: docker ps | grep mistral"
fi
echo ""

echo "[3/4] Verificando config.json del agente..."
AGENT_DIR="$HOME/.openclaw/agents/main/agent"
if [ -f "$AGENT_DIR/config.json" ]; then
    echo "Configuración:"
    cat "$AGENT_DIR/config.json" | python3 -m json.tool
else
    echo "[!] config.json no existe"
fi
echo ""

echo "[4/4] Probando generación directa con Mistral..."
echo "Enviando: 'hola'"
RESPONSE=$(curl -s -X POST "http://$HOST_IP:11436/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mistral",
    "messages": [{"role": "user", "content": "hola"}],
    "stream": false
  }' --max-time 30 2>&1)

if echo "$RESPONSE" | grep -q "choices"; then
    echo "[OK] Mistral responde correctamente"
    echo "Respuesta:"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null | grep -A 5 "content" || echo "$RESPONSE"
else
    echo "[!] Error o timeout en la respuesta"
    echo "Respuesta: $RESPONSE"
fi
echo ""

echo "========================================="
echo "Resumen"
echo "========================================="
echo ""
echo "Si todo está OK pero Moltbot se queda 'pensando':"
echo "  1. Puede ser que esté esperando una respuesta larga"
echo "  2. Prueba con un timeout: timeout 30 pnpm start agent ..."
echo "  3. O verifica los logs en tiempo real"
echo ""
echo "Para probar con timeout:"
echo "  cd ~/moltbot"
echo "  timeout 30 pnpm start agent --session-id test-session --message 'hola' --local"
echo ""












