#!/bin/bash

# Script completo: Instala todo lo necesario para OpenClaw (Moltbot)
# Ejecutar con: bash setup-complete.sh

set -e

echo "========================================="
echo "Instalación completa de OpenClaw"
echo "========================================="
echo ""

# Obtener el directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Paso 1: Configurar SSH
echo "[1/4] Configurando SSH..."
bash "$SCRIPT_DIR/setup-ssh.sh"
echo ""

# Paso 2: Instalar Node.js 22.x (OpenClaw requiere Node >= 22)
echo "[2/4] Instalando Node.js 22.x..."
bash "$SCRIPT_DIR/install-nodejs.sh"
echo ""

# Paso 3: Instalar OpenClaw
echo "[3/4] Instalando OpenClaw..."
bash "$SCRIPT_DIR/install-openclaw.sh"
echo ""

# Paso 4: Instalar dependencias del browser (Chrome, Playwright)
if [ -f "$SCRIPT_DIR/install-browser-deps.sh" ]; then
    echo "[4/4] Instalando dependencias del browser..."
    bash "$SCRIPT_DIR/install-browser-deps.sh"
else
    echo "[4/4] Omitiendo browser deps (install-browser-deps.sh no encontrado)"
fi
echo ""

echo "========================================="
echo "[OK] Instalación completada!"
echo "========================================="
echo ""
echo "Resumen:"
echo "  - SSH configurado"
echo "  - Node.js $(node -v) instalado"
echo "  - OpenClaw instalado"
echo ""
echo "Próximos pasos:"
echo "1. Obtén tu IP: hostname -I"
echo "2. Conéctate desde Cursor usando SSH Remote"
echo "3. Ejecuta: openclaw onboard (configuración inicial)"
echo ""












