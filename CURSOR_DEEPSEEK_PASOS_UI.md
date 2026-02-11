# Cursor + DeepSeek Docker – Pasos en la interfaz

## Resumen de comprobaciones (OK)

| Comprobación        | Estado |
|---------------------|--------|
| Contenedor ollama-code | Up 7 days |
| Puerto 11438        | Expuesto |
| Modelos             | deepseek-coder:33b, codellama:34b |
| API /v1/models       | 200 OK |
| API /v1/chat/completions | Conecta (puede haber límite de RAM) |

---

## Dónde configurar en Cursor (el modelo no aparece en menús)

Cursor no suele mostrar modelos locales de Ollama en el desplegable. Hay que configurarlos en la interfaz, aunque no aparezcan en la lista.

### Paso 1: Settings → Features

1. `Ctrl + ,` (abrir Settings).
2. Buscar: `Override` o `OpenAI` o `Models`.
3. Ir a **Settings → Features** o **API Keys**.

### Paso 2: Override OpenAI Base URL

1. En **Settings → Features** buscar: **Override OpenAI Base URL** o **OpenAI Base URL**.
2. Poner: `http://localhost:11438/v1`
3. En **OpenAI API Key** poner: `ollama` (cualquier texto vale para Ollama).

### Paso 3: Modelo por defecto

1. Si hay campo **Model** o **Default model**, usar: `deepseek-coder:33b`
2. Si no hay campo, configurarlo en `settings.json` (siguiente paso).

### Paso 4: Settings JSON (alternativa/complemento)

1. `Ctrl + Shift + P`.
2. Buscar: **Preferences: Open User Settings (JSON)**.
3. Asegurar que existe:

```json
{
  "cursor.model": "deepseek-coder:33b",
  "cursor.modelProvider": "openai",
  "cursor.modelBaseUrl": "http://localhost:11438/v1",
  "cursor.apiKey": "ollama",
  "cursor.chat.model": "deepseek-coder:33b",
  "cursor.chat.modelProvider": "openai",
  "cursor.chat.modelBaseUrl": "http://localhost:11438/v1",
  "cursor.chat.apiKey": "ollama"
}
```

### Paso 5: Reinicio y prueba

1. Cerrar Cursor por completo.
2. Abrirlo de nuevo.
3. Chat: `Ctrl + L`.
4. Escribir algo; aunque no aparezca el modelo en el menú, se usará DeepSeek si la configuración es correcta.
5. Comprobar actividad: `docker logs ollama-code --tail 20 -f`

---

## Si el modelo sigue sin aparecer en el menú

Es una limitación conocida de Cursor con modelos locales. Lo importante:

1. Configurar **Override OpenAI Base URL** en la UI.
2. Mantener la configuración en `settings.json`.
3. Usar el chat o Composer directamente; el modelo se usará aunque no salga en el selector.

---

## Nota sobre memoria

Si ves algo como: `"model requires more system memory (10.4 GiB) than is available"`:

- Libera RAM cerrando otras apps.
- O prueba otro modelo más ligero en otro contenedor: `ollama-qwen` (qwen2.5:7b) en puerto 11437.
