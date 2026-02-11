# 🔧 Solución: Error "Invalid Model" en Cursor

## Problema
Cursor muestra el error "invalid model" cuando intentas usar Ollama con la URL `http://localhost:11438/v1`.

## ✅ Verificación

He verificado que:
- ✅ Ollama responde correctamente en `/v1/models`
- ✅ Los modelos están disponibles: `deepseek-coder:33b` y `codellama:34b`
- ✅ El endpoint `/v1/models` devuelve los modelos en formato correcto

## 🎯 Soluciones a Probar

### Solución 1: Configuración desde API Keys (Recomendada)

En Cursor Settings → API Keys:

1. **Override OpenAI Base URL:**
   - URL: `http://localhost:11438/v1` ✅ (ya lo tienes)

2. **OpenAI API Key:**
   - Key: `ollama` (o cualquier texto)

3. **IMPORTANTE: No uses el campo "Model" en API Keys**
   - Deja el campo de modelo vacío o no lo configures ahí
   - El modelo se selecciona desde el chat o desde otra sección

### Solución 2: Configurar Modelo desde el Chat

1. Abre el chat (`Ctrl + L`)
2. Busca el selector de modelos (puede estar en la parte superior o en un menú)
3. Si hay un campo de texto para escribir el modelo, escribe: `deepseek-coder:33b`
4. O busca en la lista si aparece

### Solución 3: Usar el Modelo sin Seleccionarlo

Aunque diga "invalid model", intenta usar el chat directamente:

1. Abre el chat
2. Escribe una pregunta
3. Verifica en los logs de Docker si hay actividad:
   ```powershell
   docker logs ollama-code --tail 20 -f
   ```

Si ves actividad, el modelo está funcionando aunque diga "invalid model".

### Solución 4: Probar con Codellama

Prueba con el otro modelo disponible:

**En settings.json:**
```json
{
    "cursor.model": "codellama:34b",
    "cursor.modelProvider": "openai",
    "cursor.modelBaseUrl": "http://localhost:11438/v1",
    "cursor.apiKey": "ollama"
}
```

### Solución 5: Sin /v1 (API Nativa de Ollama)

Si `/v1` no funciona, prueba sin él (aunque esto puede no funcionar con Cursor):

```json
{
    "cursor.model": "deepseek-coder:33b",
    "cursor.modelProvider": "custom",
    "cursor.modelBaseUrl": "http://localhost:11438",
    "cursor.apiKey": "ollama"
}
```

### Solución 6: Usar el Proxy de Ollama

Si tienes `ollama-proxy` corriendo en el puerto 11440:

```json
{
    "cursor.model": "deepseek-coder:33b",
    "cursor.modelProvider": "openai",
    "cursor.modelBaseUrl": "http://localhost:11440/v1",
    "cursor.apiKey": "ollama"
}
```

Y en la interfaz de Cursor:
- Override OpenAI Base URL: `http://localhost:11440/v1`

## 🔍 Verificar qué Modelos Ve Cursor

Para ver qué modelos está detectando Cursor:

1. Abre Cursor Settings
2. Ve a la sección "Models"
3. Busca si hay alguna lista de modelos disponibles
4. O busca en el chat si hay un dropdown de modelos

## 📝 Configuración Actual Recomendada

He actualizado tu `settings.json` con esta configuración:

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

## 🧪 Probar si Funciona

Aunque diga "invalid model", prueba:

1. **Reinicia Cursor completamente**
2. **Abre el chat** (`Ctrl + L`)
3. **Escribe una pregunta simple:** "Hello, how are you?"
4. **En otra terminal, monitorea los logs:**
   ```powershell
   docker logs ollama-code --tail 20 -f
   ```

Si ves actividad en los logs cuando escribes en el chat, **el modelo está funcionando** aunque Cursor muestre el error.

## ⚠️ Limitación Conocida

Cursor puede mostrar "invalid model" pero aún así usar el modelo si:
- La URL base está correcta
- El modelo existe en Ollama
- La configuración está en `settings.json`

El error puede ser solo una validación de la interfaz que no afecta el funcionamiento real.

## 🎯 Próximos Pasos

1. ✅ Reinicia Cursor
2. ✅ Prueba usar el chat directamente (ignora el error si aparece)
3. ✅ Verifica los logs de Docker para confirmar que funciona
4. ✅ Si funciona, el error es solo cosmético

---

**¿El modelo funciona aunque diga "invalid model"?** Verifica los logs de Docker para confirmarlo.


