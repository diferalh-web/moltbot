#!/bin/bash

# Script para instalar solo Node.js y Moltbot (sin SSH)
# Ejecutar cuando ya estás conectado vía SSH
# Ejecutar con: bash install-only.sh

set -e

echo "========================================="
echo "Instalando Node.js y Moltbot"
echo "========================================="
echo ""

# Obtener el directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Paso 1: Instalar Node.js
echo "📦 Paso 1/2: Instalando Node.js 22.x..."
bash "$SCRIPT_DIR/install-nodejs.sh"
echo ""

# Paso 2: Instalar Moltbot
echo "🤖 Paso 2/2: Instalando Moltbot..."
bash "$SCRIPT_DIR/install-moltbot.sh"
echo ""

echo "========================================="
echo "✅ ¡Instalación completada!"
echo "========================================="
echo ""
echo "Resumen:"
echo "  ✓ Node.js $(node --version) instalado"
echo "  ✓ Moltbot instalado"
echo ""
echo "Próximos pasos:"
echo "1. Conéctate desde Cursor usando SSH Remote"
echo "2. Crea tu proyecto de Moltbot"
echo ""












