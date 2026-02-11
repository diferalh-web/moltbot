#!/bin/bash
# Script para verificar si Mistral está corriendo en el puerto 11436
# Ejecutar desde la VM: cd /media/sf_shareFolder && chmod +x verificar-mistral-11436.sh && ./verificar-mistral-11436.sh

set -uo pipefail

HOST_IP="192.168.100.42"
MISTRAL_PORT="11436"
MISTRAL_URL="http://${HOST_IP}:${MISTRAL_PORT}/v1"

echo "========================================="
echo "Verificar Mistral en Puerto 11436"
echo "========================================="
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_error() {
    echo -e "${RED}[X]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# ============================================
# Verificar puerto 11436
# ============================================
echo "[1/3] Verificando que el puerto $MISTRAL_PORT esté abierto..."

if timeout 3 bash -c "echo > /dev/tcp/$HOST_IP/$MISTRAL_PORT" 2>/dev/null; then
    log_success "El puerto $MISTRAL_PORT está abierto"
else
    log_error "El puerto $MISTRAL_PORT no está accesible"
    echo "  Esto significa que Mistral no está corriendo o el puerto está bloqueado"
    echo ""
    echo "  Verifica en el host (Windows):"
    echo "    docker ps | findstr mistral"
    echo "    docker ps | findstr 11436"
    exit 1
fi

echo ""

# ============================================
# Probar conexión HTTP a Mistral
# ============================================
echo "[2/3] Probando conexión HTTP a Mistral..."

# Probar endpoint de modelos
RESPONSE=$(curl -s -m 10 "$MISTRAL_URL/models" 2>&1)
CURL_EXIT=$?

if [ $CURL_EXIT -eq 0 ]; then
    if echo "$RESPONSE" | grep -qi "mistral\|model"; then
        log_success "Mistral responde correctamente"
        echo ""
        echo "Respuesta:"
        echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE" | head -30
    else
        log_warning "Mistral responde pero la respuesta es inesperada"
        echo "Respuesta: $RESPONSE"
    fi
else
    log_error "No se puede conectar a Mistral"
    echo "Error: $RESPONSE"
    echo ""
    echo "Posibles causas:"
    echo "  1. El contenedor de Mistral no está corriendo"
    echo "  2. El puerto está bloqueado por firewall"
    echo "  3. Mistral no está escuchando en $HOST_IP"
    exit 1
fi

echo ""

# ============================================
# Probar endpoint de completions
# ============================================
echo "[3/3] Probando endpoint de completions..."

TEST_REQUEST='{"model":"mistral","messages":[{"role":"user","content":"test"}],"max_tokens":5}'
COMPLETION_RESPONSE=$(curl -s -m 10 -X POST "$MISTRAL_URL/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ollama" \
    -d "$TEST_REQUEST" 2>&1)

if echo "$COMPLETION_RESPONSE" | grep -qi "error\|failed"; then
    log_warning "El endpoint de completions tiene problemas"
    echo "Respuesta: $COMPLETION_RESPONSE" | head -20
else
    log_success "El endpoint de completions funciona"
fi

echo ""
echo "========================================="
echo "Resumen"
echo "========================================="
echo ""

if [ $CURL_EXIT -eq 0 ]; then
    log_success "Mistral está funcionando correctamente en el puerto $MISTRAL_PORT"
    echo ""
    echo "El problema puede ser:"
    echo "  1. Timeout muy corto en Moltbot"
    echo "  2. Configuración incorrecta del modelo en models.json"
    echo "  3. Problema con la autenticación"
    echo ""
    echo "Verifica la configuración:"
    echo "  cat ~/.openclaw/agents/main/agent/config.json"
    echo "  cat ~/.openclaw/agents/main/agent/models.json | python3 -m json.tool | grep -A 10 ollama"
else
    log_error "Mistral no está accesible"
    echo ""
    echo "Acciones recomendadas:"
    echo "  1. Verificar que el contenedor esté corriendo en el host"
    echo "  2. Verificar el firewall"
    echo "  3. Verificar los logs del contenedor"
fi

echo ""












