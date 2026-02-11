#!/bin/bash

# Script para configurar SSH en la VM
# Ejecuta este script EN LA VM (desde VirtualBox)

echo "========================================="
echo "Configurando SSH en la VM"
echo "========================================="
echo ""

# Verificar que estamos como root o con sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Este script necesita permisos de sudo"
    echo "Ejecuta: sudo bash fix-ssh-in-vm.sh"
    exit 1
fi

# Paso 1: Verificar estado de SSH
echo "Paso 1: Verificando estado de SSH..."
systemctl status ssh --no-pager | head -5
echo ""

# Iniciar SSH si no está corriendo
if ! systemctl is-active --quiet ssh; then
    echo "Iniciando SSH..."
    systemctl start ssh
    systemctl enable ssh
    echo "[OK] SSH iniciado"
else
    echo "[OK] SSH ya está corriendo"
fi
echo ""

# Paso 2: Verificar configuración actual
echo "Paso 2: Configuración actual de PasswordAuthentication:"
grep -i "PasswordAuthentication" /etc/ssh/sshd_config | grep -v "^#"
echo ""

# Paso 3: Hacer backup
echo "Paso 3: Creando backup de configuración..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d_%H%M%S)
echo "[OK] Backup creado"
echo ""

# Paso 4: Habilitar autenticación por contraseña
echo "Paso 4: Habilitando autenticación por contraseña..."

# Comentar líneas que deshabilitan PasswordAuthentication
sed -i 's/^PasswordAuthentication no/#PasswordAuthentication no/' /etc/ssh/sshd_config

# Descomentar y habilitar PasswordAuthentication
if grep -q "^#PasswordAuthentication yes" /etc/ssh/sshd_config; then
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    echo "[OK] PasswordAuthentication habilitado (descomentado)"
elif ! grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
    echo "[OK] PasswordAuthentication agregado"
else
    echo "[OK] PasswordAuthentication ya está habilitado"
fi
echo ""

# Paso 5: Verificar cambios
echo "Paso 5: Verificando cambios:"
grep -i "PasswordAuthentication" /etc/ssh/sshd_config | grep -v "^#"
echo ""

# Paso 6: Reiniciar SSH
echo "Paso 6: Reiniciando SSH..."
systemctl restart ssh
sleep 2
systemctl status ssh --no-pager | head -5
echo ""

echo "========================================="
echo "[OK] SSH configurado correctamente!"
echo "========================================="
echo ""
echo "Ahora intenta conectarte desde Windows:"
echo "  ssh moltbot@127.0.0.1 -p 2222"
echo ""












