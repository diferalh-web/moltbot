# 🔧 Corregir models.json

## ❌ Problema Detectado

El JSON tiene un problema de formato:
- Hay una coma después de `"synthetic"` pero la indentación de `"ollama"` no es consistente
- Falta cerrar correctamente la estructura

## ✅ JSON Corregido

**El archivo debería quedar así (nota la indentación y la coma):**

```json
{
  "providers": {
    "minimax": {
      ...
    },
    "synthetic": {
      ...
      "apiKey": "ollama"
    },
    "ollama": {
      "baseUrl": "http://192.168.100.42:11435",
      "api": "openai",
      "models": [
        {
          "id": "llama2",
          "name": "Llama 2",
          "reasoning": false,
          "input": ["text"],
          "contextWindow": 4096,
          "maxTokens": 4096
        }
      ]
    }
  }
}
```

## 🔍 Validar JSON

**Para verificar que el JSON está bien formado:**

```bash
cat ~/.openclaw/agents/main/agent/models.json | python3 -m json.tool
```

Si el JSON está bien, lo mostrará formateado. Si hay error, mostrará el error.

## 🔧 Si Hay Error de Sintaxis

**Edita el archivo:**

```bash
nano ~/.openclaw/agents/main/agent/models.json
```

**Asegúrate de que:**
1. Después de `"synthetic": { ... },` hay una coma
2. `"ollama": { ... }` NO tiene coma al final (es el último)
3. La indentación es consistente
4. Todos los `{` tienen su `}` correspondiente

## ✅ Después de Corregir

**Actualizar auth-profiles.json para usar Ollama:**

```bash
nano ~/.openclaw/agents/main/agent/auth-profiles.json
```

**Cambiar lastGood para usar ollama:**

```json
{
  "version": 1,
  "profiles": {
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
    "ollama": "ollama:default"
  }
}
```

## 🧪 Probar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

---

**Primero valida el JSON con `python3 -m json.tool`, luego actualiza auth-profiles.json para usar Ollama.**












