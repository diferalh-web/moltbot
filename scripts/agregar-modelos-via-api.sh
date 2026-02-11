#!/bin/bash
# Script para agregar modelos Ollama adicionales a Open WebUI
# Este script modifica la configuración interna de Open WebUI

echo "========================================="
echo "Agregar Modelos Ollama a Open WebUI"
echo "========================================="
echo ""

# Verificar que Open WebUI está corriendo
if ! docker ps | grep -q open-webui; then
    echo "[X] Open WebUI no está corriendo"
    exit 1
fi

echo "[1/3] Verificando modelos disponibles..."
echo ""

# Verificar modelos en cada servicio
echo "Mistral (11436):"
docker exec open-webui curl -s http://host.docker.internal:11436/api/tags 2>/dev/null | grep -o '"name":"[^"]*"' | head -1
echo ""

echo "Qwen (11437):"
docker exec open-webui curl -s http://host.docker.internal:11437/api/tags 2>/dev/null | grep -o '"name":"[^"]*"' | head -1
echo ""

echo "Code (11438):"
docker exec open-webui curl -s http://host.docker.internal:11438/api/tags 2>/dev/null | grep -o '"name":"[^"]*"'
echo ""

echo "[2/3] Nota: Open WebUI necesita configuración manual en la interfaz"
echo ""
echo "[3/3] Instrucciones:"
echo "========================================="
echo "1. Abre http://localhost:8082"
echo "2. Ve a Settings → General"
echo "3. Busca 'Backend' o 'Ollama Configuration'"
echo "4. O usa el selector de modelos y escribe manualmente:"
echo "   - qwen2.5:7b@http://host.docker.internal:11437"
echo "   - codellama:34b@http://host.docker.internal:11438"
echo "   - deepseek-coder:33b@http://host.docker.internal:11438"
echo ""
echo "Alternativa: Usa solo Mistral por ahora (ya funciona)"
echo "========================================="












