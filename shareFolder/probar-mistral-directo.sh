#!/bin/bash
# Script para probar Mistral directamente
# Ejecutar en la terminal SSH de la VM

echo "========================================="
echo "Probar Mistral Directamente"
echo "========================================="
echo ""

HOST_IP="192.168.100.42"
PORT="11436"
MODEL="mistral"
MESSAGE="${1:-hola}"

echo "Configuración:"
echo "  Host: $HOST_IP"
echo "  Puerto: $PORT"
echo "  Modelo: $MODEL"
echo "  Mensaje: $MESSAGE"
echo ""

echo "[1/2] Probando endpoint /v1/models..."
echo "----------------------------------------"
curl -s "http://$HOST_IP:$PORT/v1/models" | python3 -m json.tool
echo ""

echo "[2/2] Probando generación de texto..."
echo "----------------------------------------"
echo "Enviando: '$MESSAGE'"
echo ""

RESPONSE=$(curl -s -X POST "http://$HOST_IP:$PORT/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"messages\": [{\"role\": \"user\", \"content\": \"$MESSAGE\"}],
    \"stream\": false
  }" \
  --max-time 30 2>&1)

if echo "$RESPONSE" | grep -q "choices"; then
    echo "[OK] Mistral responde correctamente"
    echo ""
    echo "Respuesta completa:"
    echo "$RESPONSE" | python3 -m json.tool
    echo ""
    echo "Solo el contenido:"
    echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['choices'][0]['message']['content'])" 2>/dev/null || echo "Error al extraer contenido"
else
    echo "[X] Error o timeout en la respuesta"
    echo ""
    echo "Respuesta recibida:"
    echo "$RESPONSE"
    echo ""
    echo "Posibles causas:"
    echo "  1. El contenedor ollama-mistral no está corriendo"
    echo "  2. Problema de conectividad de red"
    echo "  3. Firewall bloqueando el puerto $PORT"
    echo ""
    echo "Verifica en el host:"
    echo "  docker ps | grep mistral"
fi

echo ""
echo "========================================="
echo "Uso:"
echo "  ./probar-mistral-directo.sh [mensaje]"
echo "  Ejemplo: ./probar-mistral-directo.sh 'como estas?'"
echo "========================================="












