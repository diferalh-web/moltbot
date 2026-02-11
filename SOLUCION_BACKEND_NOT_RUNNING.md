# Solución: "Image Generation Failed: Backend not running or misconfigured"

Este mensaje aparece en Open WebUI cuando la generación de imágenes con ComfyUI no está bien configurada.

## Pasos para solucionarlo (en orden)

### 1. Configurar Settings > Images correctamente

1. Abre **http://localhost:8082**
2. Ve a **Admin Panel** → **Settings** → pestaña **Images**
3. Completa todo esto:
   - **Image Generation Engine**: ComfyUI
   - **API URL**: `http://comfyui:8188/` (con barra final)
   - **Model**: `v1-5-pruned-emaonly.safetensors` (o el nombre exacto de tu checkpoint)
   - **Image Generation (Experimental)**: activado (toggle ON)

### 2. Subir el workflow

- Haz clic en "Click here to upload a workflow.json file"
- Sube el archivo: `c:\code\moltbot\extensions\open-webui-multimedia\workflow_api_sd15.json`
- Si usas SD 1.5, ese es el workflow correcto. Si usas Flux, sube `workflow_api_flux.json` en su lugar.

### 3. Verificar red Docker

Open WebUI y ComfyUI deben estar en la misma red (`ai-network`). Si ComfyUI se creó con un script aparte (por ejemplo `recrear-comfyui-robusto.ps1`), puede estar en otra red. Ejecuta:

```powershell
docker network connect ai-network comfyui
```

### 4. Reiniciar Open WebUI

Para que cargue la configuración actualizada:

```powershell
cd c:\code\moltbot
docker compose -f docker-compose-unified.yml up -d --no-deps open-webui --force-recreate
```

### 5. Verificar conectividad

```powershell
.\scripts\verificar-arquitectura-completa.ps1
```

Debe mostrar **[OK]** en "Open WebUI puede alcanzar ComfyUI en la red Docker".

---

## Checklist rápido

- [ ] Model = `v1-5-pruned-emaonly.safetensors`
- [ ] API URL = `http://comfyui:8188/`
- [ ] Image Generation (Experimental) = ON
- [ ] Workflow subido
- [ ] ComfyUI y Open WebUI en ai-network
- [ ] Open WebUI reiniciado tras cambiar configuración
