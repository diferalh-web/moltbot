#!/bin/bash
# Script para probar Qwen directamente (puede ser más eficiente en memoria)
# Ejecutar en la terminal SSH de la VM

echo "========================================="
echo "Probar Qwen Directamente"
echo "========================================="
echo ""

HOST_IP="192.168.100.42"
PORT="11437"
MODEL="qwen2.5:7b"
MESSAGE="${1:-hola}"

echo "Configuración:"
echo "  Host: $HOST_IP"
echo "  Puerto: $PORT"
echo "  Modelo: $MODEL"
echo "  Mensaje: $MESSAGE"
echo ""

echo "[1/2] Probando endpoint /api/tags..."
echo "----------------------------------------"
curl -s "http://$HOST_IP:$PORT/api/tags" | python3 -m json.tool
echo ""

echo "[2/2] Probando generación de texto..."
echo "----------------------------------------"
echo "Enviando: '$MESSAGE'"
echo ""

RESPONSE=$(curl -s -X POST "http://$HOST_IP:$PORT/api/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"messages\": [{\"role\": \"user\", \"content\": \"$MESSAGE\"}],
    \"stream\": false
  }" \
  --max-time 30 2>&1)

if echo "$RESPONSE" | grep -q "message"; then
    echo "[OK] Qwen responde correctamente"
    echo ""
    echo "Respuesta:"
    echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['message']['content'])" 2>/dev/null || echo "$RESPONSE"
else
    echo "[X] Error en la respuesta"
    echo "Respuesta: $RESPONSE"
    echo ""
    if echo "$RESPONSE" | grep -q "signal: killed"; then
        echo "Mismo problema de memoria. Qwen también necesita mucha RAM."
    fi
fi

echo ""
echo "========================================="












