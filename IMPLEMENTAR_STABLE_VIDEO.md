# Implementar Stable Video Diffusion

## Descripción

Stable Video Diffusion genera videos cortos a partir de imágenes estáticas. Requiere GPU con al menos 8GB VRAM.

## Requisitos

- GPU NVIDIA con **mínimo 8GB VRAM**
- ~8GB espacio en disco para el modelo
- Docker con soporte GPU

## Instalación

### Paso 1: Ejecutar Script de Configuración

```powershell
cd C:\code\moltbot
.\scripts\setup-stable-video.ps1
```

Este script:
- Crea el contenedor `stable-video` en el puerto 8000
- Configura GPU NVIDIA
- Instala dependencias básicas
- Configura firewall
- Crea API REST básica

### Paso 2: Verificar Instalación

```powershell
# Verificar que el contenedor está corriendo
docker ps | findstr stable-video

# Probar API
curl http://localhost:8000/health
```

## Nota Importante

El script crea un endpoint API básico. Para usar Stable Video Diffusion completamente, necesitas:

1. **Descargar el modelo** (~8GB) desde Hugging Face
2. **Configurar el pipeline** de generación
3. **Integrar con la API**

### Implementación Completa (Opcional)

Para una implementación completa, necesitarías:

```python
# Ejemplo de integración completa (requiere modelo descargado)
from diffusers import StableVideoDiffusionPipeline
import torch

pipe = StableVideoDiffusionPipeline.from_pretrained(
    "stabilityai/stable-video-diffusion-img2vid",
    torch_dtype=torch.float16,
    variant="fp16"
)
pipe = pipe.to("cuda")
```

## Uso

### Desde API

```powershell
# Subir imagen y generar video
curl -X POST http://localhost:8000/api/generate `
  -F "file=@imagen.png" `
  -F "duration=5" `
  -F "fps=24" `
  --output video.mp4
```

### Desde Open WebUI

Después de configurar Open WebUI extendido, puedes usar la extensión multimedia para generar videos desde la interfaz.

## Solución de Problemas

### Error: "Model not found"
- **Solución**: El modelo debe descargarse manualmente desde Hugging Face y colocarse en el directorio de modelos

### Error: "Out of memory"
- **Solución**: 
  - Cierra otros servicios que usen GPU
  - Reduce la duración del video
  - Reduce la resolución

### API retorna "Implementation pending"
- **Normal**: El endpoint básico está configurado pero requiere la implementación completa del pipeline

## Recursos

- **Puerto**: 8000
- **API Base**: `http://localhost:8000`
- **Documentación**: https://github.com/Stability-AI/generative-models
- **Modelo Hugging Face**: https://huggingface.co/stabilityai/stable-video-diffusion-img2vid

## Próximos Pasos

Para una implementación completa:
1. Descargar modelo desde Hugging Face
2. Integrar pipeline en `stable_video_api.py`
3. Probar generación de video
4. Optimizar para producción












