# Configurar Flux en Open WebUI vía ComfyUI (Opción B)

La generación de imágenes en la WebUI puede usar **ComfyUI** con un workflow Flux/text-to-image. La extensión construye el workflow, lo envía a la API de ComfyUI y devuelve la imagen.

## Validar y configurar

1. **Comprobar servicios y variables**
   ```powershell
   .\scripts\verificar-comfyui-webui.ps1
   ```
   Verifica que ComfyUI esté en marcha, que Open WebUI tenga `ENABLE_IMAGE_GENERATION=true`, `IMAGE_GENERATION_ENGINE=comfyui` y `COMFYUI_BASE_URL`, y muestra los pasos para Admin > Settings > Images.

2. **Variables en Docker** (ya en `docker-compose-extended.yml`)
   - `ENABLE_IMAGE_GENERATION=true`
   - `IMAGE_GENERATION_ENGINE=comfyui` (para no usar OpenAI)
   - `COMFYUI_BASE_URL=http://comfyui:8188`
   - `IMAGE_GENERATION_API_URL=http://comfyui:8188`
   - `COMFYUI_CHECKPOINT_NAME` (opcional; por defecto `flux1-schnell.safetensors`)

   **Si ya tenías los contenedores levantados**, recrea `open-webui` para que cargue las nuevas variables:
   ```bash
   docker compose -f docker-compose-extended.yml up -d open-webui --force-recreate
   ```
   Luego vuelve a ejecutar `.\scripts\verificar-comfyui-webui.ps1` para confirmar.

3. **En Open WebUI (Admin > Settings > Images)**
   - **Image Generation Engine**: ComfyUI
   - **API URL**: `http://comfyui:8188/` (si Open WebUI y ComfyUI están en la misma red Docker)
   - **Model** (obligatorio): nombre exacto del archivo del checkpoint que tienes en ComfyUI. Ejemplos:
     - `flux1-schnell.safetensors`
     - `flux1-dev.safetensors`
     - O el que aparezca en la lista (ver abajo "Campo Model").
   - Activar **Image Generation (Experimental)**.
   - Subir el workflow: `extensions/open-webui-multimedia/workflow_api_flux.json` (Click here to upload a workflow.json file).
   - Mapear nodos si lo pide la UI: prompt → nodo 2 (text), dimensiones → nodo 4.

4. **ComfyUI**
   - Debe estar en ejecución (contenedor `comfyui`, puerto 8188 interno / 7860 en host).
   - Checkpoint de Flux (u otro compatible) en la carpeta de checkpoints; el nombre debe coincidir con `COMFYUI_CHECKPOINT_NAME` o con el "Set Default Model" en la WebUI.

## Qué se implementó

1. **Módulo `comfyui_workflow.py`**  
   - Construye un workflow JSON para ComfyUI (CheckpointLoaderSimple → CLIPTextEncode → EmptyLatentImage → KSampler → VAEDecode → SaveImage).  
   - Envía `POST /prompt`, espera el resultado con `GET /history/{prompt_id}` y obtiene la imagen con `GET /view`.

2. **`image_generator.py`**  
   - Cuando se usa ComfyUI, llama a `generate_image_via_comfyui()` en lugar del endpoint inventado `/api/v1/generate`.

3. **`router.py`**  
   - Para `model=comfyui`, usa el mismo flujo y devuelve la imagen como stream.

## Configuración

### 1. ComfyUI y checkpoint

- ComfyUI debe estar levantado (por ejemplo contenedor `comfyui` con puerto 8188).
- Necesitas un **checkpoint** en la carpeta que ComfyUI usa. **Dónde los lee ComfyUI en este proyecto:**
  - **En tu PC:** **`%USERPROFILE%\comfyui-models\checkpoints`**  
    Ejemplo: `C:\Users\TuUsuario\comfyui-models\checkpoints`
  - Ahí debes poner los archivos `.safetensors` (p. ej. `flux2_dev_fp8mixed.safetensors`). El compose monta esta carpeta en **`/root/ComfyUI/models/checkpoints`** dentro del contenedor, que es lo que usa la "Model Library" de ComfyUI.
  - Si tus archivos estaban en otra ruta, **cópialos** a `comfyui-models\checkpoints`. Luego **recrea el contenedor** ComfyUI para que monte el volumen y los vea.

### 2. Variable de entorno del checkpoint

- **Nombre del archivo** del checkpoint (el que aparece en ComfyUI en el nodo “Load Checkpoint”).
- Por defecto: `flux1-schnell.safetensors`.
- Para cambiarlo:
  - En **Docker**: en el servicio `open-webui` de `docker-compose-extended.yml` está:
    - `COMFYUI_CHECKPOINT_NAME=${COMFYUI_CHECKPOINT_NAME:-flux1-schnell.safetensors}`
  - Puedes definir en tu `.env`:  
    `COMFYUI_CHECKPOINT_NAME=flux1-dev.safetensors`  
    (o el nombre exacto de tu archivo).

### 3. Open WebUI

- `IMAGE_GENERATION_API_URL` debe apuntar a ComfyUI (ej. `http://comfyui:8188`), ya configurado en el compose.
- En la interfaz, si hay opción de “motor de imágenes”, elige **ComfyUI** (no OpenAI) para que las peticiones de imagen usen este flujo.

## Uso en la WebUI

- Pide una imagen en el chat usando el modelo que tenga configurado generación por ComfyUI (o el que envíe a la API de multimedia con `model=comfyui`).
- La extensión enviará prompt, width, height y steps a ComfyUI con el workflow Flux/text-to-image y mostrará la imagen generada.

## Campo Model (obligatorio)

Open WebUI pide completar **Model** para ComfyUI. Ese valor debe ser el **nombre del archivo del checkpoint** tal como lo tiene ComfyUI en su carpeta de checkpoints (p. ej. `flux1-schnell.safetensors`).

**Ver qué modelos tienes en ComfyUI:**

```powershell
# Listar checkpoints disponibles (ComfyUI en localhost:7860)
(Invoke-RestMethod -Uri "http://localhost:7860/object_info/CheckpointLoaderSimple").CheckpointLoaderSimple.input.required.ckpt_name[0]
```

Copia uno de los nombres que salgan (por ejemplo `flux1-schnell.safetensors`) y pégalo en el campo **Model** en Admin > Settings > Images. Si no aparece ninguno, tienes que descargar un checkpoint (p. ej. Flux) y ponerlo en la carpeta de checkpoints de ComfyUI antes de usar la generación de imágenes.

**Valores típicos:** `flux1-schnell.safetensors`, `flux1-dev.safetensors`, o cualquier `.safetensors` que tengas en `models/checkpoints` de ComfyUI.

**Si ComfyUI no tiene aún checkpoints** (la lista sale vacía): escribe en **Model** el nombre del archivo que vas a usar, por ejemplo `flux1-schnell.safetensors`, guarda la configuración y luego descarga ese checkpoint y colócalo en la carpeta de checkpoints de ComfyUI para que la generación funcione.

## Si algo falla

- **“Error de conexión con ComfyUI”**: comprueba que el contenedor `comfyui` esté arriba y que `IMAGE_GENERATION_API_URL` sea accesible desde el contenedor de Open WebUI (misma red Docker).
- **Error de validación o “node_errors”**: el checkpoint por defecto puede no existir; ajusta `COMFYUI_CHECKPOINT_NAME` al nombre exacto del archivo en `models/checkpoints` de ComfyUI.
- **Timeout**: la primera generación puede tardar más (carga del modelo); el tiempo máximo de espera está en `comfyui_workflow.py` (`MAX_POLL_WAIT`).
