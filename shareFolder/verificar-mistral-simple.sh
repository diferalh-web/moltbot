#!/bin/bash
# Script simple para verificar si Mistral está corriendo
# Ejecutar: cd /media/sf_shareFolder && chmod +x verificar-mistral-simple.sh && ./verificar-mistral-simple.sh

HOST_IP="192.168.100.42"
MISTRAL_PORT="11436"
MISTRAL_URL="http://${HOST_IP}:${MISTRAL_PORT}"

echo "========================================="
echo "Verificar si Mistral está corriendo"
echo "========================================="
echo ""

# 1. Verificar puerto
echo "[1/3] Verificando puerto $MISTRAL_PORT..."
if timeout 3 bash -c "echo > /dev/tcp/$HOST_IP/$MISTRAL_PORT" 2>/dev/null; then
    echo "✅ Puerto $MISTRAL_PORT está ABIERTO"
else
    echo "❌ Puerto $MISTRAL_PORT está CERRADO o no accesible"
    echo ""
    echo "Mistral NO está corriendo o el puerto está bloqueado"
    echo ""
    echo "Verifica en Windows (PowerShell):"
    echo "  docker ps | findstr mistral"
    echo "  docker ps | findstr 11436"
    exit 1
fi

echo ""

# 2. Probar conexión HTTP
echo "[2/3] Probando conexión HTTP a Mistral..."
RESPONSE=$(curl -s -m 10 "$MISTRAL_URL/v1/models" 2>&1)
CURL_EXIT=$?

if [ $CURL_EXIT -eq 0 ]; then
    echo "✅ Mistral RESPONDE correctamente"
    echo ""
    echo "Respuesta:"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null | head -20 || echo "$RESPONSE" | head -10
else
    echo "❌ Mistral NO responde"
    echo "Error: $RESPONSE"
    exit 1
fi

echo ""

# 3. Probar endpoint de chat
echo "[3/3] Probando endpoint de chat/completions..."
TEST_RESPONSE=$(curl -s -m 10 -X POST "$MISTRAL_URL/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ollama" \
    -d '{"model":"mistral","messages":[{"role":"user","content":"hola"}],"max_tokens":10}' 2>&1)

if echo "$TEST_RESPONSE" | grep -qi "error\|failed"; then
    echo "⚠️  El endpoint tiene problemas:"
    echo "$TEST_RESPONSE" | head -5
else
    echo "✅ El endpoint de chat funciona"
fi

echo ""
echo "========================================="
echo "Resumen"
echo "========================================="
echo ""

if [ $CURL_EXIT -eq 0 ]; then
    echo "✅ Mistral ESTÁ CORRIENDO y es accesible"
    echo ""
    echo "Si Moltbot aún da errores, el problema puede ser:"
    echo "  1. Timeout muy corto en la configuración de Moltbot"
    echo "  2. Nombre del modelo incorrecto en models.json"
    echo "  3. Problema con la autenticación"
    echo ""
    echo "Verifica la configuración:"
    echo "  cat ~/.openclaw/agents/main/agent/config.json"
    echo "  cat ~/.openclaw/agents/main/agent/models.json | python3 -m json.tool | grep -A 5 mistral"
else
    echo "❌ Mistral NO está accesible"
    echo ""
    echo "Verifica en Windows:"
    echo "  1. docker ps | findstr mistral"
    echo "  2. docker logs <nombre-contenedor-mistral>"
fi

echo ""












