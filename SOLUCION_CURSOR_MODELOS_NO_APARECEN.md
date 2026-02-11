# 🔧 Solución: Modelos de Ollama no Aparecen en Cursor

## Problema
Los modelos de Ollama no aparecen en la sección "Models" de Cursor ni en la lista del chat.

## ⚠️ Limitación de Cursor

Cursor está diseñado principalmente para trabajar con proveedores de API estándar (OpenAI, Anthropic, etc.). Los modelos locales de Ollama **pueden no aparecer automáticamente** en la lista de modelos de la interfaz, pero **sí pueden funcionar** si se configuran correctamente.

## ✅ Solución 1: Configurar como API Compatible con OpenAI

Ollama soporta el protocolo compatible con OpenAI. Usa esta configuración:

```json
{
    "cursor.model": "deepseek-coder:33b",
    "cursor.modelProvider": "openai",
    "cursor.modelBaseUrl": "http://localhost:11438/v1",
    "cursor.apiKey": "ollama"
}
```

**Nota:** El `/v1` al final es importante para la compatibilidad con OpenAI.

## ✅ Solución 2: Usar desde Settings de Cursor

1. **Abre Cursor Settings:**
   - `Ctrl + ,` (o `Cmd + ,` en Mac)
   - O `File → Preferences → Settings`

2. **Ve a la sección "Models" o "API Keys":**
   - Busca "Custom API" o "OpenAI Compatible"
   - O busca "Model Base URL"

3. **Configura manualmente:**
   - **Provider:** OpenAI (o Custom)
   - **Base URL:** `http://localhost:11438/v1`
   - **API Key:** `ollama` (cualquier texto funciona)
   - **Model:** `deepseek-coder:33b`

## ✅ Solución 3: Usar el Chat Directamente

Aunque el modelo no aparezca en la lista, puedes usarlo directamente:

1. Abre el chat en Cursor (`Ctrl + L`)
2. Escribe tu pregunta
3. Si está configurado correctamente, Cursor usará el modelo de Ollama automáticamente

## ✅ Solución 4: Crear un Proxy Local

Si ninguna configuración funciona, crea un proxy que exponga Ollama como API estándar:

### Opción A: Usar Ollama Proxy (si ya lo tienes)

Si tienes `ollama-proxy` corriendo en el puerto 11440, úsalo:

```json
{
    "cursor.model": "deepseek-coder:33b",
    "cursor.modelProvider": "openai",
    "cursor.modelBaseUrl": "http://localhost:11440/v1",
    "cursor.apiKey": "ollama"
}
```

### Opción B: Crear un Proxy Simple con Python

Crea un archivo `ollama-proxy.py`:

```python
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)
OLLAMA_URL = "http://localhost:11438"

@app.route('/v1/models', methods=['GET'])
def list_models():
    response = requests.get(f"{OLLAMA_URL}/api/tags")
    models = response.json().get('models', [])
    return jsonify({
        "data": [{"id": m['name'], "object": "model"} for m in models]
    })

@app.route('/v1/chat/completions', methods=['POST'])
def chat():
    data = request.json
    model = data.get('model', 'deepseek-coder:33b')
    messages = data.get('messages', [])
    prompt = messages[-1]['content'] if messages else ""
    
    response = requests.post(
        f"{OLLAMA_URL}/api/generate",
        json={"model": model, "prompt": prompt, "stream": False}
    )
    result = response.json()
    
    return jsonify({
        "choices": [{
            "message": {"role": "assistant", "content": result.get('response', '')}
        }]
    })

if __name__ == '__main__':
    app.run(port=11441)
```

Ejecuta: `python ollama-proxy.py`

Luego usa: `http://localhost:11441/v1`

## 🔍 Verificar que Funciona

### Paso 1: Probar la API de Ollama

```powershell
# Verificar que Ollama responde
Invoke-WebRequest -Uri "http://localhost:11438/v1/models" -UseBasicParsing

# Probar generación
$body = @{
    model = "deepseek-coder:33b"
    prompt = "Hello"
    stream = $false
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:11438/api/generate" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
```

### Paso 2: Verificar en Cursor

1. Abre el chat (`Ctrl + L`)
2. Escribe una pregunta simple
3. Verifica en los logs de Docker si hay actividad:
   ```powershell
   docker logs ollama-code --tail 20 -f
   ```

## 📝 Configuraciones Alternativas a Probar

### Configuración 1: Formato OpenAI Estándar
```json
{
    "cursor.model": "deepseek-coder:33b",
    "cursor.modelProvider": "openai",
    "cursor.modelBaseUrl": "http://localhost:11438/v1",
    "cursor.apiKey": "ollama"
}
```

### Configuración 2: Sin Provider Específico
```json
{
    "cursor.model": "deepseek-coder:33b",
    "cursor.modelBaseUrl": "http://localhost:11438/v1",
    "cursor.apiKey": "ollama"
}
```

### Configuración 3: Con Custom
```json
{
    "cursor.model": "deepseek-coder:33b",
    "cursor.modelProvider": "custom",
    "cursor.modelBaseUrl": "http://localhost:11438/v1",
    "cursor.apiKey": "ollama"
}
```

### Configuración 4: Para Chat Específico
```json
{
    "cursor.chat.model": "deepseek-coder:33b",
    "cursor.chat.modelProvider": "openai",
    "cursor.chat.modelBaseUrl": "http://localhost:11438/v1",
    "cursor.chat.apiKey": "ollama"
}
```

## 🎯 Modelos Disponibles

Según tus contenedores:

| Contenedor | Puerto | Modelos | URL con /v1 |
|------------|--------|---------|-------------|
| `ollama-code` | 11438 | `deepseek-coder:33b`, `codellama:34b` | `http://localhost:11438/v1` |
| `ollama-mistral` | 11436 | `mistral:latest` | `http://localhost:11436/v1` |
| `ollama-qwen` | 11437 | `qwen2.5:7b` | `http://localhost:11437/v1` |

## 🐛 Solución de Problemas

### El modelo no aparece pero debería funcionar

**Esto es normal.** Cursor puede no mostrar modelos locales en la lista, pero si la configuración es correcta, funcionará cuando uses el chat.

### Cursor no se conecta

1. **Verifica que Ollama responde:**
   ```powershell
   Test-NetConnection -ComputerName localhost -Port 11438
   ```

2. **Verifica el formato /v1:**
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:11438/v1/models" -UseBasicParsing
   ```

3. **Reinicia Cursor completamente**

### Los modelos aparecen pero no responden

1. **Verifica que el modelo está cargado:**
   ```powershell
   docker exec ollama-code ollama show deepseek-coder:33b
   ```

2. **Prueba directamente:**
   ```powershell
   docker exec ollama-code ollama run deepseek-coder:33b "Hello"
   ```

## 💡 Recomendación Final

**Si ninguna configuración hace que los modelos aparezcan en la lista**, esto es una limitación de Cursor. Sin embargo:

1. Configura la URL base con `/v1`
2. Usa el chat directamente
3. El modelo funcionará aunque no aparezca en la lista
4. Verifica en los logs de Docker que hay actividad cuando usas el chat

---

**¿Necesitas ayuda con algún paso específico?** Prueba primero la Solución 1 con `/v1` y verifica los logs de Docker.






