# Modelos configurados en el proyecto Moltbot

Resumen de los **modelos y servicios locales en Docker** que tienes en este proyecto. **No se usa OpenAI** para chat ni para imágenes cuando se configura correctamente.

---

## Servicios Ollama (LLM y chat)

| Servicio        | Contenedor     | Puerto | Uso principal        | Modelos típicos                    |
|-----------------|----------------|--------|------------------------|------------------------------------|
| **Ollama Mistral** | `ollama-mistral` | **11436** | Chat general           | `mistral:latest`                   |
| **Ollama Qwen**   | `ollama-qwen`   | **11437** | Chat alternativo       | `qwen2.5:7b`                        |
| **Ollama Code**   | `ollama-code`   | **11438** | IA de programación     | `codellama:34b`, `deepseek-coder:33b` |
| **Ollama Flux**   | `ollama-flux`   | **11439** | Generación de imágenes | `flux` (si está en Ollama; ver nota abajo) |

Los modelos se descargan en cada contenedor con `docker exec <contenedor> ollama pull <modelo>`.

---

## Servicios de imágenes (modelos locales, sin OpenAI)

| Servicio   | Contenedor | Puerto (host) | Uso                          |
|-----------|------------|----------------|------------------------------|
| **ComfyUI** | `comfyui`  | **7860** (interno 8188) | Generación de imágenes (Flux, Stable Diffusion, etc.) |
| **Ollama Flux** | `ollama-flux` | **11439** | Generación de imágenes vía modelo Flux en Ollama |

- **ComfyUI**: ya está en `docker-compose-extended.yml`; Open WebUI puede usarlo con `IMAGE_GENERATION_API_URL=http://comfyui:8188`.
- **Ollama Flux**: la extensión multimedia usa `FLUX_API_URL=http://ollama-flux:11434` para generar imágenes con Flux si el modelo está disponible en ese Ollama.

---

## Otros servicios en Docker

| Servicio        | Contenedor     | Puerto | Uso                |
|-----------------|----------------|--------|--------------------|
| **Stable Video** | `stable-video` | 8000   | Video a partir de imagen |
| **Coqui TTS**   | `coqui-tts`    | 5002   | Texto a voz        |
| **Web Search**  | `web-search`   | 5003   | Búsqueda web (DuckDuckGo/Tavily) |
| **Open WebUI**  | `open-webui`   | **8082** | Interfaz web (chat + imágenes) |

---

## Proxy Ollama (opcional)

- **ollama-proxy**: puerto **11440**. No está en `docker-compose-extended.yml`; se crea con `scripts/setup-ollama-proxy.ps1`.
- Agrega en una sola URL todos los modelos de los 4 Ollama (Mistral, Qwen, Code, Flux).
- En `docker-compose-extended.yml`, Open WebUI usa `OLLAMA_BASE_URL=http://ollama-proxy:11440`; si no ejecutas el proxy, esa URL no funcionará y hay que usar por ejemplo `OLLAMA_BASE_URL=http://ollama-mistral:11434` (o el que corresponda).

---

## Variables de Open WebUI para usar modelos locales

En `docker-compose-extended.yml`, Open WebUI tiene:

- `OLLAMA_BASE_URL=http://ollama-proxy:11440` → chat (requiere proxy) o cambiar a un Ollama concreto.
- `ENABLE_IMAGE_GENERATION=true`
- `IMAGE_GENERATION_API_URL=http://comfyui:8188` → **imágenes con ComfyUI (local)**.
- `FLUX_API_URL=http://ollama-flux:11434` → **imágenes con Flux en Ollama (local)**.

Para que la WebUI use **solo modelos locales** (sin OpenAI):

1. No configurar API key de OpenAI en la interfaz.
2. En **Admin Panel → Settings → Images** (si existe), poner motor **ComfyUI** y URL `http://comfyui:8188` (o la URL que use tu compose).
3. Asegurarse de que la extensión multimedia use `IMAGE_GENERATION_API_URL` y `FLUX_API_URL` (ya definidas en el compose).

---

## Nota sobre Flux

En `SOLUCION_FLUX_NO_DISPONIBLE.md` se indica que **Flux no es un modelo oficial de Ollama**. Si en `ollama-flux` no tienes un modelo de imagen, la generación por Flux en la WebUI puede fallar. En ese caso, la opción de imágenes local es **ComfyUI** (puerto 7860/8188), que sí está pensado para Flux y Stable Diffusion.

---

## Resumen rápido

- **Chat**: Ollama local (Mistral 11436, Qwen 11437, Code 11438; opcional proxy 11440).
- **Imágenes**: ComfyUI (`comfyui:8188`) y, si está disponible, Ollama Flux (`ollama-flux:11434`).
- **Interfaz**: Open WebUI en **http://localhost:8082**.

Todo lo anterior son **modelos y servicios locales en Docker**; no se usa OpenAI para ninguno de estos flujos cuando la configuración apunta a estos servicios.
