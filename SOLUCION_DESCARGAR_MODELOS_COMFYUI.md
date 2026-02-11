# 🔧 Solución: No Aparecen Modelos en ComfyUI

## ❌ Problema

El campo `ckpt_name` en "Load Checkpoint" no muestra ningún dropdown con modelos disponibles.

## 🔍 Causas Posibles

1. **No hay modelos descargados** (más común)
2. **Los modelos están en otra ubicación**
3. **ComfyUI aún no ha escaneado los modelos**

## ✅ Soluciones

### Solución 1: Descargar un Modelo Manualmente (Recomendado)

#### Opción A: Usar el Nodo Load Checkpoint con URL

1. **Haz doble clic** en el nodo "Load Checkpoint"
2. En el campo `ckpt_name`, **escribe directamente** el nombre del modelo
3. ComfyUI lo descargará automáticamente la primera vez

**Modelos recomendados para empezar:**

```
sd_xl_base_1.0.safetensors
```

O escribe la URL completa de Hugging Face:

```
https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
```

#### Opción B: Descargar Manualmente desde PowerShell

```powershell
# Crear directorio si no existe
New-Item -ItemType Directory -Force -Path "${env:USERPROFILE}\comfyui-models\checkpoints" | Out-Null

# Descargar Stable Diffusion 1.5 (más pequeño, ~4GB)
Invoke-WebRequest -Uri "https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors" -OutFile "${env:USERPROFILE}\comfyui-models\checkpoints\v1-5-pruned-emaonly.safetensors"
```

**Nota:** Esto descargará ~4GB. Puede tardar varios minutos.

### Solución 2: Usar el Nodo "Load Checkpoint" con Ruta Completa

1. **Descarga un modelo** desde:
   - **Hugging Face**: https://huggingface.co/models?pipeline_tag=text-to-image
   - **Civitai**: https://civitai.com/
2. **Guarda el archivo** en: `C:\Users\TU_USUARIO\comfyui-models\checkpoints\`
3. **Reinicia ComfyUI**:
   ```powershell
   docker restart comfyui
   ```
4. **Espera 2-3 minutos** y recarga la página
5. El modelo debería aparecer en el dropdown

### Solución 3: Usar Modelos Pre-descargados

Si ya tienes modelos de Stable Diffusion en otra ubicación:

1. **Copia los archivos** a: `C:\Users\TU_USUARIO\comfyui-models\checkpoints\`
2. **Reinicia ComfyUI**
3. Los modelos aparecerán en el dropdown

### Solución 4: Escribir el Nombre del Modelo Directamente

Puedes escribir el nombre del modelo directamente en el campo:

1. **Haz doble clic** en "Load Checkpoint"
2. En `ckpt_name`, escribe: `v1-5-pruned-emaonly.safetensors`
3. ComfyUI intentará descargarlo automáticamente

## 📥 Modelos Recomendados para Empezar

### Modelos Pequeños (4-6 GB)

1. **Stable Diffusion 1.5**
   - Nombre: `v1-5-pruned-emaonly.safetensors`
   - URL: https://huggingface.co/runwayml/stable-diffusion-v1-5
   - Tamaño: ~4GB

2. **Stable Diffusion 1.4**
   - Nombre: `sd-v1-4.ckpt`
   - URL: https://huggingface.co/CompVis/stable-diffusion-v1-4
   - Tamaño: ~4GB

### Modelos Medianos (6-10 GB)

1. **Stable Diffusion XL Base**
   - Nombre: `sd_xl_base_1.0.safetensors`
   - URL: https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0
   - Tamaño: ~7GB

## 🚀 Solución Rápida: Script de Descarga

He creado un script para descargar un modelo automáticamente:

```powershell
# Ejecuta esto en PowerShell
$modelDir = "${env:USERPROFILE}\comfyui-models\checkpoints"
New-Item -ItemType Directory -Force -Path $modelDir | Out-Null

Write-Host "Descargando Stable Diffusion 1.5..." -ForegroundColor Yellow
Write-Host "Esto puede tardar varios minutos (archivo de ~4GB)" -ForegroundColor Gray

Invoke-WebRequest -Uri "https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors" -OutFile "$modelDir\v1-5-pruned-emaonly.safetensors" -UseBasicParsing

Write-Host "`nModelo descargado!" -ForegroundColor Green
Write-Host "Reinicia ComfyUI: docker restart comfyui" -ForegroundColor Yellow
Write-Host "Espera 2-3 minutos y recarga la pagina" -ForegroundColor Yellow
```

## 🔄 Después de Descargar

1. **Reinicia ComfyUI**:
   ```powershell
   docker restart comfyui
   ```

2. **Espera 2-3 minutos** para que ComfyUI escanee los modelos

3. **Recarga la página** (F5)

4. **Haz doble clic** en "Load Checkpoint"

5. El dropdown debería mostrar el modelo descargado

## 📝 Verificar Ubicación de Modelos

Los modelos deben estar en:
```
C:\Users\TU_USUARIO\comfyui-models\checkpoints\
```

Dentro del contenedor se montan en:
```
/root/.cache/huggingface/
```

## 🐛 Si Aún No Aparecen

1. **Verifica que el archivo esté en la ubicación correcta**
2. **Revisa los logs de ComfyUI**:
   ```powershell
   docker logs comfyui | Select-String "model|checkpoint"
   ```
3. **Espera más tiempo** - ComfyUI puede tardar en escanear modelos grandes
4. **Reinicia el contenedor** y espera 3-5 minutos

---

**Recomendación:** Descarga Stable Diffusion 1.5 primero (más pequeño y rápido). Una vez que funcione, puedes descargar modelos más grandes si lo necesitas.









