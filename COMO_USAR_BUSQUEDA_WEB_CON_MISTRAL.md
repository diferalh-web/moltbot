# 🔍 Cómo Usar Búsqueda Web con Mistral en Open WebUI

## ✅ Estado Actual

**Sí, el servicio de búsqueda web está configurado y funcionando**, pero el modelo Mistral puede no estar reconociendo automáticamente las funciones de extensión.

## 🎯 Cómo Usar la Búsqueda Web

### Método 1: Comandos Naturales (Recomendado)

Simplemente escribe en el chat de Open WebUI de manera natural:

**Ejemplos:**

```
Busca información sobre las últimas noticias de inteligencia artificial
```

```
¿Qué hay de nuevo sobre Docker y contenedores en 2024?
```

```
Busca información actualizada sobre marketing digital
```

```
Encuentra las últimas tendencias en tecnología
```

### Método 2: Instrucciones Explícitas

Si el modelo no busca automáticamente, puedes ser más explícito:

```
Por favor, busca en la web información sobre [tu tema] y dame un resumen
```

```
Usa la función de búsqueda web para encontrar información actual sobre [tema]
```

```
Necesito información actualizada sobre [tema]. Busca en internet y dame los resultados
```

### Método 3: Usar la API Directamente

Si las funciones de extensión no funcionan automáticamente, puedes llamar a la API directamente:

```powershell
# Búsqueda simple
$body = @{
    query = "noticias de IA 2024"
    provider = "duckduckgo"
    max_results = 5
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://localhost:5003/api/search" `
  -Method POST `
  -ContentType "application/json" `
  -Body $body `
  -UseBasicParsing

$results = $response.Content | ConvertFrom-Json
$results.results | ForEach-Object { Write-Host "$($_.title) - $($_.url)" }
```

## 📋 Ejemplos de Uso

### Información Actualizada

```
Busca las últimas noticias sobre inteligencia artificial local
```

### Investigación de Tendencias

```
¿Cuáles son las tendencias actuales en marketing digital para 2024?
```

### Análisis de Competencia

```
Busca información sobre [nombre de competidor] y su estrategia de marketing
```

### Comparación de Productos

```
Compara [producto A] vs [producto B] usando información actual de la web
```

### Información Técnica Actualizada

```
¿Qué hay de nuevo sobre Docker, Kubernetes y contenedores en los últimos meses?
```

## 🔧 Verificación del Servicio

### Verificar que el Servicio Esté Corriendo

```powershell
docker ps --filter "name=web-search"
```

### Probar la Búsqueda Manualmente

```powershell
$body = @{
    query = "test"
    provider = "duckduckgo"
    max_results = 3
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:5003/api/search" `
  -Method POST `
  -ContentType "application/json" `
  -Body $body `
  -UseBasicParsing
```

## ⚙️ Configuración

### Proveedores Disponibles

1. **DuckDuckGo** (por defecto)
   - ✅ Sin API key requerida
   - ✅ Ilimitado
   - ✅ Funciona inmediatamente

2. **Tavily** (opcional)
   - ⚠️ Requiere API key
   - ✅ 1,000 búsquedas/mes gratis
   - ✅ Resultados más estructurados

### Configurar Tavily (Opcional)

```powershell
# Configurar API key
$env:TAVILY_API_KEY = "tu_api_key"

# Reiniciar el servicio
docker restart web-search
```

Obtén tu API key en: https://tavily.com

## 💡 Consejos para Mejores Resultados

1. **Sé específico**: Menciona qué tipo de información necesitas
2. **Usa palabras clave**: Incluye términos relevantes en tu búsqueda
3. **Pide resumen**: Si quieres un resumen, explícitamente pídelo
4. **Especifica cantidad**: Puedes pedir "los 5 resultados más relevantes"
5. **Combina con preguntas**: Puedes hacer una búsqueda y luego hacer preguntas sobre los resultados

## 🎯 Ejemplo Completo de Conversación

**Usuario:**
```
Busca información actualizada sobre las últimas noticias de IA local y dame un resumen de los 5 resultados más relevantes
```

**Mistral debería:**
1. Llamar a la función `web_search` o `search_and_summarize`
2. Obtener resultados de DuckDuckGo
3. Procesar y resumir la información
4. Presentar los resultados de manera organizada

## 🔍 Si No Funciona Automáticamente

Si el modelo no está usando la búsqueda web automáticamente:

1. **Sé más explícito**: Menciona que necesitas buscar en la web
2. **Usa comandos directos**: "Busca en internet sobre..."
3. **Verifica el servicio**: Asegúrate de que `web-search` esté corriendo
4. **Revisa los logs**: `docker logs web-search --tail 20`
5. **Usa la API directamente**: Como se muestra en el Método 3

## 📝 Nota Importante

Las extensiones de Open WebUI pueden no estar siendo reconocidas automáticamente por el modelo LLM. Por eso:
- **Usa comandos naturales y específicos** en el chat
- **Menciona explícitamente** que necesitas buscar en la web
- **Si no funciona**, usa la API directamente o verifica la configuración

## 🚀 Próximos Pasos

1. **Prueba con comandos naturales** en el chat
2. **Si no funciona**, sé más explícito sobre la búsqueda
3. **Verifica el servicio** si hay problemas
4. **Usa la API directamente** si necesitas integración programática









