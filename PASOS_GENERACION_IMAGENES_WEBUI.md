# Guía paso a paso: generación de imágenes en Open WebUI (ComfyUI + Flux)

Sigue estos pasos en orden.

---

## Paso 1: Comprobar que los servicios estén en marcha

En PowerShell, desde la carpeta del proyecto (`c:\code\moltbot`):

```powershell
.\scripts\verificar-comfyui-webui.ps1
```

- Debe salir **[OK]** en ComfyUI y en las variables de Open WebUI.
- Si Open WebUI no tiene `IMAGE_GENERATION_ENGINE=comfyui`, recrea el contenedor:
  ```powershell
  docker compose -f docker-compose-extended.yml up -d --no-deps open-webui --force-recreate
  ```
  Espera ~15 segundos y vuelve a ejecutar el script de verificación.

---

## Paso 2: Tener un checkpoint en ComfyUI

Para generar imágenes, ComfyUI necesita un modelo (checkpoint). Si aún no tienes ninguno:

1. **Descarga un checkpoint de Flux** (por ejemplo):
   - [FLUX.1 schnell](https://huggingface.co/black-forest-labs/FLUX.1-schnell) → archivo `flux1-schnell.safetensors`
   - O [FLUX.1 dev](https://huggingface.co/black-forest-labs/FLUX.1-dev) → `flux1-dev.safetensors`

2. **Colócalo donde ComfyUI lee los checkpoints:**
   - **En este proyecto** el volumen de modelos está mapeado así (en `docker-compose-extended.yml`):
     - **En tu PC (host):**  
       **`%USERPROFILE%\comfyui-models`**  
       Ejemplo: `C:\Users\TuUsuario\comfyui-models`
     - Los checkpoints deben ir en la subcarpeta **`checkpoints`**, es decir:  
       **`%USERPROFILE%\comfyui-models\checkpoints`**  
       Ejemplo: `C:\Users\TuUsuario\comfyui-models\checkpoints\flux1-schnell.safetensors`
   - Crea la carpeta si no existe y copia ahí el archivo `.safetensors` (p. ej. `flux1-schnell.safetensors`).
   - Usa el script para descargar: `.\scripts\descargar-modelo-comfyui.ps1 -Model 1` (SD 1.5), `-Model 2` (SDXL). Flux se descarga manualmente desde HuggingFace.

3. **Opcional:** comprueba que ComfyUI ve el modelo:
   ```powershell
   (Invoke-RestMethod -Uri "http://localhost:7860/object_info/CheckpointLoaderSimple").CheckpointLoaderSimple.input.required.ckpt_name[0]
   ```
   Debería aparecer el nombre de tu archivo (ej. `flux1-schnell.safetensors`).

**Anota el nombre exacto del archivo** (con extensión). Lo usarás en el Paso 4.

---

## Paso 3: Abrir la configuración de imágenes en Open WebUI

1. Abre el navegador en: **http://localhost:8082**
2. Inicia sesión si hace falta.
3. Ve a **Admin Panel** (icono de engranaje o menú de administración).
4. Entra en **Settings** y luego en la pestaña **Images** (Imágenes).

---

## Paso 4: Completar la configuración de ComfyUI

En **Settings > Images**:

| Campo | Valor |
|--------|--------|
| **Image Generation Engine** | **ComfyUI** |
| **API URL** | `http://comfyui:8188/` |
| **Model** | El nombre exacto de tu checkpoint, por ejemplo: `v1-5-pruned-emaonly.safetensors` |

- Si en el Paso 2 viste el nombre en la lista de ComfyUI, usa ese.
- Si aún no tienes checkpoints, escribe igual el nombre que vas a usar (ej. `flux1-schnell.safetensors`), guarda y añade el archivo después.

Activa **Image Generation (Experimental)** (toggle en ON).

---

## Paso 5: Subir el workflow

En la misma pantalla **Images**:

1. Busca la opción **“Click here to upload a workflow.json file”** (o similar).
2. Elige el archivo según el modelo:
   - **SD 1.5**: `workflow_api_sd15.json` (512→1024 con upscale)
   - **SDXL**: `workflow_api_sdxl.json` (1024 nativo, mejor calidad)
   - **Flux Schnell**: `workflow_api_flux.json` (1024, rápida)
3. Sube el archivo.

Si la interfaz pide **mapear nodos**:
- **Prompt** → nodo **2** (text)
- **Dimensiones** (width/height) → nodo **4**

---

## Paso 6: Guardar

Haz clic en **Save** (Guardar) en la parte inferior de la pantalla de configuración de Images.

---

## Paso 7: Probar la generación de imágenes

1. Vuelve al **chat** de Open WebUI (pestaña o inicio).
2. Activa o selecciona la opción de **generación de imágenes** si la interfaz lo muestra (icono de imagen o switch “Image Generation”).
3. Escribe un prompt, por ejemplo:  
   **“Un pato jugando paintball”**
4. Envía el mensaje.

La primera vez puede tardar más (ComfyUI carga el modelo). Si todo está bien, deberías ver la imagen generada en el chat.

---

## Si algo falla

- **“Necesitas completar el campo Model”**  
  → Vuelve al **Paso 4** y rellena **Model** con el nombre exacto del checkpoint (ej. `flux1-schnell.safetensors`).

- **Error de conexión con ComfyUI**  
  → ComfyUI no está accesible desde Open WebUI. Comprueba que ambos estén en la misma red Docker y que la **API URL** sea `http://comfyui:8188/`.

- **Error de checkpoint o “node_errors”**  
  → El nombre en **Model** no coincide con ningún archivo en la carpeta de checkpoints de ComfyUI. Revisa el **Paso 2** y el nombre del archivo.

- **No se genera la imagen / timeout**  
  → La primera generación puede tardar 1–2 minutos. Si tienes poca VRAM, puede fallar; en ese caso prueba con un checkpoint más pequeño o ajusta recursos del contenedor.

- **405 Method Not Allowed en `/api/v1/multimedia/image/generate`**  
  → Ese endpoint pertenece a la extensión multimedia, que **no está montada** por defecto en Open WebUI. La interfaz usa el endpoint nativo `POST /api/v1/images/generations`. Ver "Probar la API directamente" abajo.

---

## Probar la API directamente

Open WebUI expone el endpoint nativo `POST /api/v1/images/generations`. Requiere **autenticación** (cookie de sesión o Bearer token).

**PowerShell** (con sesión iniciada en el navegador en localhost:8082, copia las cookies o usa un token):

```powershell
# Opción 1: Usando el body JSON (el endpoint espera JSON, no query params)
$body = @{
    prompt = "un gato"
    model  = "flux1-schnell.safetensors"  # o tu checkpoint configurado en Settings > Images
} | ConvertTo-Json

# Necesitas incluir la cookie de sesión o un API key en el header Authorization
Invoke-WebRequest -Uri "http://localhost:8082/api/v1/images/generations" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body `
    -TimeoutSec 300 `
    -UseBasicParsing
```

Si no tienes token/cookie, la llamada devolverá 401. Obtén un token en Admin Panel > Settings > API Keys, o usa las DevTools del navegador (Application > Cookies) para copiar la cookie de sesión.

---

## Resumen rápido

1. Ejecutar `.\scripts\verificar-comfyui-webui.ps1` y corregir lo que falle.
2. Tener un checkpoint (ej. `v1-5-pruned-emaonly.safetensors`) en la carpeta de checkpoints de ComfyUI.
3. Admin Panel > Settings > Images: Engine = ComfyUI, API URL = `http://comfyui:8188/`, **Model** = nombre del checkpoint.
4. Activar Image Generation (Experimental) y subir `workflow_api_sd15.json` (o `workflow_api_flux.json` si usas Flux).
5. Si ves "Backend not running or misconfigured", ver **SOLUCION_BACKEND_NOT_RUNNING.md**.
6. Guardar y probar en el chat con un prompt de imagen.

Documentación detallada: **CONFIGURAR_FLUX_COMFYUI_WEBUI.md**

