#!/bin/bash
# Script para validar la configuración actual sin hacer cambios
# Útil para verificar el estado antes de aplicar mejoras de seguridad
# Ejecutar desde la VM: cd /media/sf_shareFolder && chmod +x validar-configuracion.sh && ./validar-configuracion.sh

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Directorios
OPENCLAW_DIR="$HOME/.openclaw"
AGENT_DIR="$OPENCLAW_DIR/agents/main/agent"
WORKSPACE_DIR="$OPENCLAW_DIR/workspace"

# Contadores
ISSUES=0
WARNINGS=0

echo "========================================="
echo "Validación de Configuración - Moltbot"
echo "========================================="
echo ""

# Función para logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
    ((WARNINGS++))
}

log_error() {
    echo -e "${RED}[X]${NC} $1"
    ((ISSUES++))
}

# Función para validar JSON
validate_json() {
    local file="$1"
    if [ ! -f "$file" ]; then
        return 1
    fi
    python3 -m json.tool "$file" > /dev/null 2>&1
}

# Función para verificar permisos
check_permissions() {
    local file="$1"
    local expected_perm="$2"
    local current_perm=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%OLp" "$file" 2>/dev/null || echo "unknown")
    
    if [ "$current_perm" = "$expected_perm" ]; then
        return 0
    fi
    return 1
}

# ============================================
# Validar estructura de directorios
# ============================================
echo "[1/7] Validando estructura de directorios..."

if [ ! -d "$OPENCLAW_DIR" ]; then
    log_error "Directorio ~/.openclaw no existe"
    echo "  Ejecuta: pnpm start onboard"
else
    log_success "Directorio ~/.openclaw existe"
fi

if [ ! -d "$AGENT_DIR" ]; then
    log_warning "Directorio del agente no existe: $AGENT_DIR"
else
    log_success "Directorio del agente existe"
fi

if [ ! -d "$WORKSPACE_DIR" ]; then
    log_info "Directorio del workspace no existe (opcional)"
else
    log_success "Directorio del workspace existe"
fi

echo ""

# ============================================
# Validar archivos JSON
# ============================================
echo "[2/7] Validando archivos JSON..."

JSON_FILES=(
    "$OPENCLAW_DIR/openclaw.json"
    "$AGENT_DIR/config.json"
    "$AGENT_DIR/models.json"
    "$AGENT_DIR/auth-profiles.json"
)

for file in "${JSON_FILES[@]}"; do
    if [ -f "$file" ]; then
        if validate_json "$file"; then
            log_success "JSON válido: $(basename "$file")"
        else
            log_error "JSON inválido: $(basename "$file")"
        fi
    else
        log_info "No existe: $(basename "$file") (puede ser normal)"
    fi
done

echo ""

# ============================================
# Validar permisos de directorios
# ============================================
echo "[3/7] Validando permisos de directorios..."

if [ -d "$OPENCLAW_DIR" ]; then
    if check_permissions "$OPENCLAW_DIR" "700"; then
        log_success "Permisos correctos en ~/.openclaw (700)"
    else
        perm=$(stat -c "%a" "$OPENCLAW_DIR" 2>/dev/null || echo "unknown")
        log_warning "Permisos incorrectos en ~/.openclaw: $perm (debería ser 700)"
    fi
fi

if [ -d "$WORKSPACE_DIR" ]; then
    if check_permissions "$WORKSPACE_DIR" "700"; then
        log_success "Permisos correctos en workspace (700)"
    else
        perm=$(stat -c "%a" "$WORKSPACE_DIR" 2>/dev/null || echo "unknown")
        log_warning "Permisos incorrectos en workspace: $perm (debería ser 700)"
    fi
fi

if [ -d "$AGENT_DIR" ]; then
    if check_permissions "$AGENT_DIR" "700"; then
        log_success "Permisos correctos en agent (700)"
    else
        perm=$(stat -c "%a" "$AGENT_DIR" 2>/dev/null || echo "unknown")
        log_warning "Permisos incorrectos en agent: $perm (debería ser 700)"
    fi
fi

echo ""

# ============================================
# Validar permisos de archivos
# ============================================
echo "[4/7] Validando permisos de archivos..."

for file in "${JSON_FILES[@]}"; do
    if [ -f "$file" ]; then
        if check_permissions "$file" "600"; then
            log_success "Permisos correctos en $(basename "$file") (600)"
        else
            perm=$(stat -c "%a" "$file" 2>/dev/null || echo "unknown")
            log_warning "Permisos incorrectos en $(basename "$file"): $perm (debería ser 600)"
        fi
    fi
done

# Validar archivos del workspace
if [ -d "$WORKSPACE_DIR" ]; then
    WORKSPACE_FILES=$(find "$WORKSPACE_DIR" -type f -name "*.md" 2>/dev/null | wc -l)
    if [ "$WORKSPACE_FILES" -gt 0 ]; then
        UNSAFE_FILES=$(find "$WORKSPACE_DIR" -type f -name "*.md" ! -perm 600 2>/dev/null | wc -l)
        if [ "$UNSAFE_FILES" -eq 0 ]; then
            log_success "Todos los archivos del workspace tienen permisos seguros"
        else
            log_warning "$UNSAFE_FILES archivo(s) del workspace con permisos inseguros"
        fi
    fi
fi

echo ""

# ============================================
# Validar configuración del gateway
# ============================================
echo "[5/7] Validando configuración del gateway..."

if [ -f "$OPENCLAW_DIR/openclaw.json" ]; then
    python3 << PYTHON_SCRIPT
import json
import os
import sys

openclaw_file = "$OPENCLAW_DIR/openclaw.json"

try:
    with open(openclaw_file, 'r') as f:
        config = json.load(f)
    
    # Verificar si tiene configuración de gateway
    if "gateway" in config:
        gateway = config.get("gateway", {})
        host = gateway.get("host", "0.0.0.0")
        port = gateway.get("port", 18789)
        
        print("[!] openclaw.json contiene configuración 'gateway'")
        print(f"    host: {host}, port: {port}")
        print("    Nota: Esta configuración puede no ser compatible con esta versión")
        print("    Si Moltbot da error, ejecuta: ./corregir-openclaw-gateway.sh")
    else:
        print("[OK] openclaw.json no tiene configuración de gateway (correcto para esta versión)")
        
except Exception as e:
    print(f"[!] Error al leer openclaw.json: {e}")
PYTHON_SCRIPT
else
    log_info "openclaw.json no existe (puede usar variables de entorno)"
fi

echo ""

# ============================================
# Validar seguridad de credenciales
# ============================================
echo "[6/7] Validando seguridad de credenciales..."

# Verificar auth-profiles.json
if [ -f "$AGENT_DIR/auth-profiles.json" ]; then
    if check_permissions "$AGENT_DIR/auth-profiles.json" "600"; then
        log_success "auth-profiles.json tiene permisos seguros (600)"
    else
        perm=$(stat -c "%a" "$AGENT_DIR/auth-profiles.json" 2>/dev/null || echo "unknown")
        log_error "auth-profiles.json tiene permisos inseguros: $perm (debería ser 600)"
    fi
    
    # Verificar si está en git
    if [ -d "$OPENCLAW_DIR/.git" ]; then
        if git -C "$OPENCLAW_DIR" ls-files --error-unmatch "$AGENT_DIR/auth-profiles.json" > /dev/null 2>&1; then
            log_error "auth-profiles.json está siendo rastreado por git!"
            log_info "Agrega auth-profiles.json a .gitignore"
        else
            log_success "auth-profiles.json no está en git (correcto)"
        fi
    fi
else
    log_info "auth-profiles.json no existe (puede usar variables de entorno)"
fi

# Verificar .env
if [ -f "$OPENCLAW_DIR/.env" ]; then
    if check_permissions "$OPENCLAW_DIR/.env" "600"; then
        log_success ".env tiene permisos seguros (600)"
    else
        perm=$(stat -c "%a" "$OPENCLAW_DIR/.env" 2>/dev/null || echo "unknown")
        log_warning ".env tiene permisos inseguros: $perm (debería ser 600)"
    fi
fi

# Verificar archivos legibles por otros
UNSAFE_FILES=$(find "$OPENCLAW_DIR" -type f -perm /o+r 2>/dev/null | grep -v ".git" | wc -l)
if [ "$UNSAFE_FILES" -eq 0 ]; then
    log_success "No hay archivos legibles por otros usuarios"
else
    log_warning "$UNSAFE_FILES archivo(s) legible(s) por otros usuarios"
    log_info "Archivos con permisos inseguros:"
    find "$OPENCLAW_DIR" -type f -perm /o+r 2>/dev/null | grep -v ".git" | head -10 | while read file; do
        perm=$(stat -c "%a" "$file" 2>/dev/null || echo "unknown")
        log_info "  - $file (permisos: $perm)"
    done
    log_info "Ejecuta './aplicar-mejoras-seguridad.sh' para corregir automáticamente"
fi

echo ""

# ============================================
# Validar archivos del workspace
# ============================================
echo "[7/7] Validando archivos del workspace..."

if [ -d "$WORKSPACE_DIR" ]; then
    WORKSPACE_FILES=(
        "IDENTITY.md"
        "USER.md"
        "SOUL.md"
        "TOOLS.md"
        "HEARTBEAT.md"
    )
    
    for file in "${WORKSPACE_FILES[@]}"; do
        if [ -f "$WORKSPACE_DIR/$file" ]; then
            log_success "$file existe"
        else
            log_info "$file no existe (opcional)"
        fi
    done
else
    log_info "Workspace no configurado (opcional)"
fi

echo ""

# ============================================
# Resumen
# ============================================
echo "========================================="
echo "Resumen de Validación"
echo "========================================="
echo -e "${GREEN}Validaciones exitosas${NC}: $((${#JSON_FILES[@]} + 5 - ISSUES - WARNINGS))"
echo -e "${YELLOW}Advertencias${NC}: $WARNINGS"
echo -e "${RED}Problemas encontrados${NC}: $ISSUES"
echo ""

if [ $ISSUES -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    log_success "¡Configuración validada correctamente!"
    echo ""
    echo "Tu configuración cumple con las mejores prácticas de seguridad."
elif [ $ISSUES -eq 0 ]; then
    log_warning "Configuración válida con algunas advertencias menores"
    echo ""
    echo "Considera ejecutar: ./aplicar-mejoras-seguridad.sh"
else
    log_error "Se encontraron problemas que deben corregirse"
    echo ""
    echo "Ejecuta: ./aplicar-mejoras-seguridad.sh para corregir automáticamente"
fi

echo ""
echo "========================================="

exit $ISSUES

