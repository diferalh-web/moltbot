# Diagnóstico: OpenClaw no invoca web_search

Guía para identificar la causa raíz cuando el modelo no llama a herramientas (web_search, etc.).

## Resolución conocida

**Causa raíz típica:** Los providers `custom-*` (ej. `custom-10-0-2-2-11437`) **no pasan las tools** a Ollama. Hay que usar el provider **`ollama`** con `baseUrl` personalizada y `"api": "openai-completions"`:

```json
{
  "models": {
    "providers": {
      "ollama": {
        "baseUrl": "http://10.0.2.2:11437/v1",
        "apiKey": "ollama-local",
        "api": "openai-completions",
        "models": [{ "id": "qwen2.5:7b", ... }]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": { "primary": "ollama/qwen2.5:7b" }
    }
  }
}
```

El script `configurar-openclaw-qwen.sh` ya crea esta configuración. Si migras desde un custom provider, elimina `custom-*` y usa `ollama`.

---

## Hipótesis a validar

1. **Ollama/modelo**: ¿Qwen 2.5 7B devuelve `tool_calls` cuando se le envían tools?
2. **Formato API**: ¿OpenClaw envía las tools en el formato que Ollama espera?
3. **Provider**: ¿Usas `ollama` (no `custom-*`)? Los `custom-*` no soportan tool calling.

---

## Paso 1: Probar Ollama directamente (sin OpenClaw)

**Objetivo:** Verificar si el modelo invoca tools cuando recibe una petición con tools.

### Desde la VM (Ollama en host 10.0.2.2:11437)

```bash
curl -s http://10.0.2.2:11437/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5:7b",
    "messages": [{"role": "user", "content": "What is the temperature in New York?"}],
    "stream": false,
    "tools": [{
      "type": "function",
      "function": {
        "name": "get_temperature",
        "description": "Get the current temperature for a city",
        "parameters": {"type": "object", "required": ["city"], "properties": {"city": {"type": "string"}}}
      }
    }]
  }' | python3 -m json.tool
```

**Interpretación:**
- Si la respuesta incluye `"tool_calls": [...]` → El modelo **sí** invoca tools. El problema está en OpenClaw.
- Si solo devuelve `"content": "..."` sin tool_calls → El modelo **no** invoca tools. Probar con otro modelo (qwen2.5-coder:7b, qwen3, etc.) o versiones de Ollama más recientes.

### Alternativa desde el host Windows (si Ollama corre ahí)

```powershell
curl -s http://127.0.0.1:11437/api/chat `
  -H "Content-Type: application/json" `
  -d '{\"model\":\"qwen2.5:7b\",\"messages\":[{\"role\":\"user\",\"content\":\"What is the temperature in New York?\"}],\"stream\":false,\"tools\":[{\"type\":\"function\",\"function\":{\"name\":\"get_temperature\",\"description\":\"Get temperature\",\"parameters\":{\"type\":\"object\",\"required\":[\"city\"],\"properties\":{\"city\":{\"type\":\"string\"}}}}]}]}'
```

---

## Paso 2: Comprobar capacidades del modelo

```bash
curl -s http://10.0.2.2:11437/api/show -d '{"name": "qwen2.5:7b"}' | python3 -m json.tool
```

Busca en la salida `capabilities` o `parameters`; si el modelo soporta tools, suele aparecer en la documentación o en las family/parameteres.

(Ollama no siempre expone "tools" explícitamente en /api/show; el test del Paso 1 es más fiable.)

---

## Paso 3: Capturar la petición que envía OpenClaw

**Opción A: Log verbose de OpenClaw**

```bash
OPENCLAW_LOG_LEVEL=trace openclaw gateway
```

Revisa si en la salida aparece el body enviado a Ollama (puede ser muy largo).

**Opción B: Logs de Ollama**

En el host, revisa los logs del contenedor ollama-qwen cuando envías un mensaje desde OpenClaw:

```powershell
docker logs ollama-qwen --tail 100 -f
```

Al hacer una pregunta en WhatsApp, verás las peticiones que llegan. No verás el body completo, pero sí si hay errores.

**Opción C: Proxy (avanzado)**

Con un proxy HTTP entre la VM y el host podrías capturar el body, pero requiere más configuración.

---

## Paso 4: Probar provider `ollama` en lugar de custom

OpenClaw trata al provider `ollama` de forma especial (descubrimiento de tools, streaming desactivado, etc.). Un provider `custom-*` puede no tener el mismo comportamiento.

### Cambiar a provider ollama con baseUrl custom

Edita `~/.openclaw/openclaw.json`:

1. Añade o modifica el provider `ollama` (no `custom-10-0-2-2-11437`):

```json
{
  "models": {
    "providers": {
      "ollama": {
        "baseUrl": "http://10.0.2.2:11437/v1",
        "apiKey": "ollama-local",
        "api": "openai-completions",
        "models": [
          {
            "id": "qwen2.5:7b",
            "name": "Qwen 2.5 7B",
            "contextWindow": 32768,
            "maxTokens": 8192,
            "input": ["text"],
            "cost": {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0}
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama/qwen2.5:7b"
      }
    }
  }
}
```

2. Cambia el modelo primario a `ollama/qwen2.5:7b` (o el id que definas).

3. Reinicia el gateway y prueba de nuevo.

**Nota:** Al definir `models.providers.ollama` explícitamente, se desactiva el auto-descubrimiento. Debes declarar los modelos manualmente.

---

## Paso 5: Verificar "api": "openai-completions"

El provider `ollama` debe usar `"api": "openai-completions"`. Si falta o está como `undefined`, puede aparecer `No API provider registered for api: undefined`. Asegúrate de tener:

```json
"ollama": {
  "baseUrl": "http://10.0.2.2:11437/v1",
  "apiKey": "ollama-local",
  "api": "openai-completions",
  ...
}
```

No uses `"api": "openai-responses"` para Ollama; `openai-completions` es el correcto.

---

## Resumen de decisiones

| Si el Paso 1 (curl directo)… | Entonces… |
|------------------------------|-----------|
| Devuelve tool_calls          | El fallo está en OpenClaw (provider, formato, config). Probar Pasos 4 y 5. |
| No devuelve tool_calls       | El modelo o la versión de Ollama no invocan tools bien. Probar otro modelo (qwen2.5-coder:7b, qwen3, llama3.1) o actualizar Ollama. |

---

## Modelos recomendados para tool calling (Ollama)

Según documentación de OpenClaw/Ollama:

- `qwen2.5-coder:32b` (mejor soporte tools)
- `qwen2.5-coder:7b` (si tienes RAM limitada)
- `qwen3`
- `llama3.3`
- `deepseek-r1:32b`
- `gpt-oss:20b`

Para probar con un modelo que suele funcionar bien con tools:

```bash
# En el host
docker exec ollama-qwen ollama pull qwen2.5-coder:7b
```

Luego configura OpenClaw para usar `qwen2.5-coder:7b` en lugar de `qwen2.5:7b`.
