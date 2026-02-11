# Guía de Implementación Completa: Flux, Stable Video, Coqui TTS + IA de Programación

## Resumen

Esta guía te ayudará a implementar un ecosistema completo de IA local que incluye:
- **IA de Programación**: DeepSeek-Coder, WizardCoder, CodeLlama
- **Generación de Imágenes**: Flux (vía Ollama)
- **Generación Avanzada de Imágenes**: ComfyUI
- **Generación de Video**: Stable Video Diffusion
- **Síntesis de Voz**: Coqui TTS
- **Interfaz Unificada**: Open WebUI extendido

## Requisitos Previos

- Windows 10/11 con Docker Desktop instalado
- GPU NVIDIA con al menos 16GB VRAM (RTX 5070 compatible)
- ~150GB espacio en disco disponible
- ~32GB RAM recomendado
- PowerShell con permisos de Administrador

## Orden de Implementación

### Fase 1: IA de Programación

```powershell
cd C:\code\moltbot

# 1. Configurar Ollama-Code
.\scripts\setup-coder-llm.ps1

# 2. Descargar modelos (esto tarda 30-60 min por modelo)
docker exec ollama-code ollama pull deepseek-coder:33b
docker exec ollama-code ollama pull wizardcoder:34b
docker exec ollama-code ollama pull codellama:34b

# 3. Verificar
docker exec ollama-code ollama list
curl http://localhost:11438/api/tags
```

**Documentación completa**: Ver `IMPLEMENTAR_IA_PROGRAMACION.md`

### Fase 2: Flux (Generación de Imágenes)

```powershell
# 1. Configurar Ollama-Flux
.\scripts\setup-flux.ps1

# 2. Descargar modelo Flux (tarda 30-60 min)
docker exec ollama-flux ollama pull flux

# 3. Verificar
docker exec ollama-flux ollama list
curl http://localhost:11439/api/tags
```

**Documentación completa**: Ver `IMPLEMENTAR_FLUX.md`

### Fase 3: Coqui TTS (Síntesis de Voz)

```powershell
# 1. Configurar Coqui TTS
.\scripts\setup-coqui-tts.ps1

# 2. Esperar a que los modelos se descarguen automáticamente (5-10 min)
# 3. Verificar
curl http://localhost:5002/health
curl http://localhost:5002/api/models
```

**Documentación completa**: Ver `IMPLEMENTAR_COQUI_TTS.md`

### Fase 4: ComfyUI (Generación Avanzada de Imágenes)

```powershell
# 1. Configurar ComfyUI
.\scripts\setup-comfyui.ps1

# 2. Abrir en navegador
# http://localhost:7860

# Los modelos se descargan automáticamente al usar
```

### Fase 5: Stable Video Diffusion

```powershell
# 1. Configurar Stable Video
.\scripts\setup-stable-video.ps1

# 2. Verificar
curl http://localhost:8000/health

# Nota: Requiere implementación adicional del pipeline completo
```

**Documentación completa**: Ver `IMPLEMENTAR_STABLE_VIDEO.md`

### Fase 6: Integración en Open WebUI

```powershell
# 1. Configurar firewall para todos los servicios
.\scripts\configurar-firewall-extendido.ps1

# 2. Configurar Open WebUI extendido
.\scripts\configure-open-webui-extended.ps1

# 3. Verificar todos los servicios
.\scripts\verificar-servicios-extendidos.ps1
```

## Uso Rápido con Docker Compose

Alternativamente, puedes usar Docker Compose para levantar todos los servicios:

```powershell
# Levantar todos los servicios
docker-compose -f docker-compose-extended.yml up -d

# Ver estado
docker-compose -f docker-compose-extended.yml ps

# Ver logs
docker-compose -f docker-compose-extended.yml logs -f

# Detener todos
docker-compose -f docker-compose-extended.yml down
```

## Acceso a los Servicios

| Servicio | Puerto | URL | Descripción |
|----------|--------|-----|-------------|
| Open WebUI | 8082 | http://localhost:8082 | Interfaz web unificada |
| Ollama-Mistral | 11436 | http://localhost:11436 | LLM General |
| Ollama-Qwen | 11437 | http://localhost:11437 | LLM Alternativo |
| Ollama-Code | 11438 | http://localhost:11438 | IA de Programación |
| Ollama-Flux | 11439 | http://localhost:11439 | Generación de Imágenes |
| ComfyUI | 7860 | http://localhost:7860 | Generación Avanzada |
| Stable Video | 8000 | http://localhost:8000 | Generación de Video |
| Coqui TTS | 5002 | http://localhost:5002 | Síntesis de Voz |

## Uso desde Open WebUI

1. Abre `http://localhost:8082` en tu navegador
2. Crea una cuenta (primera vez)
3. Selecciona el modelo deseado:
   - **Chat General**: Mistral, Qwen
   - **Programación**: DeepSeek-Coder, WizardCoder, CodeLlama
   - **Imágenes**: Flux
4. Usa los botones multimedia (si están implementados en la extensión)

## Descarga Rápida de Modelos

Para descargar todos los modelos de una vez:

```powershell
.\scripts\download-models.ps1
```

Este script descarga:
- Modelos de programación en ollama-code
- Flux en ollama-flux

## Verificación del Sistema

Para verificar que todo está funcionando:

```powershell
.\scripts\verificar-servicios-extendidos.ps1
```

Este script verifica:
- Estado de todos los contenedores
- Conectividad de las APIs
- Uso de GPU

## Solución de Problemas

### Error: "Port already in use"
- **Solución**: Detén el servicio que está usando el puerto o cambia el puerto en el script

### Error: "Out of memory"
- **Solución**: 
  - Cierra otros servicios que usen GPU
  - No ejecutes todos los servicios simultáneamente
  - Usa modelos más pequeños

### Error: "Model not found"
- **Solución**: Verifica que el modelo se descargó:
  ```powershell
  docker exec ollama-code ollama list
  docker exec ollama-flux ollama list
  ```

### Error: "Firewall blocking"
- **Solución**: Ejecuta como Administrador:
  ```powershell
  .\scripts\configurar-firewall-extendido.ps1
  ```

## Recursos Adicionales

- **Documentación IA Programación**: `IMPLEMENTAR_IA_PROGRAMACION.md`
- **Documentación Flux**: `IMPLEMENTAR_FLUX.md`
- **Documentación Stable Video**: `IMPLEMENTAR_STABLE_VIDEO.md`
- **Documentación Coqui TTS**: `IMPLEMENTAR_COQUI_TTS.md`

## Próximos Pasos

1. **Personalizar extensiones**: Edita los archivos en `extensions/open-webui-multimedia/` para ajustar la integración
2. **Agregar más modelos**: Descarga modelos adicionales según tus necesidades
3. **Optimizar rendimiento**: Ajusta la configuración de GPU según tu hardware
4. **Integrar con Moltbot**: Configura Moltbot en la VM para usar estos servicios

## Notas Importantes

- **Recursos**: No ejecutes todos los servicios simultáneamente si tienes limitaciones de VRAM
- **Almacenamiento**: Los modelos ocupan mucho espacio, planifica tu almacenamiento
- **Tiempo de descarga**: Los modelos grandes tardan 30-60 minutos en descargarse
- **Primera ejecución**: La primera vez que uses cada servicio, puede tardar más (descarga de modelos)












