# 🤖 Configurar Moltbot para usar Mistral o Qwen

## 📋 Resumen

Ahora tienes 3 contenedores Ollama disponibles:
- **ollama-moltbot** (llama2) - Puerto 11435
- **ollama-mistral** (mistral) - Puerto 11436  
- **ollama-qwen** (qwen2.5:7b) - Puerto 11437

## 🔍 Paso 1: Obtener IP del Host

**En PowerShell de Windows:**
```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*"} | Select-Object InterfaceAlias, IPAddress
```

**O usa la IP que ya conoces** (probablemente `192.168.100.42` o similar).

## 🧪 Paso 2: Probar Conectividad desde la VM

**En la terminal SSH de la VM:**

```bash
# Reemplaza HOST_IP con tu IP del host
HOST_IP="192.168.100.42"  # Cambia por tu IP

# Probar Mistral
echo "=== Probando Mistral ==="
curl http://$HOST_IP:11436/api/tags

# Probar Qwen
echo "=== Probando Qwen ==="
curl http://$HOST_IP:11437/api/tags

# Probar endpoints /v1/models (OpenAI-compatible)
echo "=== Probando Mistral /v1/models ==="
curl http://$HOST_IP:11436/v1/models

echo "=== Probando Qwen /v1/models ==="
curl http://$HOST_IP:11437/v1/models
```

Si los comandos `curl` funcionan, puedes continuar.

## 🔧 Paso 3: Configurar Moltbot para Mistral

### Opción A: Editar `models.json` del agente

**En la VM:**

```bash
nano ~/.openclaw/agents/main/agent/models.json
```

**Busca la sección `"ollama"` y actualiza:**

```json
"ollama": {
  "baseUrl": "http://192.168.100.42:11436/v1",
  "api": "openai-completions",
  "models": [
    {
      "id": "mistral",
      "name": "mistral",
      "reasoning": false,
      "input": ["text"],
      "cost": {
        "input": 0,
        "output": 0,
        "cacheRead": 0,
        "cacheWrite": 0
      },
      "contextWindow": 32000,
      "maxTokens": 8192
    }
  ],
  "apiKey": "ollama"
}
```

**Reemplaza `192.168.100.42` con tu IP del host.**

### Opción B: Editar `config.json` del agente

```bash
nano ~/.openclaw/agents/main/agent/config.json
```

**Actualiza a:**

```json
{
  "model": {
    "provider": "ollama",
    "name": "mistral",
    "baseURL": "http://192.168.100.42:11436/v1"
  }
}
```

### Opción C: Editar `openclaw.json` global

```bash
nano ~/.openclaw/openclaw.json
```

**Busca la sección del agente `"main"` y actualiza:**

```json
"agents": {
  "main": {
    "model": "ollama/mistral",
    ...
  }
}
```

**Y en la sección `models.providers.ollama`:**

```json
"models": {
  "providers": {
    "ollama": {
      "baseUrl": "http://192.168.100.42:11436/v1",
      "api": "openai-completions",
      ...
    }
  }
}
```

## 🔧 Paso 4: Configurar Moltbot para Qwen

**Mismo proceso, pero usa:**
- Puerto: `11437`
- Modelo: `qwen2.5:7b` o `qwen2.5`
- URL: `http://192.168.100.42:11437/v1`

**En `models.json`:**

```json
"ollama": {
  "baseUrl": "http://192.168.100.42:11437/v1",
  "api": "openai-completions",
  "models": [
    {
      "id": "qwen2.5:7b",
      "name": "qwen2.5:7b",
      ...
    }
  ],
  "apiKey": "ollama"
}
```

**En `config.json`:**

```json
{
  "model": {
    "provider": "ollama",
    "name": "qwen2.5:7b",
    "baseURL": "http://192.168.100.42:11437/v1"
  }
}
```

## ✅ Paso 5: Validar JSON

```bash
# Validar models.json
cat ~/.openclaw/agents/main/agent/models.json | python3 -m json.tool

# Validar config.json
cat ~/.openclaw/agents/main/agent/config.json | python3 -m json.tool

# Validar openclaw.json
cat ~/.openclaw/openclaw.json | python3 -m json.tool
```

## 🧪 Paso 6: Probar Moltbot

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola, como estas?" --local
```

**Si funciona correctamente, deberías ver:**
- Sin errores de "Failed to discover Ollama models"
- Sin errores de "does not support tools"
- Una respuesta del modelo

## 🔄 Cambiar entre Modelos

Para cambiar entre Mistral y Qwen, solo actualiza:
1. El puerto en `baseUrl` (11436 para Mistral, 11437 para Qwen)
2. El nombre del modelo (`mistral` o `qwen2.5:7b`)

## 📝 Notas

- **Mistral** soporta function calling (tools) ✅
- **Qwen** también soporta function calling (tools) ✅
- Ambos modelos son mejores que llama2 para OpenClaw
- Asegúrate de que el firewall permita los puertos 11436 y 11437

## 🐛 Troubleshooting

**Error: "Failed to discover Ollama models"**
- Verifica que la IP y puerto sean correctos
- Prueba `curl` desde la VM al host
- Verifica que el contenedor esté corriendo: `docker ps` en el host

**Error: "Invalid URL"**
- Asegúrate de incluir `/v1` al final de la URL
- Verifica que no haya espacios extra en el JSON

**Error: "does not support tools"**
- Mistral y Qwen deberían soportar tools
- Si persiste, verifica que el modelo esté correctamente descargado












