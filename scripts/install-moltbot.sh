#!/bin/bash

# Script de instalación - Instala OpenClaw (sucesor de Moltbot)
# Compatibilidad: este script delega a install-openclaw.sh
# Ejecutar con: bash install-moltbot.sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
exec bash "$SCRIPT_DIR/install-openclaw.sh"












