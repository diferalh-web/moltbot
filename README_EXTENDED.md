# Ecosistema de IA Extendido - Moltbot

Ecosistema completo de IA local que incluye modelos de lenguaje, generación de imágenes, video y síntesis de voz, todo integrado en una interfaz web unificada.

## Características

- **IA de Programación**: DeepSeek-Coder, WizardCoder, CodeLlama
- **Generación de Imágenes**: Flux (vía Ollama)
- **Generación Avanzada**: ComfyUI
- **Generación de Video**: Stable Video Diffusion
- **Síntesis de Voz**: Coqui TTS
- **Interfaz Unificada**: Open WebUI

## Inicio Rápido

### Opción 1: Script Automático (Recomendado)

```powershell
cd C:\code\moltbot
.\scripts\implementar-todo.ps1
```

### Opción 2: Scripts Individuales

```powershell
# 1. IA de Programación
.\scripts\setup-coder-llm.ps1

# 2. Flux
.\scripts\setup-flux.ps1

# 3. Coqui TTS
.\scripts\setup-coqui-tts.ps1

# 4. ComfyUI
.\scripts\setup-comfyui.ps1

# 5. Stable Video
.\scripts\setup-stable-video.ps1

# 6. Firewall
.\scripts\configurar-firewall-extendido.ps1

# 7. Open WebUI Extendido
.\scripts\configure-open-webui-extended.ps1
```

### Opción 3: Docker Compose

```powershell
docker-compose -f docker-compose-extended.yml up -d
```

## Descargar Modelos

```powershell
.\scripts\download-models.ps1
```

## Verificar Sistema

```powershell
.\scripts\verificar-servicios-extendidos.ps1
```

## Acceso

- **Open WebUI**: http://localhost:8082
- **ComfyUI**: http://localhost:7860

## Documentación

- **Guía Completa**: `GUIA_IMPLEMENTACION_COMPLETA.md`
- **IA Programación**: `IMPLEMENTAR_IA_PROGRAMACION.md`
- **Flux**: `IMPLEMENTAR_FLUX.md`
- **Stable Video**: `IMPLEMENTAR_STABLE_VIDEO.md`
- **Coqui TTS**: `IMPLEMENTAR_COQUI_TTS.md`

## Requisitos

- Windows 10/11
- Docker Desktop
- GPU NVIDIA con 16GB+ VRAM
- ~150GB espacio en disco
- ~32GB RAM

## Arquitectura

```
Open WebUI (8082)
├── Ollama-Mistral (11436) - LLM General
├── Ollama-Qwen (11437) - LLM Alternativo
├── Ollama-Code (11438) - IA Programación
├── Ollama-Flux (11439) - Imágenes
├── ComfyUI (7860) - Imágenes Avanzadas
├── Stable Video (8000) - Video
└── Coqui TTS (5002) - Voz
```












