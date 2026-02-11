#!/bin/bash
# Script para probar Mistral con warm-up (precarga el modelo)
# Ejecutar en la terminal SSH de la VM

echo "========================================="
echo "Probar Mistral con Warm-up"
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

echo "[1/4] Verificando que el modelo está disponible..."
curl -s "http://$HOST_IP:$PORT/api/tags" | python3 -m json.tool | grep -q "mistral" && echo "[OK] Modelo disponible" || echo "[!] Modelo no encontrado"
echo ""

echo "[2/4] Haciendo warm-up (precargando el modelo)..."
echo "Esto puede tardar 30-60 segundos la primera vez..."
echo ""

WARMUP_RESPONSE=$(curl -s -X POST "http://$HOST_IP:$PORT/api/generate" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"prompt\": \"test\",
    \"stream\": false
  }" \
  --max-time 90 2>&1)

if echo "$WARMUP_RESPONSE" | grep -q "response"; then
    echo "[OK] Modelo cargado y listo"
    echo ""
else
    echo "[!] Warm-up falló o timeout"
    echo "Respuesta: $WARMUP_RESPONSE" | head -5
    echo ""
fi

echo "[3/4] Esperando 5 segundos..."
sleep 5
echo ""

echo "[4/4] Probando generación real..."
echo "Enviando: '$MESSAGE'"
echo ""

RESPONSE=$(curl -s -X POST "http://$HOST_IP:$PORT/api/chat" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"messages\": [{\"role\": \"user\", \"content\": \"$MESSAGE\"}],
    \"stream\": false
  }" \
  --max-time 60 2>&1)

if echo "$RESPONSE" | grep -q "message"; then
    echo "[OK] Mistral responde correctamente!"
    echo ""
    echo "Respuesta completa:"
    echo "$RESPONSE" | python3 -m json.tool
    echo ""
    echo "Solo el contenido:"
    echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['message']['content'])" 2>/dev/null || echo "Error al extraer contenido"
else
    echo "[X] Error en la respuesta"
    echo ""
    echo "Respuesta recibida:"
    echo "$RESPONSE"
    echo ""
    if echo "$RESPONSE" | grep -q "timeout\|timed out"; then
        echo "El modelo puede estar aún cargando. Intenta de nuevo en unos segundos."
    fi
fi

echo ""
echo "========================================="












