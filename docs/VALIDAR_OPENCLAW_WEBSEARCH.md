# Validar que OpenClaw esté conectado y pueda usar web_search

Esta guía describe cómo comprobar que OpenClaw funciona correctamente y que la herramienta `web_search` está disponible y operativa.

## 1. Conectividad general (doctor + health)

```bash
# En la VM
openclaw doctor
openclaw health
```

- **doctor**: Revisa config, migraciones, estado del gateway, canales, skills, etc.
- **health**: Verifica que el gateway esté vivo y respondiendo.

Si hay problemas, `openclaw doctor --repair` puede aplicar correcciones recomendadas.

## 2. Modelos configurados

```bash
openclaw models list
```

Debes ver el modelo que usas (por ejemplo `ollama/qwen2.5:7b`) como primario. Si no aparece o hay errores, el gateway no podrá responder bien.

## 3. Configuración de web_search

Verifica en `~/.openclaw/openclaw.json`:

```bash
# En la VM
cat ~/.openclaw/openclaw.json | grep -A5 '"web"'
```

O con jq:

```bash
jq '.tools.web' ~/.openclaw/openclaw.json
```

Debe incluir:

```json
{
  "web": {
    "search": {
      "enabled": true,
      "provider": "brave",
      "apiKey": "BSA..."
    }
  }
}
```

**Requisitos mínimos:**

- `tools.web.search.enabled` no debe ser `false`
- API key: `BRAVE_API_KEY` en el entorno del proceso del gateway **o** `tools.web.search.apiKey` en config
- Si usas `tools.allow` o profiles, debe incluir `web_search` (o `group:web`)

Ejemplo de tools permitidas:

```json
"tools": {
  "allow": ["web_search", "web_fetch", "browser", ...]
}
```

## 4. Prueba directa de la API de Brave

Si la API key está en el entorno o en la config, puedes validar Brave sin pasar por el modelo:

```bash
# Con API key en env
export BRAVE_API_KEY="tu_api_key"
curl -s -H "X-Subscription-Token: $BRAVE_API_KEY" \
  "https://api.search.brave.com/res/v1/web/search?q=test" | head -200
```

Debe devolver JSON con resultados. Si devuelve error de auth o 401, la key no es válida o ha expirado.

## 5. Prueba end-to-end con TUI o Dashboard

La forma más fiable de validar que el modelo **invoca** `web_search` es una conversación:

### Opción A: TUI (terminal)

```bash
openclaw tui
```

En el TUI, escribe una pregunta que exija información actual:

- *"Usa web_search para buscar el precio actual de las acciones de NVIDIA y dime el resultado."*
- *"¿Cuáles son las últimas noticias de hoy sobre IA?"*

### Opción B: Dashboard / WebChat

Abre el dashboard (por ejemplo `http://127.0.0.1:18789/?token=...`) y envía la misma pregunta.

### Cómo saber si usó web_search

- La respuesta incluirá datos que no están en el conocimiento del modelo (fechas, precios recientes, etc.).
- En los **logs del gateway** aparecerá la invocación de la tool:

```bash
openclaw logs --follow
```

O si el gateway corre en foreground, verás salida de tipo `tool_call`, `web_search`, etc.

Si el modelo responde sin buscar (NO_REPLY o respuesta genérica), revisa:

- AGENTS.md / TOOLS.md en el workspace: que indiquen explícitamente "debes invocar web_search cuando..."
- `tools.allow` con `web_search`
- Modelo con capacidad de tool use (Qwen 2.5 7B es adecuado)
- **Provider correcto:** Usa `ollama` (no `custom-*`). Los providers `custom-*` no pasan tools a Ollama. Ver [DIAGNOSTICO_OPENCLAW_TOOLS.md](./DIAGNOSTICO_OPENCLAW_TOOLS.md).

## 6. Script de validación

Puedes ejecutar el script incluido en el proyecto:

```bash
# Desde Windows (via SSH)
ssh -p 2222 clawbot@127.0.0.1 "bash -s" < scripts/validar-openclaw-websearch.sh

# O copiando el script y ejecutándolo en la VM
scp -P 2222 scripts/validar-openclaw-websearch.sh clawbot@127.0.0.1:~/
ssh -p 2222 clawbot@127.0.0.1 "bash ~/validar-openclaw-websearch.sh"
```

El script ejecuta las comprobaciones 1–4 y da instrucciones para la prueba 5.

## Resumen rápido

| Paso | Comando | Qué valida |
|------|---------|------------|
| 1 | `openclaw doctor` | Config, estado, gateway |
| 2 | `openclaw health` | Gateway vivo |
| 3 | `openclaw models list` | Modelo disponible |
| 4 | Revisar `tools.web.search` y `tools.allow` | web_search habilitada |
| 5 | `curl` a Brave API | Key válida |
| 6 | `openclaw tui` + pregunta explícita | Modelo invoca web_search |

## Referencias

- [OpenClaw Web Tools](https://docs.clawd.bot/tools/web)
- [OpenClaw Doctor](https://docs.clawd.bot/gateway/doctor)
- [Brave Search API](https://brave.com/search/api/)
- `docs/CONFIGURAR_OPENCLAW_QWEN.md` — configuración del modelo Qwen
