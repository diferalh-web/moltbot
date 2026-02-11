# 🚀 Configurar Moltbot - Guía Completa

## 📋 Paso 1: Iniciar el Asistente de Configuración

**En tu terminal SSH**, ejecuta:

```bash
cd ~/moltbot
pnpm start onboard
```

Este comando iniciará un asistente interactivo que te guiará paso a paso.

## 🔧 Paso 2: Proceso de Configuración

El asistente `onboard` te pedirá:

### 2.1 Configuración del Gateway
- **Puerto del Gateway**: Generalmente `18789` (por defecto)
- **Configuración de red**: Acepta los defaults o personaliza según necesites

### 2.2 Configuración del Workspace
- **Directorio del workspace**: Generalmente `~/.openclaw/workspace`
- **Configuración del agente**: Acepta los defaults

### 2.3 Configuración de Skills
- Selecciona qué skills quieres habilitar
- Puedes agregar más después

### 2.4 Configuración de Credenciales

**IMPORTANTE:** Necesitarás API keys para los modelos de IA:

#### OpenAI
- Ve a: https://platform.openai.com/api-keys
- Crea una API key
- Cópiala y pégala cuando el asistente la solicite

#### Anthropic (Claude)
- Ve a: https://console.anthropic.com/
- Crea una API key
- Cópiala y pégala cuando el asistente la solicite

#### Otros proveedores (opcional)
- AWS Bedrock
- Otros modelos compatibles

## 📝 Paso 3: Configuración de Canales (Opcional)

Después de la configuración inicial, puedes configurar canales:

### WhatsApp
```bash
pnpm start channels login whatsapp
```

### Telegram
```bash
pnpm start channels login telegram
```

### Otros canales
```bash
pnpm start channels --help
```

## ✅ Paso 4: Verificar Configuración

```bash
# Ver estado de salud
pnpm start health

# Ver estado de canales
pnpm start status

# Ver configuración
pnpm start config get
```

## 🚀 Paso 5: Iniciar el Gateway

```bash
# Iniciar gateway en primer plano
pnpm start gateway

# O en modo desarrollo (aislado)
pnpm start --dev gateway
```

## 💻 Paso 6: Usar Moltbot

### Enviar un mensaje de prueba

```bash
# Ejecutar un turno del agente
pnpm start agent --message "Hola, ¿cómo estás?"

# O usar la interfaz de terminal
pnpm start tui
```

## 🔍 Comandos Útiles

```bash
# Ver ayuda general
pnpm start --help

# Ver ayuda de un comando específico
pnpm start <comando> --help

# Ver logs del gateway
pnpm start logs

# Ver sesiones almacenadas
pnpm start sessions

# Ver estado del sistema
pnpm start system
```

## 🆘 Solución de Problemas

### Error: "Gateway not running"
```bash
# Iniciar el gateway
pnpm start gateway
```

### Error: "No API keys configured"
```bash
# Configurar credenciales
pnpm start configure
```

### Error: "Port already in use"
```bash
# Usar otro puerto
pnpm start gateway --port 19001
```

### Verificar configuración
```bash
# Ver configuración actual
cat ~/.openclaw/openclaw.json

# O usar el comando
pnpm start config get
```

## 📚 Documentación Adicional

- Documentación oficial: `docs.openclaw.ai/cli`
- Ver ayuda en cualquier momento: `pnpm start <comando> --help`

---

**Empieza ejecutando `pnpm start onboard` y sigue las instrucciones del asistente.**
