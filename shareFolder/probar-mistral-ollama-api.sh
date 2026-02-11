#!/bin/bash
# Script para probar Mistral usando la API nativa de Ollama
# Ejecutar en la terminal SSH de la VM

echo "========================================="
echo "Probar Mistral con API Nativa de Ollama"
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

echo "[1/3] Probando endpoint /api/tags (nativo Ollama)..."
echo "----------------------------------------"
curl -s "http://$HOST_IP:$PORT/api/tags" | python3 -m json.tool
echo ""

echo "[2/3] Probando endpoint /api/chat (nativo Ollama)..."
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
    echo "[OK] Mistral responde correctamente con API nativa"
    echo ""
    echo "Respuesta completa:"
    echo "$RESPONSE" | python3 -m json.tool
    echo ""
    echo "Solo el contenido:"
    echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['message']['content'])" 2>/dev/null || echo "Error al extraer contenido"
else
    echo "[!] No funcionó con /api/chat, probando /v1/chat/completions..."
    echo ""
    
    # Probar con formato OpenAI
    RESPONSE=$(curl -s -X POST "http://$HOST_IP:$PORT/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d "{
        \"model\": \"$MODEL\",
        \"messages\": [{\"role\": \"user\", \"content\": \"$MESSAGE\"}],
        \"stream\": false
      }" \
      --max-time 30 2>&1)
    
    if echo "$RESPONSE" | grep -q "choices"; then
        echo "[OK] Mistral responde con formato OpenAI"
        echo ""
        echo "Respuesta:"
        echo "$RESPONSE" | python3 -m json.tool | head -20
    else
        echo "[X] Error o timeout en ambos endpoints"
        echo ""
        echo "Respuesta recibida:"
        echo "$RESPONSE"
        echo ""
        echo "Verifica en el host:"
        echo "  docker ps | grep mistral"
        echo "  docker logs ollama-mistral --tail 20"
    fi
fi

echo ""
echo "[3/3] Probando endpoint /api/generate (alternativa)..."
echo "----------------------------------------"
RESPONSE=$(curl -s -X POST "http://$HOST_IP:$PORT/api/generate" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"prompt\": \"$MESSAGE\",
    \"stream\": false
  }" \
  --max-time 30 2>&1)

if echo "$RESPONSE" | grep -q "response"; then
    echo "[OK] Mistral responde con /api/generate"
    echo ""
    echo "Respuesta:"
    echo "$RESPONSE" | python3 -m json.tool | grep -A 2 "response" | head -5
else
    echo "[!] /api/generate no respondió"
    echo "Respuesta: $RESPONSE"
fi

echo ""
echo "========================================="
echo "Resumen"
echo "========================================="
echo ""
echo "Si ninguno funciona, el problema puede ser:"
echo "  1. El contenedor está corriendo pero el modelo no está cargado"
echo "  2. Problema de memoria en el contenedor"
echo "  3. El modelo necesita ser 'pulled' de nuevo"
echo ""
echo "En el host, verifica:"
echo "  docker exec ollama-mistral ollama list"
echo "  docker exec ollama-mistral ollama show mistral"
echo ""












