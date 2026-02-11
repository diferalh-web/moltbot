#!/bin/bash

# Instala Google Chrome y Playwright para el browser tool de OpenClaw
# Requerido para pruebas web headless en la VM
# Ejecutar con: bash install-browser-deps.sh
# Ref: https://docs.molt.bot/tools/browser-linux-troubleshooting

set -e

echo "========================================="
echo "Instalando dependencias del browser"
echo "========================================="

# Verificar que estamos en Linux
if [[ "$(uname)" != "Linux" ]]; then
    echo "[!] Este script está diseñado para Linux (Ubuntu/Debian)"
    exit 1
fi

# 1. Instalar Google Chrome (.deb) - evita problemas con Chromium snap/AppArmor
echo ""
echo "[1/3] Instalando Google Chrome..."

if command -v google-chrome-stable &> /dev/null || [ -f /usr/bin/google-chrome-stable ]; then
    echo "[OK] Google Chrome ya está instalado"
else
    cd /tmp
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb || {
        echo "[X] No se pudo descargar Chrome. Prueba manualmente:"
        echo "    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
        echo "    sudo dpkg -i google-chrome-stable_current_amd64.deb"
        exit 1
    }
    sudo dpkg -i google-chrome-stable_current_amd64.deb || sudo apt-get install -f -y
    rm -f google-chrome-stable_current_amd64.deb
    echo "[OK] Google Chrome instalado"
fi

# 2. Instalar dependencias del sistema para Chromium
echo ""
echo "[2/3] Instalando dependencias del sistema..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
    libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 \
    libdrm2 libdbus-1-3 libxkbcommon0 libatspi2.0-0 libxcomposite1 \
    libxdamage1 libxfixes3 libxrandr2 libgbm1 libasound2 2>/dev/null || true

# 3. Instalar Playwright Chromium (para el agente)
echo ""
echo "[3/3] Instalando Playwright Chromium..."

if command -v npx &> /dev/null; then
    npx playwright install chromium 2>/dev/null || {
        echo "[!] Playwright se instalará cuando OpenClaw lo requiera"
        echo "    Ejecuta manualmente: npx playwright install chromium"
    }
else
    echo "[!] npx no encontrado. Instala Node.js primero."
fi

# Verificar instalación
echo ""
echo "========================================="
echo "Verificando instalación"
echo "========================================="

if [ -f /usr/bin/google-chrome-stable ]; then
    echo "[OK] Google Chrome: /usr/bin/google-chrome-stable"
else
    echo "[!] Chrome no encontrado en /usr/bin/google-chrome-stable"
fi

echo ""
echo "Configuración para openclaw.json:"
echo '  "browser": {'
echo '    "enabled": true,'
echo '    "headless": true,'
echo '    "noSandbox": true,'
echo '    "executablePath": "/usr/bin/google-chrome-stable"'
echo '  }'
echo ""
