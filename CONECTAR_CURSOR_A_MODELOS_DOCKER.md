# 🔌 Conectar Cursor a Modelos Ollama en Docker

## 📋 Resumen

Esta guía te mostrará cómo configurar Cursor IDE para usar los modelos de Ollama que tienes corriendo en Docker para desarrollo.

## 🐳 Modelos Disponibles en Docker

Según tu configuración actual, tienes los siguientes contenedores de Ollama:

| Contenedor | Puerto | URL Local | Modelos Disponibles |
|------------|--------|-----------|---------------------|
| `ollama-mistral` | 11436 | `http://localhost:11436` | mistral:latest (4.4 GB) |
| `ollama-qwen` | 11437 | `http://localhost:11437` | qwen2.5:7b (4.7 GB) |
| `ollama-code` | 11438 | `http://localhost:11438` | codellama:34b (19 GB), deepseek-coder:33b (18 GB) |
| `ollama-flux` | 11439 | `http://localhost:11439` | flux (imágenes) |
| `ollama-moltbot` | 11435 | `http://localhost:11435` | llama2 |

## 🚀 Inicio Rápido

**Verifica tus modelos disponibles:**

```powershell
# Ver modelos en cada contenedor
docker exec ollama-code ollama list
docker exec ollama-mistral ollama list
docker exec ollama-qwen ollama list
```

**Configuración recomendada para desarrollo de código:**

Abre Cursor Settings (JSON) con `Ctrl + Shift + P` → `Preferences: Open User Settings (JSON)` y agrega:

```json
{
  "cursor.modelBaseUrl": "http://localhost:11438",
  "cursor.model": "deepseek-coder:33b",
  "cursor.apiKey": "ollama"
}
```

## ✅ Paso 1: Verificar que los Contenedores Están Corriendo

```powershell
# Ver todos los contenedores de Ollama
docker ps --filter "name=ollama" --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"

# Verificar que responden
curl http://localhost:11436/api/tags
curl http://localhost:11437/api/tags
curl http://localhost:11438/api/tags
```

## 🔧 Paso 2: Configurar Cursor para Usar Ollama Local

### Opción A: Configuración en Settings de Cursor (Recomendado)

1. **Abre Cursor Settings:**
   - Presiona `Ctrl + ,` (o `Cmd + ,` en Mac)
   - O ve a `File → Preferences → Settings`

2. **Busca "Model" o "AI Model":**
   - En la barra de búsqueda, escribe: `cursor.model`

3. **Configura el modelo:**
   - Busca la opción `Cursor: Model` o `AI: Model`
   - Selecciona "Custom" o "Ollama"

4. **Configura la URL base:**
   - Busca `Cursor: Model Base URL` o similar
   - Ingresa: `http://localhost:11438` (para modelos de código)
   - O `http://localhost:11436` (para Mistral general)

### Opción B: Configuración Manual en settings.json

1. **Abre el archivo de configuración:**
   - Presiona `Ctrl + Shift + P` (o `Cmd + Shift + P` en Mac)
   - Escribe: `Preferences: Open User Settings (JSON)`
   - Presiona Enter

2. **Agrega la configuración:**

```json
{
  "cursor.aiModel": "ollama",
  "cursor.modelBaseUrl": "http://localhost:11438",
  "cursor.model": "deepseek-coder:33b",
  "cursor.apiKey": "ollama"
}
```

**O para usar Mistral:**

```json
{
  "cursor.aiModel": "ollama",
  "cursor.modelBaseUrl": "http://localhost:11436",
  "cursor.model": "mistral:latest",
  "cursor.apiKey": "ollama"
}
```

### Opción C: Usar Variables de Entorno

Si Cursor no tiene opciones directas para Ollama, puedes configurar variables de entorno:

```powershell
# En PowerShell (sesión actual)
$env:OLLAMA_HOST = "http://localhost:11438"
$env:OLLAMA_MODEL = "deepseek-coder:33b"

# O crear un archivo .env en tu proyecto
# OLLAMA_HOST=http://localhost:11438
# OLLAMA_MODEL=deepseek-coder:33b
```

## 🎯 Paso 3: Verificar Modelos Disponibles

Antes de configurar, verifica qué modelos tienes en cada contenedor:

```powershell
# Ver modelos en ollama-code (recomendado para desarrollo)
docker exec ollama-code ollama list

# Ver modelos en ollama-mistral
docker exec ollama-mistral ollama list

# Ver modelos en ollama-qwen
docker exec ollama-qwen ollama list
```

## 🔍 Paso 4: Configuración Específica por Modelo

### Para Desarrollo de Código (Recomendado)

**Usa `ollama-code` (puerto 11438):**

```json
{
  "cursor.modelBaseUrl": "http://localhost:11438",
  "cursor.model": "deepseek-coder:33b",
  "cursor.apiKey": "ollama"
}
```

**Modelos disponibles en ollama-code:**
- `deepseek-coder:33b` - Mejor para programación compleja
- `codellama:34b` - Alternativa más rápida
- `wizardcoder:34b` - Para seguridad y auditoría

### Para Chat General

**Usa `ollama-mistral` (puerto 11436):**

```json
{
  "cursor.modelBaseUrl": "http://localhost:11436",
  "cursor.model": "mistral:latest",
  "cursor.apiKey": "ollama"
}
```

### Para Chat Alternativo

**Usa `ollama-qwen` (puerto 11437):**

```json
{
  "cursor.modelBaseUrl": "http://localhost:11437",
  "cursor.model": "qwen2.5:7b",
  "cursor.apiKey": "ollama"
}
```

## 🧪 Paso 5: Probar la Conexión

### Probar desde Terminal

```powershell
# Probar API de Ollama directamente
curl http://localhost:11438/api/generate -Method POST -ContentType "application/json" -Body '{
  "model": "deepseek-coder:33b",
  "prompt": "Write a hello world in Python",
  "stream": false
}'
```

### Probar desde Cursor

1. Abre un archivo de código
2. Selecciona código y presiona `Ctrl + K` (o `Cmd + K` en Mac)
3. Escribe una pregunta o solicitud
4. Cursor debería usar tu modelo local de Ollama

## ⚙️ Paso 6: Configuración Avanzada

### Usar Múltiples Modelos

Si Cursor soporta múltiples modelos, puedes configurar perfiles:

```json
{
  "cursor.models": {
    "code": {
      "baseUrl": "http://localhost:11438",
      "model": "deepseek-coder:33b",
      "apiKey": "ollama"
    },
    "general": {
      "baseUrl": "http://localhost:11436",
      "model": "mistral:latest",
      "apiKey": "ollama"
    }
  }
}
```

### Configurar Timeout y Retry

Si tienes problemas de conexión:

```json
{
  "cursor.modelBaseUrl": "http://localhost:11438",
  "cursor.modelTimeout": 60000,
  "cursor.modelRetry": 3
}
```

## 🐛 Solución de Problemas

### Error: "Cannot connect to Ollama"

1. **Verifica que Docker está corriendo:**
   ```powershell
   docker ps | findstr ollama
   ```

2. **Verifica que el puerto está accesible:**
   ```powershell
   Test-NetConnection -ComputerName localhost -Port 11438
   ```

3. **Verifica que el contenedor está saludable:**
   ```powershell
   docker logs ollama-code --tail 50
   ```

### Error: "Model not found"

1. **Verifica que el modelo está instalado:**
   ```powershell
   docker exec ollama-code ollama list
   ```

2. **Si falta, descárgalo:**
   ```powershell
   docker exec ollama-code ollama pull deepseek-coder:33b
   ```

### Error: "Connection refused"

1. **Verifica que el puerto está expuesto:**
   ```powershell
   docker port ollama-code
   ```
   Debería mostrar: `11434/tcp -> 0.0.0.0:11438`

2. **Reinicia el contenedor:**
   ```powershell
   docker restart ollama-code
   ```

### Cursor no detecta Ollama

Si Cursor no tiene soporte nativo para Ollama, puedes:

1. **Usar un proxy local:**
   - Configura un proxy que traduzca las llamadas de Cursor a Ollama
   - O usa `ollama-proxy` que ya tienes en puerto 11440

2. **Usar extensiones:**
   - Busca extensiones de Ollama en el marketplace de Cursor
   - O usa extensiones de VS Code compatibles

## 📝 Notas Importantes

1. **Rendimiento:**
   - Los modelos grandes (33B, 34B) requieren mucha RAM
   - Asegúrate de tener suficiente memoria disponible
   - Los modelos más pequeños son más rápidos pero menos precisos

2. **Puertos:**
   - Cada contenedor usa un puerto diferente
   - Asegúrate de usar el puerto correcto para cada modelo

3. **API Key:**
   - Ollama no requiere una API key real
   - Usa `"ollama"` como placeholder si es requerido

4. **URL Base:**
   - Cursor puede requerir `/v1` al final: `http://localhost:11438/v1`
   - Prueba ambas variantes si una no funciona

## 🚀 Comandos Rápidos

```powershell
# Ver todos los modelos disponibles
docker exec ollama-code ollama list
docker exec ollama-mistral ollama list
docker exec ollama-qwen ollama list

# Probar un modelo específico
docker exec ollama-code ollama run deepseek-coder:33b "Write hello world in Python"

# Ver logs de un contenedor
docker logs ollama-code --tail 50 -f

# Reiniciar un contenedor
docker restart ollama-code
```

## 📚 Referencias

- [Documentación de Ollama](https://ollama.ai/docs)
- [Cursor Settings](https://cursor.sh/docs)
- [Ollama API](https://github.com/ollama/ollama/blob/main/docs/api.md)

---

**¿Necesitas ayuda con algún paso específico?** Revisa los logs de Docker o prueba la conexión manualmente primero.

