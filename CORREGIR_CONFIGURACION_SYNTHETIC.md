# 🔧 Corregir Configuración de Synthetic para Ollama

## ❌ Problemas Detectados

1. **Error 401 "Invalid API Key"** - Synthetic está rechazando la API key
2. **Modelo incorrecto**: `synthetic/hf:MiniMaxAI/MiniMax-M2.1` - no es Ollama

## ✅ Solución: Editar Configuración Manualmente

### Paso 1: Ver Configuración Actual

```bash
cat ~/.openclaw/agents/main/agent/auth-profiles.json
cat ~/.openclaw/agents/main/agent/config.json 2>/dev/null || echo "No existe config.json"
```

### Paso 2: Editar auth-profiles.json

```bash
nano ~/.openclaw/agents/main/agent/auth-profiles.json
```

**Reemplaza el contenido con:**

```json
{
  "synthetic": {
    "baseURL": "http://192.168.100.42:11435",
    "apiKey": "ollama",
    "model": "llama2"
  },
  "ollama": {
    "baseURL": "http://192.168.100.42:11435",
    "model": "llama2"
  },
  "defaultProvider": "ollama",
  "defaultModel": "llama2"
}
```

Guarda: `Ctrl+O`, `Enter`, `Ctrl+X`

### Paso 3: Crear/Editar config.json

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

### Paso 4: Verificar Variables de Entorno

```bash
export OPENCLAW_MODEL_PROVIDER=ollama
export OPENCLAW_MODEL_NAME=llama2
export OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435

# Verificar
echo $OPENCLAW_MODEL_PROVIDER
echo $OPENCLAW_MODEL_NAME
echo $OPENCLAW_MODEL_BASE_URL
```

### Paso 5: Probar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

## 🔍 Verificar Conexión a Ollama

**Antes de probar, verifica que Ollama responde:**

```bash
curl http://192.168.100.42:11435/api/tags
```

Deberías ver el modelo `llama2:latest` en la respuesta.

---

**Empieza con el Paso 1 para ver la configuración actual, luego edita los archivos en los Pasos 2 y 3.**












