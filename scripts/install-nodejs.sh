#!/bin/bash

# Script de instalación de Node.js 22+ en Ubuntu Server
# Ejecutar con: bash install-nodejs.sh

set -e  # Salir si hay algún error

echo "========================================="
echo "Instalando Node.js 22.x en Ubuntu Server"
echo "========================================="

# Actualizar sistema
echo "Actualizando sistema..."
sudo apt update
sudo apt upgrade -y

# Instalar dependencias necesarias
echo "Instalando dependencias..."
sudo apt install -y curl gnupg ca-certificates

# Agregar repositorio de NodeSource
echo "Agregando repositorio de NodeSource..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

# Instalar Node.js
echo "Instalando Node.js 22.x..."
sudo apt-get install -y nodejs

# Verificar instalación
echo ""
echo "========================================="
echo "Verificando instalación..."
echo "========================================="
node --version
npm --version

echo ""
echo "✅ Node.js instalado correctamente!"
echo "Versión de Node.js: $(node --version)"
echo "Versión de npm: $(npm --version)"












