# 🔧 Forzar Uso de Ollama

## ❌ Problema Persistente

Error 401 "Invalid API Key" - OpenClaw sigue usando Synthetic en lugar de Ollama.

## ✅ Solución: Actualizar auth-profiles.json Completamente

**El problema es que `lastGood` apunta a Synthetic. Necesitamos cambiarlo a Ollama.**

### Paso 1: Ver auth-profiles.json Actual

```bash
cat ~/.openclaw/agents/main/agent/auth-profiles.json
```

### Paso 2: Editar auth-profiles.json

```bash
nano ~/.openclaw/agents/main/agent/auth-profiles.json
```

**Reemplaza TODO el contenido con:**

```json
{
  "version": 1,
  "profiles": {
    "ollama:default": {
      "type": "api_key",
      "provider": "ollama",
      "key": "ollama",
      "baseURL": "http://192.168.100.42:11435",
      "model": "llama2"
    },
    "synthetic:default": {
      "type": "api_key",
      "provider": "synthetic",
      "key": "ollama",
      "baseURL": "http://192.168.100.42:11435",
      "model": "llama2"
    }
  },
  "lastGood": {
    "ollama": "ollama:default"
  },
  "usageStats": {}
}
```

**Cambios importantes:**
1. `ollama:default` está primero
2. `lastGood` apunta a `"ollama": "ollama:default"`
3. Eliminamos `usageStats` de synthetic para empezar limpio

Guarda: `Ctrl+O`, `Enter`, `Ctrl+X`

### Paso 3: Verificar Variables de Entorno

```bash
export OPENCLAW_MODEL_PROVIDER=ollama
export OPENCLAW_MODEL_NAME=llama2
export OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435

# Verificar
echo $OPENCLAW_MODEL_PROVIDER
echo $OPENCLAW_MODEL_NAME
echo $OPENCLAW_MODEL_BASE_URL
```

### Paso 4: Verificar config.json

```bash
cat ~/.openclaw/agents/main/agent/config.json
```

Debería mostrar:
```json
{
  "model": {
    "provider": "ollama",
    "name": "llama2",
    "baseURL": "http://192.168.100.42:11435"
  }
}
```

### Paso 5: Probar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

## 🔍 Si Aún No Funciona

**Ver qué modelo está usando el agente:**

```bash
pnpm start agents list
```

**Si muestra Synthetic, podemos intentar eliminar y recrear el agente sin Synthetic.**

---

**Empieza con el Paso 2 (editar auth-profiles.json) y asegúrate de que lastGood apunte a ollama.**












