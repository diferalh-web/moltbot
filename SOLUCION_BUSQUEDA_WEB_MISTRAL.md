# 🔍 Solución: Mistral no usa Búsqueda Web

## ❌ Problema

Mistral responde con información desactualizada (2021) en lugar de usar la búsqueda web para obtener información actualizada de 2025.

## 🔍 Causa

Las funciones de búsqueda web están implementadas, pero **Open WebUI no las está exponiendo automáticamente como herramientas** que el modelo puede usar.

## ✅ Soluciones

### Solución 1: Usar Prompts Explícitos (Funciona Ahora)

En lugar de esperar que Mistral use automáticamente la búsqueda web, puedes ser más explícito en tus prompts:

#### Ejemplo 1: Búsqueda Directa
```
Por favor, busca en internet información actualizada sobre las últimas noticias de inteligencia artificial en 2025 y dame un resumen.
```

#### Ejemplo 2: Instrucción Clara
```
Necesito información actualizada. Usa la función de búsqueda web para encontrar las últimas noticias de tecnología en 2025.
```

#### Ejemplo 3: Específico
```
Busca en la web: "noticias de IA 2025" y dame los resultados más recientes.
```

### Solución 2: Usar la API Directamente (Alternativa)

Si el modelo no usa la búsqueda automáticamente, puedes llamar a la API directamente:

```powershell
# Búsqueda directa desde PowerShell
$body = @{
    query = "noticias de inteligencia artificial 2025"
    provider = "duckduckgo"
    max_results = 10
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://localhost:5003/api/search" `
  -Method POST `
  -ContentType "application/json" `
  -Body $body `
  -UseBasicParsing

$results = $response.Content | ConvertFrom-Json
$results.results | ForEach-Object { 
    Write-Host "`n=== $($_.title) ===" -ForegroundColor Cyan
    Write-Host $_.snippet -ForegroundColor White
    Write-Host "Fuente: $($_.url)" -ForegroundColor Gray
}
```

### Solución 3: Configurar Open WebUI para Function Calling (Recomendado)

Open WebUI necesita configurarse para exponer las funciones como "tools" al modelo. Esto requiere:

1. **Verificar que la extensión esté cargada**:
   - Las funciones están en `extensions/open-webui-multimedia/`
   - El archivo `tools.py` registra las herramientas

2. **Habilitar Function Calling en el modelo**:
   - Algunos modelos de Ollama soportan function calling
   - Mistral puede necesitar una versión específica que soporte tools

3. **Usar un modelo que soporte Function Calling**:
   - Prueba con `mistral:latest` (debería soportar)
   - O usa `qwen2.5:7b` que tiene mejor soporte para tools

## 🧪 Prueba Rápida

### Test 1: Verificar que el servicio funciona
```powershell
curl http://localhost:5003/health
```

### Test 2: Probar búsqueda directa
```powershell
curl -X POST http://localhost:5003/api/search `
  -H "Content-Type: application/json" `
  -d '{\"query\":\"noticias IA 2025\",\"provider\":\"duckduckgo\"}'
```

### Test 3: Probar desde Open WebUI
1. Abre http://localhost:8082
2. Selecciona Mistral
3. Escribe: "Busca información actualizada sobre inteligencia artificial en 2025"
4. Si no busca, prueba: "Por favor, usa la función web_search para buscar: noticias IA 2025"

## 📝 Nota Importante

**Mistral puede no reconocer automáticamente cuándo debe usar la búsqueda web**. Esto es normal porque:

1. Los modelos locales no tienen acceso a internet por defecto
2. Necesitan instrucciones explícitas para usar herramientas externas
3. Open WebUI puede requerir configuración adicional para exponer las funciones

## 🚀 Recomendación

**Por ahora, usa prompts explícitos** que indiquen claramente que necesitas búsqueda web:

```
Busca en internet información sobre [tu tema] y dame un resumen actualizado.
```

O:

```
Usa la función de búsqueda web para encontrar información actual sobre [tema].
```

Esto debería funcionar mejor que esperar que el modelo lo haga automáticamente.








