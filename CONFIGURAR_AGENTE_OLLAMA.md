# 🔧 Configurar Agente para Usar Ollama

## ❌ Problema

El archivo `auth-profiles.json` está correcto, pero OpenClaw sigue intentando usar "anthropic" por defecto.

## ✅ Solución: Configurar el Agente

**El archivo auth-profiles.json necesita incluir la configuración del modelo por defecto.**

### Opción 1: Actualizar auth-profiles.json

**Edita el archivo para incluir más configuración:**

```bash
nano ~/.openclaw/agents/main/agent/auth-profiles.json
```

**Reemplaza el contenido con:**

```json
{
  "ollama": {
    "baseURL": "http://192.168.100.42:11435",
    "model": "llama2"
  },
  "defaultProvider": "ollama",
  "defaultModel": "llama2"
}
```

Guarda: `Ctrl+O`, `Enter`, `Ctrl+X`

### Opción 2: Usar comando de configuración

```bash
cd ~/moltbot

# Ver ayuda de configuración de agentes
pnpm start agents add --help

# Intentar configurar el agente main
pnpm start agents add main
```

### Opción 3: Verificar configuración del agente

```bash
cd ~/moltbot

# Ver agentes configurados
pnpm start agents list

# Ver configuración del agente main
ls -la ~/.openclaw/agents/main/agent/
cat ~/.openclaw/agents/main/agent/*.json
```

### Opción 4: Crear archivo de configuración del agente

```bash
nano ~/.openclaw/agents/main/agent/config.json
```

**Escribe:**

```json
{
  "model": {
    "provider": "ollama",
    "name": "llama2",
    "baseURL": "http://192.168.100.42:11435"
  }
}
```

Guarda: `Ctrl+O`, `Enter`, `Ctrl+X`

## 🧪 Probar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

---

**Empieza con la Opción 1 (actualizar auth-profiles.json) y si no funciona, prueba las otras opciones.**












