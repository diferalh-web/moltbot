#!/bin/bash
# Script interactivo para probar diferentes funcionalidades de Moltbot
# Ejecutar: cd /media/sf_shareFolder && chmod +x probar-funcionalidades.sh && ./probar-funcionalidades.sh

set -uo pipefail

cd ~/moltbot

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Función para mostrar menú
show_menu() {
    clear
    echo -e "${CYAN}=========================================${NC}"
    echo -e "${CYAN}   Probar Funcionalidades de Moltbot${NC}"
    echo -e "${CYAN}=========================================${NC}"
    echo ""
    echo -e "${GREEN}Comandos Básicos:${NC}"
    echo "  1) Ver ayuda y comandos disponibles"
    echo "  2) Ver estado del sistema (health/status)"
    echo "  3) Ver configuración actual"
    echo ""
    echo -e "${GREEN}Conversación:${NC}"
    echo "  4) Probar conversación básica (mensaje personalizado)"
    echo "  5) Probar memoria/contexto (misma sesión)"
    echo "  6) Probar pregunta rápida predefinida"
    echo ""
    echo -e "${GREEN}Pruebas Específicas:${NC}"
    echo "  7) Pregunta técnica (Docker/APIs)"
    echo "  8) Pregunta creativa (poema/creatividad)"
    echo "  9) Pregunta de programación (código)"
    echo "  10) Pregunta de análisis (comparación)"
    echo ""
    echo -e "${GREEN}Utilidades:${NC}"
    echo "  11) Verificar conexión con Mistral"
    echo "  12) Ver logs/errores recientes"
    echo "  13) Cambiar modelo (si tienes varios)"
    echo ""
    echo -e "${RED}  0) Salir${NC}"
    echo ""
}

# Función para esperar antes de continuar
wait_for_user() {
    echo ""
    echo -e "${YELLOW}Presiona Enter para continuar...${NC}"
    read
}

# Loop principal
while true; do
    show_menu
    read -p "Selecciona una opción (0-13): " opcion
    echo ""

    case $opcion in
        1)
            echo -e "${BLUE}=== Ayuda General ===${NC}"
            pnpm start --help
            echo ""
            echo -e "${BLUE}=== Ayuda del Agente ===${NC}"
            pnpm start agent --help
            wait_for_user
            ;;
        2)
            echo -e "${BLUE}=== Estado de Salud ===${NC}"
            pnpm start health 2>&1 || echo "Comando no disponible o error"
            echo ""
            echo -e "${BLUE}=== Estado de Canales ===${NC}"
            pnpm start status 2>&1 || echo "Comando no disponible o error"
            wait_for_user
            ;;
        3)
            echo -e "${BLUE}=== Configuración Actual ===${NC}"
            echo ""
            echo "Configuración completa:"
            pnpm start config get 2>&1 | head -50 || echo "No disponible"
            echo ""
            echo "Configuración del agente:"
            cat ~/.openclaw/agents/main/agent/config.json | python3 -m json.tool 2>/dev/null || echo "No disponible"
            wait_for_user
            ;;
        4)
            echo -e "${BLUE}=== Conversación Básica ===${NC}"
            echo ""
            read -p "Escribe tu mensaje: " mensaje
            if [ -n "$mensaje" ]; then
                echo ""
                echo -e "${CYAN}Enviando mensaje...${NC}"
                pnpm start agent --session-id "test-$(date +%s)" --message "$mensaje" --local
            else
                echo -e "${RED}Mensaje vacío, cancelado${NC}"
            fi
            wait_for_user
            ;;
        5)
            echo -e "${BLUE}=== Prueba de Memoria/Contexto ===${NC}"
            SESSION_ID="memory-test-$(date +%s)"
            echo "Usando sesión: $SESSION_ID"
            echo ""
            echo -e "${YELLOW}1. Primera interacción (guardando información):${NC}"
            pnpm start agent --session-id "$SESSION_ID" --message "Mi nombre es TestUser, me gusta la programación y mi color favorito es el azul" --local
            echo ""
            echo -e "${YELLOW}2. Segunda interacción (debería recordar):${NC}"
            pnpm start agent --session-id "$SESSION_ID" --message "¿Cuál es mi nombre, qué me gusta y cuál es mi color favorito?" --local
            wait_for_user
            ;;
        6)
            echo -e "${BLUE}=== Pregunta Rápida Predefinida ===${NC}"
            echo ""
            echo "Selecciona una pregunta:"
            echo "  1) ¿Qué puedes hacer?"
            echo "  2) ¿Cómo te llamas?"
            echo "  3) Explícame qué es Docker"
            echo "  4) ¿Cuál es la diferencia entre Python y JavaScript?"
            read -p "Opción (1-4): " pregunta_opcion
            case $pregunta_opcion in
                1) mensaje="¿Qué puedes hacer? Lista tus capacidades principales" ;;
                2) mensaje="¿Cómo te llamas?" ;;
                3) mensaje="Explícame qué es Docker en términos simples" ;;
                4) mensaje="¿Cuál es la diferencia principal entre Python y JavaScript?" ;;
                *) mensaje="Hola" ;;
            esac
            echo ""
            echo -e "${CYAN}Pregunta: $mensaje${NC}"
            pnpm start agent --session-id "quick-$(date +%s)" --message "$mensaje" --local
            wait_for_user
            ;;
        7)
            echo -e "${BLUE}=== Pregunta Técnica ===${NC}"
            echo ""
            echo "Pregunta: ¿Qué es un API REST y cómo funciona?"
            pnpm start agent --session-id "tech-$(date +%s)" --message "Explícame qué es un API REST y cómo funciona, con ejemplos prácticos" --local
            wait_for_user
            ;;
        8)
            echo -e "${BLUE}=== Pregunta Creativa ===${NC}"
            echo ""
            echo "Pregunta: Escribe un poema sobre la inteligencia artificial"
            pnpm start agent --session-id "creative-$(date +%s)" --message "Escribe un poema corto (4-6 líneas) sobre la inteligencia artificial y el futuro de la tecnología" --local
            wait_for_user
            ;;
        9)
            echo -e "${BLUE}=== Pregunta de Programación ===${NC}"
            echo ""
            echo "Pregunta: Escribe una función en Python que calcule el factorial"
            pnpm start agent --session-id "code-$(date +%s)" --message "Escribe una función en Python que calcule el factorial de un número. Incluye comentarios explicativos" --local
            wait_for_user
            ;;
        10)
            echo -e "${BLUE}=== Pregunta de Análisis ===${NC}"
            echo ""
            echo "Pregunta: Compara microservicios vs arquitectura monolítica"
            pnpm start agent --session-id "analysis-$(date +%s)" --message "Compara las ventajas y desventajas de usar microservicios vs arquitectura monolítica, considerando factores como escalabilidad, mantenimiento y complejidad" --local
            wait_for_user
            ;;
        11)
            echo -e "${BLUE}=== Verificar Conexión con Mistral ===${NC}"
            echo ""
            echo "Verificando puerto 11436..."
            if timeout 3 bash -c "echo > /dev/tcp/192.168.100.42/11436" 2>/dev/null; then
                echo -e "${GREEN}✅ Puerto 11436 está abierto${NC}"
            else
                echo -e "${RED}❌ Puerto 11436 está cerrado${NC}"
            fi
            echo ""
            echo "Probando conexión HTTP..."
            RESPONSE=$(curl -s -m 5 "http://192.168.100.42:11436/v1/models" 2>&1)
            if echo "$RESPONSE" | grep -qi "mistral\|model"; then
                echo -e "${GREEN}✅ Mistral responde correctamente${NC}"
                echo "$RESPONSE" | python3 -m json.tool 2>/dev/null | head -10 || echo "$RESPONSE" | head -5
            else
                echo -e "${RED}❌ Mistral no responde${NC}"
                echo "Error: $RESPONSE"
            fi
            wait_for_user
            ;;
        12)
            echo -e "${BLUE}=== Verificar Configuración y Estado ===${NC}"
            echo ""
            echo "Configuración del agente:"
            cat ~/.openclaw/agents/main/agent/config.json | python3 -m json.tool 2>/dev/null || echo "Error al leer config.json"
            echo ""
            echo "Verificando archivos de configuración:"
            ls -la ~/.openclaw/agents/main/agent/*.json 2>/dev/null | head -5
            wait_for_user
            ;;
        13)
            echo -e "${BLUE}=== Cambiar Modelo ===${NC}"
            echo ""
            echo "Modelos disponibles:"
            echo "  1) mistral (puerto 11436) - Actual"
            echo "  2) llama2 (puerto 11435)"
            read -p "Selecciona modelo (1-2): " modelo_opcion
            case $modelo_opcion in
                1)
                    echo "Ya estás usando Mistral"
                    ;;
                2)
                    echo "Cambiando a llama2..."
                    cd /media/sf_shareFolder 2>/dev/null || cd ~
                    if [ -f "corregir-config-ollama-llama2.sh" ]; then
                        ./corregir-config-ollama-llama2.sh
                    else
                        echo "Script de cambio no encontrado"
                    fi
                    cd ~/moltbot
                    ;;
                *)
                    echo "Opción inválida"
                    ;;
            esac
            wait_for_user
            ;;
        0)
            echo ""
            echo -e "${GREEN}¡Hasta luego!${NC}"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Opción inválida. Presiona Enter para continuar...${NC}"
            read
            ;;
    esac
done

