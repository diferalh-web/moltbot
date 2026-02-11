#!/bin/bash
# Script para eliminar la configuración del gateway que no es compatible
# Ejecutar desde la VM: cd /media/sf_shareFolder && chmod +x corregir-openclaw-gateway.sh && ./corregir-openclaw-gateway.sh

set -uo pipefail

OPENCLAW_DIR="$HOME/.openclaw"
BACKUP_DIR="$OPENCLAW_DIR/backup"

echo "========================================="
echo "Corregir openclaw.json - Eliminar gateway"
echo "========================================="
echo ""

# Crear backup
if [ -f "$OPENCLAW_DIR/openclaw.json" ]; then
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/openclaw.json.$(date +%Y%m%d_%H%M%S)"
    cp "$OPENCLAW_DIR/openclaw.json" "$BACKUP_FILE"
    echo "[OK] Backup creado: $(basename "$BACKUP_FILE")"
    echo ""
    
    # Eliminar la sección gateway
    python3 << PYTHON_SCRIPT
import json
import sys
import os

openclaw_file = "$OPENCLAW_DIR/openclaw.json"

try:
    with open(openclaw_file, 'r') as f:
        config = json.load(f)
    
    changes = False
    
    # Eliminar la sección gateway si existe
    if "gateway" in config:
        del config["gateway"]
        changes = True
        print("[OK] Sección 'gateway' eliminada")
    
    # Guardar si hubo cambios
    if changes:
        with open(openclaw_file, 'w') as f:
            json.dump(config, f, indent=2)
        print("[OK] openclaw.json corregido")
    else:
        print("[INFO] openclaw.json ya está correcto (no tiene sección gateway)")
        
except Exception as e:
    print(f"[X] Error al procesar openclaw.json: {e}")
    sys.exit(1)
PYTHON_SCRIPT
    
    # Validar JSON
    if python3 -m json.tool "$OPENCLAW_DIR/openclaw.json" > /dev/null 2>&1; then
        echo "[OK] JSON válido"
    else
        echo "[X] Error: JSON inválido después de la corrección"
        echo "    Restaurando desde backup..."
        cp "$BACKUP_FILE" "$OPENCLAW_DIR/openclaw.json"
        exit 1
    fi
else
    echo "[!] openclaw.json no existe"
    exit 1
fi

echo ""
echo "========================================="
echo "[OK] Corrección completada"
echo "========================================="
echo ""
echo "Ahora puedes probar Moltbot:"
echo "  cd ~/moltbot"
echo "  pnpm start agent --session-id test --message 'hola' --local"
echo ""












