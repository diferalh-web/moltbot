#!/bin/bash
# Script para encontrar la carpeta compartida y ejecutar configuración de Mistral
# Ejecutar en la terminal SSH de la VM

echo "========================================="
echo "Buscar Carpeta Compartida y Configurar Mistral"
echo "========================================="
echo ""

# Buscar el script en ubicaciones comunes
SCRIPT_NAME="configurar-moltbot-mistral-vm.sh"
SCRIPT_PATH=""

echo "[1/4] Buscando carpeta compartida..."
echo ""

# Ubicaciones comunes para VirtualBox Shared Folders
COMMON_PATHS=(
    "/media/sf_shareFolder"
    "/mnt/shareFolder"
    "/media/*/shareFolder"
    "/mnt/*/shareFolder"
    "/media/sf_*"
    "/mnt/sf_*"
)

# Buscar en ubicaciones comunes
for path in "${COMMON_PATHS[@]}"; do
    if [ -f "$path/$SCRIPT_NAME" ]; then
        SCRIPT_PATH="$path/$SCRIPT_NAME"
        echo "[OK] Encontrado en: $path"
        break
    fi
done

# Si no se encontró, buscar en todo el sistema
if [ -z "$SCRIPT_PATH" ]; then
    echo "[!] No encontrado en ubicaciones comunes, buscando en todo el sistema..."
    SCRIPT_PATH=$(find / -name "$SCRIPT_NAME" 2>/dev/null | head -1)
    
    if [ -n "$SCRIPT_PATH" ]; then
        echo "[OK] Encontrado en: $(dirname $SCRIPT_PATH)"
    else
        echo "[X] No se encontró el script $SCRIPT_NAME"
        echo ""
        echo "Ubicaciones verificadas:"
        for path in "${COMMON_PATHS[@]}"; do
            echo "  - $path"
        done
        echo ""
        echo "Solución:"
        echo "  1. Verifica que la carpeta compartida esté montada en VirtualBox"
        echo "  2. Verifica que tu usuario esté en el grupo vboxsf:"
        echo "     groups | grep vboxsf"
        echo "  3. Si no estás en el grupo, ejecuta:"
        echo "     sudo usermod -aG vboxsf $USER"
        echo "     (luego reinicia sesión)"
        exit 1
    fi
fi

echo ""
echo "[2/4] Verificando permisos..."
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
cd "$SCRIPT_DIR"

if [ ! -x "$SCRIPT_PATH" ]; then
    echo "[!] El script no tiene permisos de ejecución, agregando..."
    chmod +x "$SCRIPT_PATH"
    echo "[OK] Permisos agregados"
else
    echo "[OK] El script ya tiene permisos de ejecución"
fi

echo ""
echo "[3/4] Verificando que el script sea válido..."
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "[X] El script no existe: $SCRIPT_PATH"
    exit 1
fi

echo "[OK] Script encontrado y válido"
echo ""
echo "[4/4] Ejecutando configuración de Mistral..."
echo "========================================="
echo ""

# Ejecutar el script
bash "$SCRIPT_PATH"

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "[OK] Configuración completada exitosamente!"
    echo "========================================="
    echo ""
    echo "Próximo paso: Probar Moltbot"
    echo "  cd ~/moltbot"
    echo "  pnpm start agent --session-id test-session --message 'hola' --local"
    echo ""
else
    echo ""
    echo "========================================="
    echo "[X] Hubo un error durante la configuración"
    echo "========================================="
    echo ""
    echo "Revisa los mensajes de error arriba"
    echo "Los backups están en: ~/.openclaw/backup/"
    exit $EXIT_CODE
fi












