#!/bin/bash

# Script de instalación de OpenClaw (sucesor de Moltbot)
# Ejecutar con: bash install-openclaw.sh
# Requiere Node.js >= 22

set -e  # Salir si hay algún error

echo "========================================="
echo "Instalando OpenClaw"
echo "========================================="

# Verificar que Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "[X] Error: Node.js no está instalado"
    echo "Por favor ejecuta primero: bash install-nodejs.sh"
    exit 1
fi

# Verificar Node.js >= 22 (requisito de OpenClaw)
NODE_MAJOR=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_MAJOR" -lt 22 ]; then
    echo "[X] Error: OpenClaw requiere Node.js >= 22"
    echo "Versión actual: $(node -v)"
    echo "Ejecuta: bash install-nodejs.sh"
    exit 1
fi

echo "Node.js versión: $(node -v)"
echo "npm versión: $(npm -v)"

# Instalar OpenClaw globalmente
echo ""
echo "Instalando OpenClaw (esto puede tomar varios minutos)..."
sudo npm install -g openclaw@latest

# Verificar instalación
echo ""
echo "========================================="
echo "Verificando instalación de OpenClaw..."
echo "========================================="

if command -v openclaw &> /dev/null; then
    echo "[OK] OpenClaw instalado correctamente!"
    openclaw --version 2>/dev/null || echo "OpenClaw instalado (versión no disponible)"
else
    echo "[!] OpenClaw puede estar instalado pero no en PATH"
    echo "Intenta ejecutar: npx openclaw"
fi

echo ""
echo "========================================="
echo "Instalación completada!"
echo "========================================="
echo ""
echo "Próximos pasos:"
echo "1. Ejecuta: openclaw onboard (asistente de configuración inicial)"
echo "2. Configura el workspace: ~/.openclaw/workspace"
echo "3. Inicia el Gateway: openclaw gateway"
echo ""
echo "Para más información: docs.molt.bot"
