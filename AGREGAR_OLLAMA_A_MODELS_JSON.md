# ✅ Agregar Ollama a models.json

## ❌ Problema Detectado

1. `config.json` está bien configurado con Ollama ✅
2. `models.json` NO tiene proveedor "ollama" - solo tiene "minimax" y "synthetic" ❌
3. Synthetic está usando `baseUrl: "https://api.synthetic.new/anthropic"` en lugar de Ollama ❌

## ✅ Solución: Agregar Proveedor Ollama a models.json

**Editar models.json:**

```bash
nano ~/.openclaw/agents/main/agent/models.json
```

**Agregar el proveedor "ollama" dentro de "providers":**

El archivo debería quedar así (agrega la sección "ollama" después de "synthetic"):

```json
{
  "providers": {
    "minimax": {
      "baseUrl": "https://api.minimax.io/anthropic",
      "api": "anthropic-messages",
      "models": [
        ...
      ],
      "apiKey": "d"
    },
    "synthetic": {
      "baseUrl": "https://api.synthetic.new/anthropic",
      "api": "anthropic-messages",
      "models": [
        ...
      ],
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

**O más simple, solo agrega al final antes del cierre:**

```json
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
```

Guarda: `Ctrl+O`, `Enter`, `Ctrl+X`

## 🔧 Alternativa: Modificar Synthetic en models.json

**O modificar el baseUrl de Synthetic para que apunte a Ollama:**

```bash
nano ~/.openclaw/agents/main/agent/models.json
```

**Cambiar el baseUrl de synthetic:**

```json
"synthetic": {
  "baseUrl": "http://192.168.100.42:11435",
  ...
}
```

## 🧪 Probar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

---

**Recomiendo agregar el proveedor "ollama" a models.json (Solución 1) para que OpenClaw reconozca Ollama como proveedor válido.**












