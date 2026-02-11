# 🔧 Solución Error 401 - Invalid API Key

## ❌ Problema

Synthetic está validando la API key contra su propio servicio antes de hacer la llamada a Ollama, por eso rechaza "ollama" como API key.

## ✅ Solución 1: Verificar Configuración del Modelo

**El agente está configurado con modelo Synthetic, pero necesitamos que use Ollama directamente.**

**Ver qué modelo está usando el agente:**

```bash
pnpm start agents list
```

Debería mostrar: `Model: synthetic/hf:MiniMaxAI/MiniMax-M2.1`

## ✅ Solución 2: Crear Perfil de Ollama Directo

**Editar auth-profiles.json para agregar perfil de Ollama y hacerlo el predeterminado:**

```bash
nano ~/.openclaw/agents/main/agent/auth-profiles.json
```

**Agregar perfil ollama:default y cambiar lastGood:**

```json
{
  "version": 1,
  "profiles": {
    "minimax:default": {
      "type": "api_key",
      "provider": "minimax",
      "key": "d"
    },
    "synthetic:default": {
      "type": "api_key",
      "provider": "synthetic",
      "key": "ollama",
      "baseURL": "http://192.168.100.42:11435",
      "model": "llama2"
    },
    "ollama:default": {
      "type": "api_key",
      "provider": "ollama",
      "key": "ollama",
      "baseURL": "http://192.168.100.42:11435",
      "model": "llama2"
    }
  },
  "lastGood": {
    "synthetic": "synthetic:default",
    "ollama": "ollama:default"
  },
  "usageStats": {
    "synthetic:default": {
      "errorCount": 0,
      "lastFailureAt": 1770003973856,
      "lastUsed": 1770003973864
    }
  }
}
```

## ✅ Solución 3: Crear Archivo config.json

**Crear archivo de configuración del agente que especifique Ollama:**

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

## ✅ Solución 4: Usar Variables de Entorno

**Asegurar que las variables estén configuradas:**

```bash
export OPENCLAW_MODEL_PROVIDER=ollama
export OPENCLAW_MODEL_NAME=llama2
export OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435

# Verificar
echo $OPENCLAW_MODEL_PROVIDER
echo $OPENCLAW_MODEL_NAME
echo $OPENCLAW_MODEL_BASE_URL
```

## ✅ Solución 5: Verificar que Ollama Responde

**Antes de probar, verifica que Ollama está accesible:**

```bash
curl http://192.168.100.42:11435/api/tags
curl http://192.168.100.42:11435/api/generate -d '{"model":"llama2","prompt":"test","stream":false}'
```

## 🧪 Probar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

## 🔍 Si Aún No Funciona

**El problema puede ser que Synthetic requiere una API key válida de su servicio. En ese caso, necesitamos:**

1. **Eliminar el agente y recrearlo sin Synthetic**
2. **O encontrar una forma de hacer que OpenClaw use Ollama directamente**

---

**Empieza con la Solución 3 (crear config.json) y la Solución 4 (variables de entorno), luego prueba de nuevo.**












