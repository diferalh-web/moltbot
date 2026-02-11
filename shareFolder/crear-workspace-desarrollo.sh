#!/bin/bash

# Crea el workspace de OpenClaw con plantillas para desarrollo autónomo
# Ejecutar en la VM: bash crear-workspace-desarrollo.sh

set -e

WORKSPACE_DIR="$HOME/.openclaw/workspace"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "========================================="
echo "Creando workspace de desarrollo"
echo "========================================="

mkdir -p "$WORKSPACE_DIR"

# Copiar plantillas si existen
for file in AGENTS-desarrollo.md.template TOOLS-desarrollo.md.template; do
    src="$SCRIPT_DIR/$file"
    if [ -f "$src" ]; then
        base="${file%.template}"
        case "$base" in
            AGENTS-desarrollo.md) dest="$WORKSPACE_DIR/AGENTS.md" ;;
            TOOLS-desarrollo.md) dest="$WORKSPACE_DIR/TOOLS.md" ;;
            *) dest="$WORKSPACE_DIR/${base%.md}.md" ;;
        esac
        cp "$src" "$dest"
        echo "[OK] $dest"
    fi
done

# Crear SOUL.md si no existe (mínimo para desarrollo)
if [ ! -f "$WORKSPACE_DIR/SOUL.md" ]; then
    cat > "$WORKSPACE_DIR/SOUL.md" << 'EOF'
# Core Truths

- Be resourceful: try to figure it out before asking.
- Earn trust through competence.
- When developing: plan first, then execute. Iterate until it works.
EOF
    echo "[OK] $WORKSPACE_DIR/SOUL.md (creado)"
fi

echo ""
echo "Workspace listo en: $WORKSPACE_DIR"
echo ""
