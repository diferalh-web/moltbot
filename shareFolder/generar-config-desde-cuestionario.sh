#!/bin/bash
# Script para generar archivos de configuración desde las respuestas del cuestionario
# Ejecutar desde la VM: cd /media/sf_shareFolder && chmod +x generar-config-desde-cuestionario.sh && ./generar-config-desde-cuestionario.sh

set -euo pipefail

WORKSPACE_DIR="$HOME/.openclaw/workspace"
BACKUP_DIR="$HOME/.openclaw/backup"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "Generador de Configuración - OpenClaw"
echo "========================================="
echo ""

# Crear directorio del workspace si no existe
mkdir -p "$WORKSPACE_DIR"
mkdir -p "$BACKUP_DIR"

# Backup de archivos existentes
if [ -d "$WORKSPACE_DIR" ] && [ "$(ls -A $WORKSPACE_DIR 2>/dev/null)" ]; then
    echo "[INFO] Creando backup de archivos existentes..."
    WORKSPACE_BACKUP="$BACKUP_DIR/workspace.$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$WORKSPACE_BACKUP" -C "$HOME/.openclaw" workspace 2>/dev/null && {
        echo -e "${GREEN}[OK]${NC} Backup creado: workspace.$(date +%Y%m%d_%H%M%S).tar.gz"
    }
    echo ""
fi

echo "Este script te guiará para crear los archivos de configuración."
echo "Responde las preguntas basándote en el cuestionario que completaste."
echo ""

# Función para leer respuesta
read_response() {
    local prompt="$1"
    local default="$2"
    local response
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " response
        echo "${response:-$default}"
    else
        read -p "$prompt: " response
        echo "$response"
    fi
}

# ============================================
# IDENTITY.md
# ============================================
echo "========================================="
echo "Configuración de IDENTITY.md"
echo "========================================="
echo ""

ASSISTANT_NAME=$(read_response "Nombre del asistente" "OpenClaw")
ASSISTANT_TYPE=$(read_response "Tipo de criatura/personalidad" "AI Assistant")
ASSISTANT_EMOJI=$(read_response "Emoji del asistente" "🦀")
ASSISTANT_VIBE=$(read_response "Vibe/personalidad (3-5 palabras)" "helpful, resourceful, friendly")

cat > "$WORKSPACE_DIR/IDENTITY.md" << EOF
# OpenClaw Identity

- **Name:** $ASSISTANT_NAME
- **Type:** $ASSISTANT_TYPE
- **Vibe:** $ASSISTANT_VIBE
- **Emoji:** $ASSISTANT_EMOJI
- **Avatar:** (puedes agregar una descripción o URL de avatar aquí)

## Descripción

$ASSISTANT_NAME es un asistente AI diseñado para ser $ASSISTANT_VIBE.
EOF

echo -e "${GREEN}[OK]${NC} IDENTITY.md creado"
echo ""

# ============================================
# USER.md
# ============================================
echo "========================================="
echo "Configuración de USER.md"
echo "========================================="
echo ""

USER_NAME=$(read_response "Tu nombre o cómo te gusta que te llamen" "")
USER_TIMEZONE=$(read_response "Zona horaria" "America/Mexico_City")
TONE_PREFERENCE=$(read_response "Tono preferido (formal/informal/mixto)" "mixto")

cat > "$WORKSPACE_DIR/USER.md" << EOF
# User Information

- **Name:** $USER_NAME
- **Timezone:** $USER_TIMEZONE
- **Preferred Address:** $USER_NAME
- **Tone Preference:** $TONE_PREFERENCE

## Notes

Información adicional sobre el usuario y sus preferencias.
EOF

echo -e "${GREEN}[OK]${NC} USER.md creado"
echo ""

# ============================================
# SOUL.md
# ============================================
echo "========================================="
echo "Configuración de SOUL.md"
echo "========================================="
echo ""

echo "Nivel de autonomía:"
echo "  1) Solo sugerencias, nunca ejecutar comandos"
echo "  2) Comandos simples con confirmación"
echo "  3) Comandos complejos con confirmación"
echo "  4) Alta autonomía para tareas rutinarias"
AUTONOMY_LEVEL=$(read_response "Selecciona (1-4)" "2")

echo ""
RESTRICTIONS=$(read_response "Temas o áreas que NO debe tocar (deja vacío si no hay)" "")
CONFIDENTIAL_HANDLING=$(read_response "Manejo de información confidencial (nunca/preguntar/cifrado)" "preguntar")
UNCERTAINTY_HANDLING=$(read_response "Qué hacer cuando no está seguro (preguntar/suposición/buscar)" "preguntar")
PRINCIPLES=$(read_response "Principios o valores a seguir (deja vacío para usar defaults)" "")

cat > "$WORKSPACE_DIR/SOUL.md" << EOF
# Core Truths and Boundaries

## Autonomy Level
$AUTONOMY_LEVEL

## Restrictions
$([ -n "$RESTRICTIONS" ] && echo "$RESTRICTIONS" || echo "Ninguna restricción específica")

## Confidential Information Handling
$CONFIDENTIAL_HANDLING

## Uncertainty Handling
$UNCERTAINTY_HANDLING

## Core Principles
$([ -n "$PRINCIPLES" ] && echo "$PRINCIPLES" || echo "- Treat user data with confidentiality
- Never share credentials
- Respect privacy boundaries
- Be helpful but not performative
- Earn trust through competence")

## Vibe
$ASSISTANT_VIBE

## Continuity
Maintain context and remember user preferences across sessions.
EOF

echo -e "${GREEN}[OK]${NC} SOUL.md creado"
echo ""

# ============================================
# TOOLS.md
# ============================================
echo "========================================="
echo "Configuración de TOOLS.md"
echo "========================================="
echo ""

SSH_HOSTS=$(read_response "Hosts SSH (separados por comas, deja vacío si no hay)" "")
IOT_DEVICES=$(read_response "Dispositivos IoT o cámaras (separados por comas, deja vacío si no hay)" "")
TTS_PREFERENCES=$(read_response "Preferencias de TTS/voces (deja vacío si no hay)" "")
ROOM_DEVICES=$(read_response "Nombres de habitaciones/dispositivos (separados por comas, deja vacío si no hay)" "")
LOCAL_TOOLS=$(read_response "Herramientas o servicios locales (deja vacío si no hay)" "")

cat > "$WORKSPACE_DIR/TOOLS.md" << EOF
# Local Tools Configuration

## SSH Hosts
$([ -n "$SSH_HOSTS" ] && echo "$SSH_HOSTS" || echo "Ninguno configurado")

## IoT Devices / Cameras
$([ -n "$IOT_DEVICES" ] && echo "$IOT_DEVICES" || echo "Ninguno configurado")

## TTS Preferences
$([ -n "$TTS_PREFERENCES" ] && echo "$TTS_PREFERENCES" || echo "Sin preferencias específicas")

## Room / Device Names
$([ -n "$ROOM_DEVICES" ] && echo "$ROOM_DEVICES" || echo "Sin nombres específicos")

## Local Tools / Services
$([ -n "$LOCAL_TOOLS" ] && echo "$LOCAL_TOOLS" || echo "Ninguno configurado")

## Notes
Agrega aquí cualquier otra información específica del entorno.
EOF

echo -e "${GREEN}[OK]${NC} TOOLS.md creado"
echo ""

# ============================================
# HEARTBEAT.md
# ============================================
echo "========================================="
echo "Configuración de HEARTBEAT.md"
echo "========================================="
echo ""

echo "Tareas periódicas (selecciona todas las que apliquen, separadas por comas):"
echo "  1) Estado de salud del sistema"
echo "  2) Backups automáticos"
echo "  3) Actualizaciones de seguridad"
echo "  4) Revisión de logs"
echo "  5) Verificación de servicios"
PERIODIC_TASKS=$(read_response "Tareas (1,2,3,4,5 o 'ninguna')" "1,4")

HEARTBEAT_FREQUENCY=$(read_response "Frecuencia de heartbeats (hora/diario/semanal/solicitado)" "diario")

cat > "$WORKSPACE_DIR/HEARTBEAT.md" << EOF
# Periodic Checks and Tasks

## Frequency
$HEARTBEAT_FREQUENCY

## Tasks
$PERIODIC_TASKS

## Instructions
- If nothing requires attention, reply with "HEARTBEAT_OK"
- If a task or alert needs addressing, respond appropriately without including "HEARTBEAT_OK"
EOF

echo -e "${GREEN}[OK]${NC} HEARTBEAT.md creado"
echo ""

# ============================================
# Aplicar permisos seguros
# ============================================
echo "========================================="
echo "Aplicando permisos seguros..."
echo "========================================="
echo ""

chmod 700 "$WORKSPACE_DIR" 2>/dev/null || true
find "$WORKSPACE_DIR" -type f -name "*.md" -exec chmod 600 {} \; 2>/dev/null || true

echo -e "${GREEN}[OK]${NC} Permisos aplicados"
echo ""

# ============================================
# Resumen
# ============================================
echo "========================================="
echo "Resumen"
echo "========================================="
echo ""
echo -e "${GREEN}Archivos creados en:${NC} $WORKSPACE_DIR"
echo ""
echo "Archivos generados:"
echo "  ✓ IDENTITY.md - Personalidad del asistente"
echo "  ✓ USER.md - Información del usuario"
echo "  ✓ SOUL.md - Límites y comportamiento"
echo "  ✓ TOOLS.md - Configuración del entorno"
echo "  ✓ HEARTBEAT.md - Tareas periódicas"
echo ""
echo "Puedes editar estos archivos manualmente si necesitas ajustar algo:"
echo "  nano $WORKSPACE_DIR/IDENTITY.md"
echo ""
echo "========================================="












