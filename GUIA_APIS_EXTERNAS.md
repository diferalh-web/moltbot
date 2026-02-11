# Guía de APIs Externas

## Descripción

El gateway de APIs externas permite integrar servicios de IA en la nube con tu ecosistema local:

- **Google Gemini**: Modelo avanzado de Google
- **Hugging Face**: Acceso a miles de modelos open source

## Configuración

### Instalación

```powershell
.\scripts\setup-external-apis.ps1
```

### Configurar API Keys

#### Google Gemini

```powershell
$env:GEMINI_API_KEY = "tu_api_key"
```

Obtén tu API key en: https://makersuite.google.com/app/apikey

#### Hugging Face

```powershell
$env:HUGGINGFACE_API_KEY = "tu_token"
```

Obtén tu token en: https://huggingface.co/settings/tokens

**Nota**: Algunos modelos de Hugging Face funcionan sin API key.

## Uso desde Open WebUI

### Google Gemini

```python
from extensions.open-webui-multimedia import call_gemini

result = call_gemini(
    prompt="Explica qué es la inteligencia artificial",
    model="gemini-pro",
    api_key="tu_key"  # Opcional, usa variable de entorno si no se proporciona
)
```

### Hugging Face

```python
from extensions.open-webui-multimedia import call_huggingface

result = call_huggingface(
    model="gpt2",
    prompt="Hello world",
    api_key="tu_token"  # Opcional
)
```

## Modelos Disponibles

### Google Gemini

- **gemini-pro**: Modelo general de propósito
- **gemini-pro-vision**: Modelo con capacidades de visión

### Hugging Face (Ejemplos)

- **gpt2**: Modelo básico de OpenAI
- **mistralai/Mistral-7B-Instruct-v0.2**: Modelo instructivo
- **meta-llama/Llama-2-7b-chat-hf**: Modelo de chat
- **google/flan-t5-base**: Modelo T5 de Google

**Nota**: Hay miles de modelos disponibles en Hugging Face. Busca en: https://huggingface.co/models

## Ejemplos de Uso

### Generación de Contenido con Gemini

```python
from extensions.open-webui-multimedia import call_gemini

# Generar copy de marketing
copy = call_gemini(
    prompt="Genera un post de Instagram sobre nuestro nuevo producto de tecnología",
    model="gemini-pro"
)

print(copy["response"])
```

### Análisis con Hugging Face

```python
from extensions.open-webui-multimedia import call_huggingface

# Análisis de sentimiento
sentiment = call_huggingface(
    model="cardiffnlp/twitter-roberta-base-sentiment-latest",
    prompt="Me encanta este producto!"
)
```

### Integración con Marketing

```python
from extensions.open-webui-multimedia import call_gemini, generate_marketing_copy

# Usar Gemini para mejorar copy de marketing
basic_copy = generate_marketing_copy(
    product="Producto X",
    audience="Jóvenes",
    tone="casual"
)

# Mejorar con Gemini
enhanced = call_gemini(
    prompt=f"Mejora este copy de marketing: {basic_copy['prompt']}",
    model="gemini-pro"
)
```

## Límites y Consideraciones

### Google Gemini

- **Plan gratuito**: Generoso, pero con límites de rate
- **Costo**: Consulta la página de precios de Google
- **Latencia**: Depende de la conexión a internet

### Hugging Face

- **Modelos públicos**: Muchos funcionan sin API key
- **Modelos privados**: Requieren API key
- **Rate limits**: Varían por modelo
- **Cold start**: Algunos modelos pueden tardar en cargar (503 error)

## Troubleshooting

### Error: "GEMINI_API_KEY no configurada"

1. Configura la variable de entorno: `$env:GEMINI_API_KEY = "tu_key"`
2. O proporciona la key en la llamada a la función
3. Reinicia el contenedor después de configurar

### Error: "Model is loading" (Hugging Face)

1. Espera unos minutos y vuelve a intentar
2. Algunos modelos grandes tardan en cargar
3. Usa modelos más pequeños si necesitas respuesta inmediata

### Error: "Rate limit exceeded"

1. Reduce la frecuencia de llamadas
2. Implementa retry con backoff
3. Considera usar modelos locales para evitar límites

### Error de conexión

1. Verifica tu conexión a internet
2. Verifica que el servicio está corriendo: `docker ps | findstr external-apis-gateway`
3. Revisa los logs: `docker logs external-apis-gateway`

## Mejores Prácticas

1. **Usa modelos locales cuando sea posible**: Más rápido y sin límites
2. **Combina local y nube**: Usa local para tareas comunes, nube para especializadas
3. **Cachea respuestas**: Evita llamadas repetidas
4. **Maneja errores**: Implementa retry para errores temporales
5. **Monitorea uso**: Revisa el uso de API keys para evitar sorpresas

## Casos de Uso

### Cuando Usar Gemini

- Tareas que requieren conocimiento actualizado
- Análisis complejos
- Generación de contenido de alta calidad
- Cuando los modelos locales no son suficientes

### Cuando Usar Hugging Face

- Modelos especializados (sentimiento, traducción, etc.)
- Experimentación con diferentes modelos
- Tareas específicas que requieren modelos especializados
- Cuando quieres probar modelos open source

## Integración con el Ecosistema Local

Las APIs externas complementan tu ecosistema local:

```
Local (Ollama) → Tareas generales, rápido, sin límites
     ↓
Externo (Gemini/HF) → Tareas especializadas, conocimiento actualizado
```

Usa local para la mayoría de tareas y externo cuando necesites capacidades específicas o conocimiento actualizado.









