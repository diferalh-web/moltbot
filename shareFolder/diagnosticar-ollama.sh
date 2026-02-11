#!/bin/bash
# Script para diagnosticar problemas de conexión con Ollama
# Ejecutar desde la VM: cd /media/sf_shareFolder && chmod +x diagnosticar-ollama.sh && ./diagnosticar-ollama.sh

set -uo pipefail

HOST_IP="192.168.100.42"
OLLAMA_PORT="11435"
OLLAMA_URL="http://${HOST_IP}:${OLLAMA_PORT}"

echo "========================================="
echo "Diagnóstico de Conexión con Ollama"
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
# Paso 1: Verificar conectividad básica
# ============================================
echo "[1/6] Verificando conectividad básica con el host..."

if ping -c 2 "$HOST_IP" > /dev/null 2>&1; then
    log_success "El host $HOST_IP es alcanzable"
else
    log_error "No se puede alcanzar el host $HOST_IP"
    echo "  Verifica que el host esté encendido y en la misma red"
    exit 1
fi

echo ""

# ============================================
# Paso 2: Verificar que el puerto esté abierto
# ============================================
echo "[2/6] Verificando que el puerto $OLLAMA_PORT esté abierto..."

if timeout 3 bash -c "echo > /dev/tcp/$HOST_IP/$OLLAMA_PORT" 2>/dev/null; then
    log_success "El puerto $OLLAMA_PORT está abierto"
else
    log_error "El puerto $OLLAMA_PORT no está accesible"
    echo "  Verifica que Ollama esté corriendo en el host"
    echo "  Verifica el firewall en el host"
fi

echo ""

# ============================================
# Paso 3: Probar conexión HTTP a Ollama
# ============================================
echo "[3/6] Probando conexión HTTP a Ollama..."

RESPONSE=$(curl -s -m 5 "$OLLAMA_URL/api/tags" 2>&1)
CURL_EXIT=$?

if [ $CURL_EXIT -eq 0 ]; then
    if echo "$RESPONSE" | grep -q "models"; then
        log_success "Ollama responde correctamente"
        echo ""
        echo "Modelos disponibles:"
        echo "$RESPONSE" | python3 -m json.tool 2>/dev/null | grep -E '"name"|"model"' | head -10 || echo "$RESPONSE" | head -20
    else
        log_warning "Ollama responde pero la respuesta es inesperada"
        echo "Respuesta: $RESPONSE"
    fi
else
    log_error "No se puede conectar a Ollama"
    echo "Error: $RESPONSE"
    echo ""
    echo "Posibles causas:"
    echo "  1. Ollama no está corriendo en el host"
    echo "  2. Firewall bloqueando el puerto $OLLAMA_PORT"
    echo "  3. Ollama no está escuchando en $HOST_IP"
fi

echo ""

# ============================================
# Paso 4: Verificar configuración de Moltbot
# ============================================
echo "[4/6] Verificando configuración de Moltbot..."

AGENT_DIR="$HOME/.openclaw/agents/main/agent"

if [ -f "$AGENT_DIR/config.json" ]; then
    echo "config.json:"
    cat "$AGENT_DIR/config.json" | python3 -m json.tool 2>/dev/null || cat "$AGENT_DIR/config.json"
    echo ""
else
    log_warning "config.json no existe"
fi

if [ -f "$AGENT_DIR/models.json" ]; then
    echo "models.json (sección ollama):"
    python3 << EOF
import json
import os

models_file = os.path.expanduser("$AGENT_DIR/models.json")
try:
    with open(models_file, 'r') as f:
        data = json.load(f)
    
    if "providers" in data and "ollama" in data["providers"]:
        ollama = data["providers"]["ollama"]
        print(f"baseUrl: {ollama.get('baseUrl', 'NO CONFIGURADO')}")
        print(f"api: {ollama.get('api', 'NO CONFIGURADO')}")
        if "models" in ollama and len(ollama["models"]) > 0:
            print(f"modelo: {ollama['models'][0].get('id', 'NO CONFIGURADO')}")
    else:
        print("Sección ollama NO encontrada")
except Exception as e:
    print(f"Error: {e}")
EOF
    echo ""
else
    log_warning "models.json no existe"
fi

# ============================================
# Paso 5: Verificar variables de entorno
# ============================================
echo "[5/6] Verificando variables de entorno..."

if [ -n "${OPENCLAW_MODEL_BASE_URL:-}" ]; then
    log_info "OPENCLAW_MODEL_BASE_URL está configurada: $OPENCLAW_MODEL_BASE_URL"
else
    log_info "OPENCLAW_MODEL_BASE_URL no está configurada"
fi

if [ -n "${OLLAMA_HOST:-}" ]; then
    log_info "OLLAMA_HOST está configurada: $OLLAMA_HOST"
else
    log_info "OLLAMA_HOST no está configurada"
fi

echo ""

# ============================================
# Paso 6: Recomendaciones
# ============================================
echo "[6/6] Recomendaciones..."
echo ""

if [ $CURL_EXIT -ne 0 ]; then
    echo "Para resolver el problema de conexión:"
    echo ""
    echo "1. Verifica que Ollama esté corriendo en el host:"
    echo "   # En el host (Windows), verifica que el contenedor esté corriendo"
    echo "   docker ps | grep ollama"
    echo ""
    echo "2. Verifica el firewall en el host:"
    echo "   # En Windows, permite el puerto $OLLAMA_PORT en el firewall"
    echo ""
    echo "3. Verifica que Ollama esté escuchando en la IP correcta:"
    echo "   # En el host, verifica la configuración de red de Ollama"
    echo ""
    echo "4. Prueba desde el host si Ollama responde:"
    echo "   curl http://localhost:$OLLAMA_PORT/api/tags"
    echo ""
else
    log_success "La conexión a Ollama funciona correctamente"
    echo ""
    echo "Si Moltbot aún da errores, verifica:"
    echo "  1. Que la configuración en models.json use la URL correcta"
    echo "  2. Que el modelo especificado exista en Ollama"
    echo "  3. Los logs de Moltbot para más detalles"
fi

echo ""
echo "========================================="












