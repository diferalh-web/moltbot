# Guía de Clonación de Voz

## Descripción

La clonación de voz permite generar audio usando la voz de una persona a partir de una muestra de audio de referencia. Utiliza XTTS (eXtended Text-to-Speech) de Coqui TTS.

## Requisitos

- GPU NVIDIA (recomendado, ~2GB VRAM)
- Audio de referencia (mínimo 3-5 segundos, preferiblemente 10-30 segundos)
- Formato de audio: WAV, MP3, OGG

## Configuración

### Instalación

```powershell
.\scripts\setup-voice-cloning.ps1
```

**Nota**: XTTS se carga automáticamente en el primer uso y puede tardar varios minutos.

## Preparación del Audio de Referencia

### Características Ideales

- **Duración**: 10-30 segundos (mínimo 3-5 segundos)
- **Calidad**: Audio claro, sin ruido de fondo
- **Formato**: WAV (sin compresión) es ideal
- **Contenido**: Habla natural, sin música ni efectos

### Formatos Soportados

- WAV (recomendado)
- MP3
- OGG
- FLAC

## Uso desde Open WebUI

### Uso Básico

1. Prepara tu audio de referencia
2. Convierte a base64 o sube a una URL accesible
3. Usa la función de clonación:

```python
from extensions.open-webui-multimedia import clone_voice

result = clone_voice(
    text="El texto que quieres generar con la voz clonada",
    reference_audio="base64_encoded_audio",
    language="es"
)
```

### Desde Archivo Local

```python
from extensions.open-webui-multimedia import clone_voice_from_file

result = clone_voice_from_file(
    text="Hola, esta es una prueba de clonación de voz",
    audio_file_path="/ruta/al/audio.wav",
    language="es"
)
```

### Desde URL

```python
from extensions.open-webui-multimedia import clone_voice_from_url

result = clone_voice_from_url(
    text="Texto a generar",
    audio_url="https://ejemplo.com/audio.wav",
    language="es"
)
```

## Idiomas Soportados

XTTS soporta múltiples idiomas:

- Español (es)
- Inglés (en)
- Francés (fr)
- Alemán (de)
- Italiano (it)
- Portugués (pt)
- Polaco (pl)
- Turco (tr)
- Ruso (ru)
- Holandés (nl)
- Checo (cs)
- Árabe (ar)
- Chino (zh)
- Japonés (ja)
- Coreano (ko)

## Ejemplos de Uso

### Narración de Videos

```python
# Generar narración para un video de marketing
from extensions.open-webui-multimedia import clone_voice, generate_marketing_video

# Clonar voz del narrador
narration_audio = clone_voice(
    text="Bienvenido a nuestro nuevo producto...",
    reference_audio="narrator_voice.wav",
    language="es"
)

# Generar video con narración
video = generate_marketing_video(
    image_path="producto.png",
    duration=30,
    add_narration=True,
    narration_text="Bienvenido a nuestro nuevo producto..."
)
```

### Personalización de Contenido

```python
# Crear múltiples versiones con diferentes voces
voices = ["voice1.wav", "voice2.wav", "voice3.wav"]
texts = ["Versión 1", "Versión 2", "Versión 3"]

for voice, text in zip(voices, texts):
    result = clone_voice_from_file(
        text=text,
        audio_file_path=voice,
        language="es"
    )
```

## Limitaciones

1. **Primera carga**: XTTS tarda varios minutos en cargar la primera vez
2. **VRAM**: Requiere ~2GB de VRAM para funcionar óptimamente
3. **Calidad del audio de referencia**: Mejor calidad = mejor clonación
4. **Idioma**: El audio de referencia y el texto deben estar en el mismo idioma para mejores resultados
5. **Duración**: Textos muy largos pueden tardar más en generar

## Mejores Prácticas

1. **Audio de referencia de calidad**: Usa audio claro y sin ruido
2. **Duración adecuada**: 10-30 segundos es ideal
3. **Mismo idioma**: Asegúrate de que el audio y el texto están en el mismo idioma
4. **Texto natural**: Escribe el texto como se hablaría naturalmente
5. **Pruebas**: Prueba con diferentes textos para encontrar el mejor resultado

## Troubleshooting

### Error: "XTTS no está disponible"

1. Espera unos minutos (se carga bajo demanda)
2. Verifica que tienes suficiente VRAM
3. Revisa los logs: `docker logs coqui-tts`

### Error: "No se pudo acceder al audio de referencia"

1. Verifica que el archivo existe y es accesible
2. Si usas base64, asegúrate de que está correctamente codificado
3. Si usas URL, verifica que es accesible públicamente

### Calidad de clonación baja

1. Mejora la calidad del audio de referencia
2. Usa audio más largo (15-30 segundos)
3. Asegúrate de que el audio está en el mismo idioma que el texto
4. Reduce el ruido de fondo del audio de referencia

### Tiempo de generación muy largo

1. Normal en la primera generación (carga del modelo)
2. Usa GPU para acelerar
3. Reduce la longitud del texto si es muy largo

## Verificación

```powershell
# Verificar que la clonación está disponible
curl http://localhost:5002/api/models

# Debe mostrar "voice_cloning_available": true
```

## Casos de Uso

- **Marketing**: Narraciones personalizadas para videos
- **Educación**: Contenido educativo con voces específicas
- **Accesibilidad**: Generar audio en diferentes voces
- **Localización**: Adaptar contenido a diferentes acentos
- **Personalización**: Crear experiencias únicas para usuarios









