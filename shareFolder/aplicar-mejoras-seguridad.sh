#!/bin/bash
# Script para aplicar mejoras de seguridad a la configuración de Moltbot/OpenClaw
# Valida la configuración actual y aplica cambios de forma segura
# Ejecutar desde la VM: cd /media/sf_shareFolder && chmod +x aplicar-mejoras-seguridad.sh && ./aplicar-mejoras-seguridad.sh

set -uo pipefail
# Nota: No usamos 'set -e' para permitir que el script continúe aunque algunos archivos no se puedan actualizar

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directorios
OPENCLAW_DIR="$HOME/.openclaw"
AGENT_DIR="$OPENCLAW_DIR/agents/main/agent"
WORKSPACE_DIR="$OPENCLAW_DIR/workspace"
BACKUP_DIR="$OPENCLAW_DIR/backup"

# Contador de cambios
CHANGES_MADE=0
WARNINGS=0
ERRORS=0

echo "========================================="
echo "Aplicar Mejoras de Seguridad - Moltbot"
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
    ((ERRORS++))
}

# Función para validar JSON
validate_json() {
    local file="$1"
    if [ ! -f "$file" ]; then
        return 1
    fi
    python3 -m json.tool "$file" > /dev/null 2>&1
}

# Función para hacer backup
create_backup() {
    local file="$1"
    local backup_name=$(basename "$file")
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    mkdir -p "$BACKUP_DIR"
    cp "$file" "$BACKUP_DIR/${backup_name}.${timestamp}" 2>/dev/null || {
        log_error "No se pudo crear backup de $file"
        return 1
    }
    log_success "Backup creado: ${backup_name}.${timestamp}"
    return 0
}

# Función para verificar permisos
check_permissions() {
    local file="$1"
    local expected_perm="$2"
    local current_perm=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%OLp" "$file" 2>/dev/null || echo "unknown")
    
    if [ "$current_perm" != "$expected_perm" ]; then
        return 1
    fi
    return 0
}

# Función para aplicar permisos seguros
apply_secure_permissions() {
    local file="$1"
    local expected_perm="$2"
    
    if check_permissions "$file" "$expected_perm"; then
        log_info "Permisos correctos en $(basename "$file")"
        return 0
    fi
    
    if [ -f "$file" ]; then
        chmod "$expected_perm" "$file" 2>/dev/null && {
            log_success "Permisos actualizados: $(basename "$file") -> $expected_perm"
            ((CHANGES_MADE++))
            return 0
        } || {
            log_warning "No se pudieron actualizar permisos de $(basename "$file") (puede requerir sudo)"
            return 1
        }
    fi
    return 1
}

# ============================================
# PASO 1: Validar estructura de directorios
# ============================================
echo "[1/8] Validando estructura de directorios..."
if [ ! -d "$OPENCLAW_DIR" ]; then
    log_error "Directorio ~/.openclaw no existe"
    echo "  Ejecuta primero: pnpm start onboard"
    exit 1
fi

if [ ! -d "$AGENT_DIR" ]; then
    log_warning "Directorio del agente no existe: $AGENT_DIR"
    log_info "Algunas validaciones se omitirán"
fi

log_success "Estructura de directorios validada"
echo ""

# ============================================
# PASO 2: Crear backups de todos los archivos
# ============================================
echo "[2/8] Creando backups de seguridad..."

# Backup de archivos de configuración
FILES_TO_BACKUP=(
    "$OPENCLAW_DIR/openclaw.json"
    "$AGENT_DIR/config.json"
    "$AGENT_DIR/models.json"
    "$AGENT_DIR/auth-profiles.json"
)

for file in "${FILES_TO_BACKUP[@]}"; do
    if [ -f "$file" ]; then
        create_backup "$file"
    fi
done

# Backup del workspace si existe
if [ -d "$WORKSPACE_DIR" ]; then
    WORKSPACE_BACKUP="$BACKUP_DIR/workspace.$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$WORKSPACE_BACKUP" -C "$OPENCLAW_DIR" workspace 2>/dev/null && {
        log_success "Backup del workspace creado"
    } || {
        log_warning "No se pudo crear backup del workspace"
    }
fi

log_success "Backups completados"
echo ""

# ============================================
# PASO 3: Validar archivos JSON existentes
# ============================================
echo "[3/8] Validando archivos JSON..."

JSON_FILES=(
    "$OPENCLAW_DIR/openclaw.json"
    "$AGENT_DIR/config.json"
    "$AGENT_DIR/models.json"
    "$AGENT_DIR/auth-profiles.json"
)

VALIDATION_FAILED=0
for file in "${JSON_FILES[@]}"; do
    if [ -f "$file" ]; then
        if validate_json "$file"; then
            log_success "JSON válido: $(basename "$file")"
        else
            log_error "JSON inválido: $(basename "$file")"
            ((VALIDATION_FAILED++))
        fi
    fi
done

if [ $VALIDATION_FAILED -gt 0 ]; then
    log_error "Hay $VALIDATION_FAILED archivo(s) JSON inválido(s)"
    echo "  Revisa los archivos antes de continuar"
    read -p "¿Continuar de todas formas? (s/n): " continue_anyway
    if [ "${continue_anyway:-n}" != "s" ] && [ "${continue_anyway:-n}" != "S" ]; then
        exit 1
    fi
fi
echo ""

# ============================================
# PASO 4: Aplicar permisos seguros a directorios
# ============================================
echo "[4/8] Aplicando permisos seguros a directorios..."

# Directorio principal
if [ -d "$OPENCLAW_DIR" ]; then
    if check_permissions "$OPENCLAW_DIR" "700"; then
        log_info "Permisos ya correctos en ~/.openclaw (700)"
    else
        if chmod 700 "$OPENCLAW_DIR" 2>/dev/null; then
            log_success "Permisos aplicados a ~/.openclaw (700)"
            ((CHANGES_MADE++))
        else
            log_warning "No se pudieron aplicar permisos a ~/.openclaw (puede requerir sudo)"
        fi
    fi
fi

# Directorio del workspace
if [ -d "$WORKSPACE_DIR" ]; then
    if check_permissions "$WORKSPACE_DIR" "700"; then
        log_info "Permisos ya correctos en workspace (700)"
    else
        if chmod 700 "$WORKSPACE_DIR" 2>/dev/null; then
            log_success "Permisos aplicados a workspace (700)"
            ((CHANGES_MADE++))
        else
            log_warning "No se pudieron aplicar permisos a workspace (puede requerir sudo)"
        fi
    fi
fi

# Directorio del agente
if [ -d "$AGENT_DIR" ]; then
    if check_permissions "$AGENT_DIR" "700"; then
        log_info "Permisos ya correctos en agent (700)"
    else
        if chmod 700 "$AGENT_DIR" 2>/dev/null; then
            log_success "Permisos aplicados a agent (700)"
            ((CHANGES_MADE++))
        else
            log_warning "No se pudieron aplicar permisos a agent (puede requerir sudo)"
        fi
    fi
fi

# Directorio de backups
if [ -d "$BACKUP_DIR" ]; then
    if check_permissions "$BACKUP_DIR" "700"; then
        log_info "Permisos ya correctos en backup (700)"
    else
        if chmod 700 "$BACKUP_DIR" 2>/dev/null; then
            log_success "Permisos aplicados a backup (700)"
            ((CHANGES_MADE++))
        fi
    fi
fi

echo ""

# ============================================
# PASO 5: Aplicar permisos seguros a archivos
# ============================================
echo "[5/8] Aplicando permisos seguros a archivos..."

# Archivos de configuración: 600
for file in "${JSON_FILES[@]}"; do
    if [ -f "$file" ]; then
        apply_secure_permissions "$file" "600"
    fi
done

# Archivos del workspace: 600
if [ -d "$WORKSPACE_DIR" ]; then
    WORKSPACE_FIXED=0
    WORKSPACE_FAILED=0
    while IFS= read -r file; do
        if chmod 600 "$file" 2>/dev/null; then
            ((WORKSPACE_FIXED++))
        else
            ((WORKSPACE_FAILED++))
        fi
    done < <(find "$WORKSPACE_DIR" -type f -name "*.md" 2>/dev/null)
    
    if [ $WORKSPACE_FIXED -gt 0 ]; then
        log_success "Permisos aplicados a $WORKSPACE_FIXED archivo(s) del workspace"
        ((CHANGES_MADE++))
    fi
    if [ $WORKSPACE_FAILED -gt 0 ]; then
        log_warning "$WORKSPACE_FAILED archivo(s) del workspace no pudieron actualizarse (puede requerir sudo)"
    fi
fi

echo ""

# ============================================
# PASO 6: Validar openclaw.json
# ============================================
echo "[6/8] Validando openclaw.json..."

if [ -f "$OPENCLAW_DIR/openclaw.json" ]; then
    # Validar que el JSON sea válido
    if validate_json "$OPENCLAW_DIR/openclaw.json"; then
        log_success "openclaw.json es válido"
        
        # Verificar si tiene configuración de gateway no soportada
        if grep -q '"gateway"' "$OPENCLAW_DIR/openclaw.json" 2>/dev/null; then
            log_warning "openclaw.json contiene configuración 'gateway' que puede no ser compatible"
            log_info "Si Moltbot da error, ejecuta: ./corregir-openclaw-gateway.sh"
        fi
    else
        log_error "openclaw.json es inválido"
    fi
else
    log_info "openclaw.json no existe (puede ser normal si usas variables de entorno)"
fi

echo ""

# ============================================
# PASO 7: Verificar que no haya credenciales expuestas
# ============================================
echo "[7/8] Verificando seguridad de credenciales..."

# Verificar que auth-profiles.json tenga permisos correctos
if [ -f "$AGENT_DIR/auth-profiles.json" ]; then
    if check_permissions "$AGENT_DIR/auth-profiles.json" "600"; then
        log_success "auth-profiles.json tiene permisos seguros"
    else
        log_warning "auth-profiles.json no tiene permisos seguros"
        apply_secure_permissions "$AGENT_DIR/auth-profiles.json" "600"
    fi
    
    # Verificar que no esté en git (si existe .git)
    if [ -d "$OPENCLAW_DIR/.git" ]; then
        if git -C "$OPENCLAW_DIR" ls-files --error-unmatch "$AGENT_DIR/auth-profiles.json" > /dev/null 2>&1; then
            log_error "auth-profiles.json está siendo rastreado por git!"
            log_info "Considera agregarlo a .gitignore"
        fi
    fi
else
    log_info "auth-profiles.json no existe (puede usar variables de entorno)"
fi

# Verificar archivos .env
if [ -f "$OPENCLAW_DIR/.env" ]; then
    if check_permissions "$OPENCLAW_DIR/.env" "600"; then
        log_success ".env tiene permisos seguros"
    else
        apply_secure_permissions "$OPENCLAW_DIR/.env" "600"
    fi
fi

# Corregir archivos legibles por otros usuarios
UNSAFE_FILES=$(find "$OPENCLAW_DIR" -type f -perm /o+r 2>/dev/null | grep -v ".git" | wc -l)
if [ "$UNSAFE_FILES" -gt 0 ]; then
    log_warning "Encontrados $UNSAFE_FILES archivo(s) legible(s) por otros usuarios"
    log_info "Corrigiendo permisos automáticamente..."
    
    FIXED_COUNT=0
    while IFS= read -r file; do
        # Determinar permisos apropiados basados en el tipo de archivo
        if [[ "$file" == *.json ]] || [[ "$file" == *.md ]] || [[ "$file" == *.env ]] || [[ "$file" == *.key ]]; then
            if chmod 600 "$file" 2>/dev/null; then
                ((FIXED_COUNT++))
            fi
        elif [[ "$file" == *.sh ]] || [[ -x "$file" ]]; then
            if chmod 700 "$file" 2>/dev/null; then
                ((FIXED_COUNT++))
            fi
        else
            if chmod 600 "$file" 2>/dev/null; then
                ((FIXED_COUNT++))
            fi
        fi
    done < <(find "$OPENCLAW_DIR" -type f -perm /o+r 2>/dev/null | grep -v ".git")
    
    if [ $FIXED_COUNT -gt 0 ]; then
        log_success "Corregidos $FIXED_COUNT archivo(s)"
        ((CHANGES_MADE++))
    else
        log_warning "No se pudieron corregir algunos archivos (puede requerir sudo)"
    fi
else
    log_success "No hay archivos legibles por otros usuarios"
fi

echo ""

# ============================================
# PASO 8: Validación final y resumen
# ============================================
echo "[8/8] Validación final..."

# Re-validar JSON después de cambios
VALIDATION_FAILED=0
for file in "${JSON_FILES[@]}"; do
    if [ -f "$file" ]; then
        if ! validate_json "$file"; then
            log_error "JSON inválido después de cambios: $(basename "$file")"
            ((VALIDATION_FAILED++))
        fi
    fi
done

if [ $VALIDATION_FAILED -gt 0 ]; then
    log_error "ALERTA: Algunos archivos JSON quedaron inválidos"
    log_info "Puedes restaurar desde: $BACKUP_DIR"
    exit 1
fi

# Resumen
echo ""
echo "========================================="
echo "Resumen de Cambios"
echo "========================================="
echo -e "${GREEN}Cambios aplicados:${NC} $CHANGES_MADE"
echo -e "${YELLOW}Advertencias:${NC} $WARNINGS"
echo -e "${RED}Errores:${NC} $ERRORS"
echo ""
echo "Backups guardados en: $BACKUP_DIR"
echo ""

if [ $ERRORS -eq 0 ]; then
    log_success "¡Mejoras de seguridad aplicadas exitosamente!"
    echo ""
    echo "Próximos pasos recomendados:"
    echo "  1. Verificar que Moltbot sigue funcionando:"
    echo "     cd ~/moltbot && pnpm start agent --message 'test' --local"
    echo "  2. Revisar permisos: find ~/.openclaw -type f -perm /o+r"
    echo "  3. Configurar .gitignore si usas git"
    echo ""
else
    log_warning "Hubo algunos errores. Revisa los mensajes arriba."
    echo "  Puedes restaurar desde los backups si es necesario"
    echo ""
fi

echo "========================================="

