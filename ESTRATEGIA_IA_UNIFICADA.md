# Estrategia de IA Local Unificada

## Visión General

Este proyecto implementa un ecosistema completo de IA local que integra múltiples funcionalidades en una interfaz unificada:

- **IA Local**: Modelos de lenguaje ejecutándose localmente con Ollama
- **Búsqueda Web**: Acceso a información actualizada mediante DuckDuckGo y Tavily
- **Generación de Imágenes**: Flux y ComfyUI para crear imágenes
- **Generación de Videos**: Stable Video Diffusion para videos
- **Síntesis de Voz**: Coqui TTS para texto a voz
- **Clonación de Voz**: XTTS para clonar voces
- **APIs Externas**: Integración con Gemini y Hugging Face
- **Herramientas de Marketing**: Copy, hashtags, análisis, imágenes y videos optimizados

## Arquitectura

```
Open WebUI (8082) - Interfaz Unificada
├── Ollama LLMs
│   ├── Mistral (11436) - LLM General
│   ├── Qwen (11437) - LLM Alternativo
│   ├── Code (11438) - IA de Programación
│   └── Flux (11439) - Generación de Imágenes
├── ComfyUI (7860) - Generación Avanzada de Imágenes
├── Stable Video (8000) - Generación de Videos
├── Coqui TTS (5002) - Síntesis de Voz + Clonación
├── Web Search (5003) - Búsqueda Web
└── External APIs Gateway (5004) - Gemini + Hugging Face
```

## Componentes Principales

### 1. Servicios Docker

Todos los servicios están containerizados y se pueden gestionar con Docker Compose:

- **docker-compose-unified.yml**: Configuración completa de todos los servicios
- Scripts de setup individuales para cada servicio
- Script de verificación unificado

### 2. Extensiones Open WebUI

Las extensiones en `extensions/open-webui-multimedia/` proporcionan:

- **web_search.py**: Búsqueda web con DuckDuckGo y Tavily
- **voice_cloning.py**: Clonación de voz con XTTS
- **external_apis.py**: Integración con Gemini y Hugging Face
- **marketing_tools.py**: Herramientas especializadas para marketing
- **marketing_templates.py**: Templates y workflows predefinidos
- **image_generator.py**: Generación de imágenes (mejorado con funciones de marketing)
- **video_generator.py**: Generación de videos (mejorado con funciones de marketing)

### 3. Servidores Python

Servicios backend independientes:

- **web_search_server.py**: Servidor Flask para búsqueda web
- **tts_server.py**: Servidor Flask para TTS y clonación de voz
- **api_gateway.py**: Gateway para APIs externas

## Instalación Rápida

### Opción 1: Docker Compose (Recomendado)

```powershell
# Levantar todos los servicios
docker-compose -f docker-compose-unified.yml up -d

# Ver estado
docker-compose -f docker-compose-unified.yml ps

# Ver logs
docker-compose -f docker-compose-unified.yml logs -f
```

### Opción 2: Scripts Individuales

```powershell
# 1. Búsqueda Web
.\scripts\setup-web-search.ps1

# 2. Clonación de Voz
.\scripts\setup-voice-cloning.ps1

# 3. APIs Externas
.\scripts\setup-external-apis.ps1

# 4. Configurar Open WebUI
.\scripts\configure-open-webui-unified.ps1
```

## Configuración de API Keys (Opcional)

### Tavily (Búsqueda Web)

```powershell
$env:TAVILY_API_KEY = "tu_api_key"
```

**Nota**: DuckDuckGo funciona sin API key, Tavily es opcional.

### Google Gemini

```powershell
$env:GEMINI_API_KEY = "tu_api_key"
```

Obtén tu API key en: https://makersuite.google.com/app/apikey

### Hugging Face

```powershell
$env:HUGGINGFACE_API_KEY = "tu_token"
```

Obtén tu token en: https://huggingface.co/settings/tokens

**Nota**: Algunos modelos de Hugging Face funcionan sin API key.

## Uso desde Open WebUI

### Búsqueda Web

```
Busca información sobre: [tu consulta]
```

O usa la función directamente:
```python
from extensions.open-webui-multimedia import web_search
result = web_search("IA local 2024", provider="duckduckgo")
```

### Clonación de Voz

```python
from extensions.open-webui-multimedia import clone_voice
result = clone_voice(
    text="Hola, esta es una prueba",
    reference_audio="base64_audio_data",
    language="es"
)
```

### Generación de Imágenes para Marketing

```python
from extensions.open-webui-multimedia import generate_social_media_image
result = generate_social_media_image(
    prompt="Producto innovador",
    platform="instagram",
    content_type="post"
)
```

### Generación de Videos para Marketing

```python
from extensions.open-webui-multimedia import generate_marketing_video
result = generate_marketing_video(
    image_path="imagen.png",
    duration=15,
    add_narration=True,
    narration_text="Descubre nuestro nuevo producto"
)
```

### Herramientas de Marketing

```python
from extensions.open-webui-multimedia import generate_marketing_copy, generate_hashtags

# Generar copy
copy = generate_marketing_copy(
    product="Producto X",
    audience="Jóvenes profesionales",
    tone="profesional",
    template_type="social_media_post"
)

# Generar hashtags
hashtags = generate_hashtags(
    topic="tecnología",
    platform="instagram",
    count=10
)
```

## Funcionalidades de Marketing

### Generación de Copy

- Posts para redes sociales
- Emails de marketing
- Landing pages
- Descripciones de productos

### Generación de Hashtags

- Optimizados por plataforma (Instagram, Twitter, LinkedIn, TikTok)
- Estrategias específicas por plataforma
- Cantidad recomendada por plataforma

### Análisis de Competencia

- Búsqueda de información sobre competidores
- Análisis de estrategias de marketing
- Resumen de resultados

### Briefs de Campaña

- Generación automática de briefs estructurados
- Incluye objetivos, audiencia, canales, tipos de contenido
- Base para desarrollar campañas completas

### Imágenes para Marketing

- Dimensiones optimizadas por plataforma
- Estilos predefinidos (modern, bold, elegant, etc.)
- Banners y posts de redes sociales
- Generación desde prompts simples

### Videos para Marketing

- Duración optimizada (5s, 15s, 30s, 60s)
- Integración con TTS para narración
- Videos desde imágenes generadas
- Transiciones entre múltiples imágenes

## Verificación del Sistema

```powershell
# Verificar todos los servicios
.\scripts\verificar-unified-system.ps1
```

Este script verifica:
- Estado de todos los contenedores
- Conectividad de las APIs
- Funcionalidades específicas (clonación, búsqueda, APIs externas)
- Uso de GPU

## Troubleshooting

### Servicio no inicia

1. Verifica que Docker está corriendo
2. Revisa los logs: `docker logs [nombre-contenedor]`
3. Verifica que los puertos no están ocupados
4. Asegúrate de tener GPU NVIDIA si es necesario

### API no responde

1. Verifica que el contenedor está corriendo: `docker ps`
2. Prueba el endpoint de health: `curl http://localhost:[puerto]/health`
3. Revisa los logs del contenedor
4. Verifica el firewall de Windows

### Clonación de voz no funciona

1. XTTS se carga bajo demanda en el primer uso
2. Espera varios minutos la primera vez
3. Verifica que tienes suficiente VRAM (XTTS requiere ~2GB)
4. Revisa los logs: `docker logs coqui-tts`

### Búsqueda web no funciona

1. DuckDuckGo funciona sin API key
2. Si usas Tavily, verifica que la API key está configurada
3. Verifica conectividad a internet
4. Revisa los logs: `docker logs web-search`

## Próximos Pasos

1. **Configurar API keys** (opcional) para funcionalidades premium
2. **Explorar las funcionalidades** desde Open WebUI
3. **Crear contenido de marketing** usando las herramientas integradas
4. **Personalizar templates** según tus necesidades
5. **Integrar con tus workflows** existentes

## Recursos Adicionales

- **GUIA_BUSQUEDA_WEB.md**: Guía detallada de búsqueda web
- **GUIA_CLONACION_VOZ.md**: Guía de clonación de voz
- **GUIA_APIS_EXTERNAS.md**: Guía de APIs externas
- **GUIA_MARKETING.md**: Guía completa de herramientas de marketing
- **GUIA_INTERFAZ_MEJORADA.md**: Guía de uso de la interfaz mejorada

## Soporte

Para problemas o preguntas:
1. Revisa la documentación específica de cada funcionalidad
2. Verifica los logs de los servicios
3. Ejecuta el script de verificación
4. Consulta los ejemplos de uso en cada guía









