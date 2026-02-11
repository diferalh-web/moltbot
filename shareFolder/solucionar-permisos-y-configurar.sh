#!/bin/bash
# Script para agregar usuario al grupo vboxsf y configurar Mistral
# Ejecutar en la terminal SSH de la VM

echo "========================================="
echo "Solucionar Permisos y Configurar Mistral"
echo "========================================="
echo ""

# Verificar si está en el grupo
echo "[1/4] Verificando grupo vboxsf..."
if groups | grep -q vboxsf; then
    echo "[OK] Usuario ya está en el grupo vboxsf"
else
    echo "[!] Usuario NO está en el grupo vboxsf"
    echo ""
    echo "Ejecuta este comando (requiere sudo):"
    echo "  sudo usermod -aG vboxsf $USER"
    echo ""
    echo "Luego reinicia sesión SSH:"
    echo "  exit"
    echo "  # Vuelve a conectarte"
    echo ""
    read -p "¿Ya ejecutaste el comando y reiniciaste sesión? (s/n): " respuesta
    if [ "$respuesta" != "s" ] && [ "$respuesta" != "S" ]; then
        echo "Por favor ejecuta los comandos y vuelve a ejecutar este script"
        exit 1
    fi
    
    # Verificar de nuevo
    if ! groups | grep -q vboxsf; then
        echo "[X] Aún no estás en el grupo. Por favor reinicia sesión SSH."
        exit 1
    fi
    echo "[OK] Usuario agregado al grupo vboxsf"
fi

echo ""
echo "[2/4] Verificando acceso a carpeta compartida..."
SHARED_FOLDER="/media/sf_shareFolder"

if [ -d "$SHARED_FOLDER" ]; then
    echo "[OK] Carpeta compartida encontrada: $SHARED_FOLDER"
    
    # Verificar permisos
    if [ -r "$SHARED_FOLDER" ]; then
        echo "[OK] Tienes permisos de lectura"
    else
        echo "[!] No tienes permisos de lectura"
        echo "    Ejecuta: sudo chmod 755 $SHARED_FOLDER"
        exit 1
    fi
    
    # Listar archivos
    echo ""
    echo "Archivos en la carpeta compartida:"
    ls -la "$SHARED_FOLDER" | grep -E "\.sh$|total" || ls -la "$SHARED_FOLDER" | head -10
else
    echo "[X] Carpeta compartida no encontrada en $SHARED_FOLDER"
    echo "    Verifica que esté montada: mount | grep vboxsf"
    exit 1
fi

echo ""
echo "[3/4] Buscando script de configuración..."
SCRIPT_PATH="$SHARED_FOLDER/configurar-moltbot-mistral-vm.sh"

if [ -f "$SCRIPT_PATH" ]; then
    echo "[OK] Script encontrado: $SCRIPT_PATH"
else
    echo "[X] Script no encontrado: $SCRIPT_PATH"
    echo "    Archivos disponibles:"
    ls -la "$SHARED_FOLDER"
    exit 1
fi

echo ""
echo "[4/4] Ejecutando configuración de Mistral..."
echo "========================================="
echo ""

# Dar permisos de ejecución
chmod +x "$SCRIPT_PATH"

# Ejecutar el script
cd "$SHARED_FOLDER"
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












