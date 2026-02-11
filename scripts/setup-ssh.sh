#!/bin/bash

# Script para configurar SSH en Ubuntu Server
# Ejecutar con: bash setup-ssh.sh

set -e

echo "========================================="
echo "Configurando SSH en Ubuntu Server"
echo "========================================="

# Actualizar sistema
echo "Actualizando sistema..."
sudo apt update

# Instalar OpenSSH Server
echo "Instalando OpenSSH Server..."
sudo apt install -y openssh-server

# Habilitar SSH al inicio
echo "Habilitando SSH al inicio..."
sudo systemctl enable ssh

# Iniciar servicio SSH
echo "Iniciando servicio SSH..."
sudo systemctl start ssh

# Verificar estado
echo ""
echo "========================================="
echo "Verificando estado de SSH..."
echo "========================================="
sudo systemctl status ssh --no-pager

# Mostrar información de conexión
echo ""
echo "========================================="
echo "Información de conexión SSH"
echo "========================================="
IP_ADDRESS=$(hostname -I | awk '{print $1}')
USERNAME=$(whoami)

echo "Usuario: $USERNAME"
echo "IP de la VM: $IP_ADDRESS"
echo ""
echo "Para conectarte desde Windows, usa:"
echo "  ssh $USERNAME@$IP_ADDRESS"
echo ""
echo "O si configuraste port forwarding (puerto 2222):"
echo "  ssh $USERNAME@127.0.0.1 -p 2222"
echo ""
echo "✅ SSH configurado correctamente!"












