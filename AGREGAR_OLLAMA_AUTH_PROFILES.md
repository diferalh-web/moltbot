# ✅ Agregar Configuración de Ollama a auth-profiles.json

## 📋 Estado Actual

El archivo tiene perfiles de Synthetic y MiniMax, pero falta la configuración completa de Ollama.

## ✅ Solución: Agregar Perfil de Ollama

**Edita el archivo:**

```bash
nano ~/.openclaw/agents/main/agent/auth-profiles.json
```

**Reemplaza TODO el contenido con:**

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

**Cambios importantes:**
1. Agregado `baseURL` y `model` al perfil `synthetic:default`
2. Agregado nuevo perfil `ollama:default` con configuración completa
3. Agregado `ollama` a `lastGood`

Guarda: `Ctrl+O`, `Enter`, `Ctrl+X`

## 🔧 Alternativa: Solo Modificar Synthetic

**Si prefieres usar solo Synthetic, modifica solo ese perfil:**

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
    }
  },
  "lastGood": {
    "synthetic": "synthetic:default"
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

## 🧪 Probar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

## 🔍 Verificar Conexión

```bash
curl http://192.168.100.42:11435/api/tags
```

---

**Edita el archivo y agrega la baseURL y model al perfil synthetic:default, o agrega el perfil ollama:default completo.**












