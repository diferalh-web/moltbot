#!/bin/bash
# Script para verificar si la carpeta compartida está montada
# Ejecutar en la terminal SSH de la VM

echo "========================================="
echo "Verificar Carpeta Compartida VirtualBox"
echo "========================================="
echo ""

# Verificar si VirtualBox Guest Additions está instalado
echo "[1/5] Verificando VirtualBox Guest Additions..."
if [ -f /usr/bin/VBoxClient ]; then
    echo "[OK] VirtualBox Guest Additions detectado"
    VBOX_INSTALLED=true
else
    echo "[!] VirtualBox Guest Additions no detectado"
    echo "    Puede que la carpeta compartida no funcione sin esto"
    VBOX_INSTALLED=false
fi
echo ""

# Verificar grupo vboxsf
echo "[2/5] Verificando grupo vboxsf..."
if groups | grep -q vboxsf; then
    echo "[OK] Usuario está en el grupo vboxsf"
    IN_VBOXSF=true
else
    echo "[X] Usuario NO está en el grupo vboxsf"
    echo "    Esto es necesario para acceder a carpetas compartidas"
    IN_VBOXSF=false
fi
echo ""

# Buscar montajes de VirtualBox
echo "[3/5] Buscando montajes de VirtualBox..."
MOUNTED=false
if mount | grep -q vboxsf; then
    echo "[OK] Carpetas compartidas montadas encontradas:"
    mount | grep vboxsf | while read line; do
        echo "  $line"
    done
    MOUNTED=true
else
    echo "[!] No se encontraron montajes de vboxsf"
fi
echo ""

# Buscar en ubicaciones comunes
echo "[4/5] Verificando ubicaciones comunes..."
COMMON_PATHS=(
    "/media/sf_shareFolder"
    "/media/sf_*"
    "/mnt/shareFolder"
    "/mnt/sf_*"
)

FOUND_PATH=""
for path_pattern in "${COMMON_PATHS[@]}"; do
    for path in $path_pattern; do
        if [ -d "$path" ] 2>/dev/null; then
            echo "[OK] Directorio encontrado: $path"
            if [ -f "$path/configurar-moltbot-mistral-vm.sh" ]; then
                echo "     ✓ Scripts encontrados aquí!"
                FOUND_PATH="$path"
            else
                echo "     - No se encontraron los scripts aquí"
                ls -la "$path" 2>/dev/null | head -5
            fi
        fi
    done
done

if [ -z "$FOUND_PATH" ]; then
    echo "[!] No se encontró la carpeta compartida en ubicaciones comunes"
fi
echo ""

# Verificar servicios de VirtualBox
echo "[5/5] Verificando servicios de VirtualBox..."
if systemctl list-units --type=service 2>/dev/null | grep -q vboxadd; then
    echo "[OK] Servicios de VirtualBox encontrados:"
    systemctl list-units --type=service 2>/dev/null | grep vboxadd | while read line; do
        echo "  $line"
    done
else
    echo "[!] No se encontraron servicios de VirtualBox"
fi
echo ""

# Resumen y recomendaciones
echo "========================================="
echo "Resumen y Recomendaciones"
echo "========================================="
echo ""

if [ "$IN_VBOXSF" = false ]; then
    echo "[!] ACCIÓN REQUERIDA: Agregar usuario al grupo vboxsf"
    echo ""
    echo "Ejecuta estos comandos:"
    echo "  sudo usermod -aG vboxsf $USER"
    echo "  # Luego reinicia sesión SSH:"
    echo "  exit"
    echo "  # Vuelve a conectarte"
    echo ""
fi

if [ "$MOUNTED" = false ] && [ "$VBOX_INSTALLED" = true ]; then
    echo "[!] ACCIÓN REQUERIDA: Montar carpeta compartida"
    echo ""
    echo "1. Verifica el nombre de la carpeta compartida en VirtualBox:"
    echo "   Máquina > Configuración > Carpetas compartidas"
    echo ""
    echo "2. Monta manualmente (reemplaza 'shareFolder' con el nombre real):"
    echo "   sudo mkdir -p /media/sf_shareFolder"
    echo "   sudo mount -t vboxsf shareFolder /media/sf_shareFolder"
    echo ""
    echo "3. Para montar automáticamente al iniciar, agrega a /etc/fstab:"
    echo "   shareFolder /media/sf_shareFolder vboxsf defaults 0 0"
    echo ""
fi

if [ -n "$FOUND_PATH" ]; then
    echo "[OK] Carpeta compartida encontrada en: $FOUND_PATH"
    echo ""
    echo "Para ejecutar la configuración:"
    echo "  cd $FOUND_PATH"
    echo "  chmod +x configurar-moltbot-mistral-vm.sh"
    echo "  ./configurar-moltbot-mistral-vm.sh"
    echo ""
else
    echo "[!] No se encontró la carpeta compartida con los scripts"
    echo ""
    echo "Opciones:"
    echo "  1. Verificar configuración en VirtualBox"
    echo "  2. Montar la carpeta compartida manualmente"
    echo "  3. Usar los comandos manuales de EJECUTAR_EN_VM_MISTRAL.md"
    echo ""
fi

echo "========================================="












