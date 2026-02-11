# 🔧 Configurar Ollama Manualmente Después de Crear Agente

## ❌ Problema

Ollama no está en la lista de proveedores predefinidos del asistente.

## ✅ Solución: Skip y Configurar Manualmente

### Paso 1: Seleccionar "Skip for now"

**En el prompt actual:**
- Usa las flechas `↑` `↓` para moverte a "Skip for now"
- Presiona `Enter` para seleccionar

Esto creará el agente sin modelo configurado.

### Paso 2: Verificar que el Agente se Creó

```bash
pnpm start agents list
```

Deberías ver "main" en la lista.

### Paso 3: Configurar Ollama Manualmente

**Editar el archivo auth-profiles.json del agente:**

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

### Paso 4: Crear Archivo de Configuración del Modelo

**Crear un archivo config.json:**

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

### Paso 5: Asegurar Variables de Entorno

```bash
export OPENCLAW_MODEL_PROVIDER=ollama
export OPENCLAW_MODEL_NAME=llama2
export OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435
```

### Paso 6: Probar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

## 🔍 Verificar Archivos

**Después de crear el agente, verifica:**

```bash
ls -la ~/.openclaw/agents/main/agent/
cat ~/.openclaw/agents/main/agent/*.json
```

---

**Selecciona "Skip for now" primero para crear el agente, luego configura Ollama manualmente.**












