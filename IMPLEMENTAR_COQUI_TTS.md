# Implementar Coqui TTS (Síntesis de Voz)

## Descripción

Coqui TTS es una biblioteca open source para síntesis de voz (text-to-speech) con soporte para múltiples idiomas y voces naturales.

## Requisitos

- GPU NVIDIA (opcional, mejora la velocidad)
- ~2-5GB espacio en disco para modelos de voz
- Docker con soporte GPU (recomendado)

## Instalación

### Paso 1: Ejecutar Script de Configuración

```powershell
cd C:\code\moltbot
.\scripts\setup-coqui-tts.ps1
```

Este script:
- Crea el contenedor `coqui-tts` en el puerto 5002
- Instala Coqui TTS y dependencias
- Crea servidor Flask con API REST
- Configura modelos de voz (español e inglés)
- Configura firewall

### Paso 2: Verificar Instalación

```powershell
# Verificar que el contenedor está corriendo
docker ps | findstr coqui-tts

# Probar API de salud
curl http://localhost:5002/health

# Ver modelos disponibles
curl http://localhost:5002/api/models
```

**Nota**: Los modelos de voz se descargan automáticamente en el primer uso y pueden tardar varios minutos.

## Uso

### Desde API

```powershell
# Generar audio en español
curl -X POST http://localhost:5002/api/tts `
  -H "Content-Type: application/json" `
  -d '{"text":"Hola mundo, esto es una prueba de síntesis de voz","language":"es"}' `
  --output output.wav

# Generar audio en inglés
curl -X POST http://localhost:5002/api/tts `
  -H "Content-Type: application/json" `
  -d '{"text":"Hello world, this is a text to speech test","language":"en"}' `
  --output output.wav
```

### Desde Open WebUI

Después de configurar Open WebUI extendido, puedes usar la extensión multimedia para generar voz desde la interfaz.

### Modelos Disponibles

- **Español**: `tts_models/es/css10/vits` - Voz natural en español
- **Inglés**: `tts_models/en/ljspeech/tacotron2-DDC` - Voz natural en inglés

## Integración con Open WebUI

La extensión `tts_generator.py` está disponible automáticamente después de ejecutar `configure-open-webui-extended.ps1`.

### Ejemplo de Uso en Código

```python
from extensions.open-webui-multimedia.tts_generator import text_to_speech

result = text_to_speech(
    text="Hola, ¿cómo estás?",
    language="es",
    voice="default"
)

if result["success"]:
    # result["audio_data"] contiene el audio en base64
    audio_base64 = result["audio_data"]
    # Decodificar y guardar
    import base64
    audio_bytes = base64.b64decode(audio_base64)
    with open("output.wav", "wb") as f:
        f.write(audio_bytes)
```

## Solución de Problemas

### Error: "Model not found"
- **Solución**: Los modelos se descargan automáticamente. Espera unos minutos y vuelve a intentar

### Error: "Connection refused"
- **Solución**: Verifica que el contenedor está corriendo:
  ```powershell
  docker ps | findstr coqui-tts
  docker logs coqui-tts --tail 50
  ```

### Audio de baja calidad
- **Solución**: 
  - Usa modelos de mayor calidad (requieren más espacio)
  - Asegúrate de que la GPU está siendo usada para mejor rendimiento

### Tiempo de respuesta lento
- **Normal**: La primera generación tarda más (descarga del modelo)
- **Optimización**: Usa GPU para acelerar el proceso

## Recursos

- **Puerto**: 5002
- **API Base**: `http://localhost:5002`
- **Documentación Coqui TTS**: https://github.com/coqui-ai/TTS
- **Modelos disponibles**: https://github.com/coqui-ai/TTS/wiki/Released-Models

## Personalización

### Agregar más idiomas

Edita `tts_server.py` en `${USERPROFILE}\coqui-tts-data\tts_server.py` y agrega más modelos:

```python
if language == 'fr':
    model_name = "tts_models/fr/css10/vits"
elif language == 'de':
    model_name = "tts_models/de/css10/vits"
```

Luego reinicia el contenedor:
```powershell
docker restart coqui-tts
```












