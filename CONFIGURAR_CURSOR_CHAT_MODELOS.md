# 🔧 Configurar Modelos de Ollama en el Chat de Cursor

## Problema
Los modelos de Ollama no aparecen en la lista del chat de Cursor.

## ✅ Solución

### Paso 1: Verificar que Ollama está corriendo

```powershell
# Verificar contenedores
docker ps --filter "name=ollama-code"

# Ver modelos disponibles
docker exec ollama-code ollama list
```

### Paso 2: Configurar Cursor Settings

Abre Cursor Settings (JSON) con `Ctrl + Shift + P` → `Preferences: Open User Settings (JSON)`

**Opción A: Configuración para Chat (Recomendada)**

```json
{
    "cursor.chat.model": "ollama/deepseek-coder:33b",
    "cursor.chat.modelProvider": "ollama",
    "cursor.chat.modelBaseUrl": "http://localhost:11438",
    "cursor.chat.apiKey": "ollama"
}
```

**Opción B: Configuración General + Chat**

```json
{
    "cursor.general.model": "ollama/deepseek-coder:33b",
    "cursor.general.modelProvider": "ollama",
    "cursor.general.modelBaseUrl": "http://localhost:11438",
    "cursor.general.apiKey": "ollama",
    "cursor.chat.model": "ollama/deepseek-coder:33b",
    "cursor.chat.modelProvider": "ollama",
    "cursor.chat.modelBaseUrl": "http://localhost:11438",
    "cursor.chat.apiKey": "ollama"
}
```

**Opción C: Si Cursor requiere formato diferente**

```json
{
    "cursor.model": "ollama/deepseek-coder:33b",
    "cursor.modelProvider": "ollama",
    "cursor.modelBaseUrl": "http://localhost:11438/v1",
    "cursor.apiKey": "ollama"
}
```

### Paso 3: Configurar desde la Interfaz de Cursor

1. **Abre Cursor Settings:**
   - Presiona `Ctrl + ,` (o `Cmd + ,` en Mac)
   - O ve a `File → Preferences → Settings`

2. **Busca "Model" o "Chat Model":**
   - En la barra de búsqueda, escribe: `cursor.chat.model` o `model`
   - Busca opciones relacionadas con "Chat Model" o "AI Model"

3. **Configura el proveedor:**
   - Busca `Cursor: Model Provider` o `Chat: Model Provider`
   - Selecciona "Ollama" o "Local LLM"

4. **Configura la URL:**
   - Busca `Cursor: Model Base URL` o `Chat: Model Base URL`
   - Ingresa: `http://localhost:11438` (o `http://localhost:11438/v1`)

5. **Selecciona el modelo:**
   - Busca `Cursor: Chat Model` o `Model`
   - Ingresa: `deepseek-coder:33b` o `ollama/deepseek-coder:33b`

### Paso 4: Reiniciar Cursor

Después de cambiar la configuración:
1. Cierra completamente Cursor
2. Vuelve a abrirlo
3. Abre el chat (normalmente `Ctrl + L` o `Cmd + L`)
4. Verifica que el modelo aparece en el selector

## 🔍 Modelos Disponibles

Según tus contenedores Docker:

| Contenedor | Puerto | Modelos |
|------------|--------|---------|
| `ollama-code` | 11438 | `deepseek-coder:33b`, `codellama:34b` |
| `ollama-mistral` | 11436 | `mistral:latest` |
| `ollama-qwen` | 11437 | `qwen2.5:7b` |

## 🎯 Formatos de Modelo a Probar

Si el modelo no aparece, prueba estos formatos en la configuración:

1. `deepseek-coder:33b`
2. `ollama/deepseek-coder:33b`
3. `http://localhost:11438/deepseek-coder:33b`
4. `deepseek-coder:33b@http://localhost:11438`

## 🐛 Solución de Problemas

### El modelo no aparece en la lista

1. **Verifica que el contenedor está corriendo:**
   ```powershell
   docker ps --filter "name=ollama-code"
   ```

2. **Verifica que el modelo está instalado:**
   ```powershell
   docker exec ollama-code ollama list
   ```

3. **Prueba la API directamente:**
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:11438/api/tags" -UseBasicParsing
   ```

4. **Prueba diferentes formatos de URL:**
   - `http://localhost:11438`
   - `http://localhost:11438/v1`
   - `http://127.0.0.1:11438`

### Cursor no se conecta a Ollama

1. **Verifica el firewall:**
   ```powershell
   Test-NetConnection -ComputerName localhost -Port 11438
   ```

2. **Reinicia el contenedor:**
   ```powershell
   docker restart ollama-code
   ```

3. **Verifica los logs:**
   ```powershell
   docker logs ollama-code --tail 50
   ```

### El modelo aparece pero no responde

1. **Verifica que el modelo está cargado:**
   ```powershell
   docker exec ollama-code ollama show deepseek-coder:33b
   ```

2. **Prueba generar una respuesta:**
   ```powershell
   docker exec ollama-code ollama run deepseek-coder:33b "Hello"
   ```

## 📝 Notas Importantes

- **Formato del modelo**: Cursor puede requerir el prefijo `ollama/` antes del nombre del modelo
- **URL Base**: Algunas versiones de Cursor requieren `/v1` al final de la URL
- **API Key**: Ollama no requiere una API key real, pero usa `"ollama"` como placeholder
- **Reinicio**: Siempre reinicia Cursor después de cambiar la configuración

## 🔄 Alternativas si no Funciona

Si ninguna configuración funciona, puedes:

1. **Usar la extensión de Ollama** (si está disponible en el marketplace de Cursor)
2. **Usar un proxy local** que traduzca las llamadas de Cursor a Ollama
3. **Configurar variables de entorno** antes de iniciar Cursor:
   ```powershell
   $env:CURSOR_MODEL_PROVIDER = "ollama"
   $env:CURSOR_MODEL_BASE_URL = "http://localhost:11438"
   $env:CURSOR_MODEL = "deepseek-coder:33b"
   ```

---

**¿Necesitas ayuda con algún paso específico?** Verifica los logs de Docker y prueba la conexión manualmente primero.







