# Implementar Flux (Generación de Imágenes)

## Descripción

Flux es un modelo de generación de imágenes de alta calidad disponible en Ollama. Requiere GPU con al menos 16GB VRAM.

## Requisitos

- GPU NVIDIA con **mínimo 16GB VRAM** (RTX 5070 tiene 16GB, compatible)
- ~12GB espacio en disco para el modelo
- Docker con soporte GPU

## Instalación

### Paso 1: Ejecutar Script de Configuración

```powershell
cd C:\code\moltbot
.\scripts\setup-flux.ps1
```

Este script:
- Crea el contenedor `ollama-flux` en el puerto 11439
- Configura GPU NVIDIA
- Configura firewall
- Verifica el estado

### Paso 2: Descargar Modelo Flux

```powershell
# Descargar Flux (esto puede tardar 30-60 minutos)
docker exec ollama-flux ollama pull flux
```

**Nota**: El modelo Flux es grande (~12GB) y tarda en descargarse.

### Paso 3: Verificar Instalación

```powershell
# Ver modelo instalado
docker exec ollama-flux ollama list

# Probar API
curl http://localhost:11439/api/tags
```

## Uso

### Desde Open WebUI

1. Abre `http://localhost:8082`
2. En el selector de modelo, busca `flux`
3. Escribe un prompt descriptivo de la imagen que quieres generar
4. La imagen se generará y mostrará en la interfaz

### Ejemplos de Prompts

```
Un paisaje futurista con montañas y un sol rojo en el horizonte, estilo ciencia ficción
```

```
Un gato sentado en una biblioteca antigua, iluminación dramática, estilo cinematográfico
```

```
Diseño de logo moderno para una empresa de tecnología, minimalista, colores azul y blanco
```

### Desde API Directa

```powershell
curl http://localhost:11439/api/generate -d '{
  "model": "flux",
  "prompt": "a beautiful sunset over mountains",
  "stream": false
}'
```

## Integración con ComfyUI

Para generación avanzada de imágenes, también puedes usar ComfyUI (puerto 7860) que ofrece más control sobre el proceso de generación.

## Solución de Problemas

### Error: "Out of memory" o "CUDA out of memory"
- **Causa**: No hay suficiente VRAM disponible
- **Solución**: 
  - Cierra otros servicios que usen GPU
  - Usa un modelo más pequeño si está disponible
  - Reduce la resolución de la imagen

### Error: "Model not found"
- **Solución**: Verifica que Flux se descargó:
  ```powershell
  docker exec ollama-flux ollama list
  ```

### Generación muy lenta
- **Normal**: Flux puede tardar 30-120 segundos por imagen
- **Optimización**: Asegúrate de que la GPU está siendo usada:
  ```powershell
  nvidia-smi
  ```

## Recursos

- **Puerto**: 11439
- **API Base**: `http://localhost:11439`
- **Documentación Flux**: https://github.com/black-forest-labs/flux
- **Ollama Flux**: https://ollama.ai/library/flux












