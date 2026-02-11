# 🎬 Guía: Ejecutar LTX-2 en ComfyUI

LTX-2 es un modelo open source de Lightricks que genera video y audio sincronizados. Esta guía indica todo lo necesario para usarlo en tu ComfyUI.

---

## ✅ Requisitos previos

| Requisito | Tu setup |
|-----------|----------|
| **GPU** | RTX 5070 (12 GB VRAM) |
| **ComfyUI** | Corriendo (Docker o nativo) |
| **Espacio en disco** | ~80–100 GB libres |
| **RAM sistema** | 32 GB recomendado |

### Con 12 GB VRAM (RTX 5070)

- Resolución: **576p–720p** de forma estable
- Duración: **5–8 segundos**
- Modelo: usar **distilled FP8** para mejor rendimiento

---

## 📦 1. Instalación de ComfyUI-LTXVideo (Custom Node)

### Opción A: Script automático (recomendado)

```powershell
.\scripts\setup-ltx2-comfyui.ps1
```

### Opción B: ComfyUI Manager (si ya lo tenés)

1. Abrí ComfyUI: `http://localhost:7860`
2. Clic en **Manager** (o Ctrl+M)
3. **Install Custom Nodes** → buscar **"LTXVideo"**
4. Instalar **ComfyUI-LTXVideo**
5. Reiniciar ComfyUI: `docker restart comfyui`

### Opción C: Instalación manual

Si usás `recrear-comfyui-robusto.ps1` (ComfyUI en `comfyui-data`):

```powershell
$customNodes = "$env:USERPROFILE\comfyui-data\custom_nodes"
if (!(Test-Path $customNodes)) { New-Item -ItemType Directory -Force -Path $customNodes }
cd $customNodes
git clone https://github.com/Lightricks/ComfyUI-LTXVideo.git
```

---

## 📥 2. Modelos necesarios

### Obligatorios (para RTX 5070 / 12 GB)

| Modelo | Ubicación | Tamaño | Enlace |
|--------|-----------|--------|--------|
| **Checkpoint distilled FP8** | `checkpoints/` | ~10 GB | [ltx-2-19b-distilled-fp8.safetensors](https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-distilled-fp8.safetensors) |
| **Spatial Upscaler** | `latent_upscale_models/` | ~1 GB | [ltx-2-spatial-upscaler-x2-1.0.safetensors](https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-spatial-upscaler-x2-1.0.safetensors) |
| **Temporal Upscaler** | `latent_upscale_models/` | ~500 MB | [ltx-2-temporal-upscaler-x2-1.0.safetensors](https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-temporal-upscaler-x2-1.0.safetensors) |
| **Distilled LoRA** | `loras/` | ~400 MB | [ltx-2-19b-distilled-lora-384.safetensors](https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-distilled-lora-384.safetensors) |
| **Gemma Text Encoder** | `text_encoders/gemma-3-12b-it-qat-q4_0-unquantized/` | ~24 GB | [Google Gemma 3](https://huggingface.co/google/gemma-3-12b-it-qat-q4_0-unquantized) *Requiere aceptar licencia* |

### Dónde van los archivos

- **Si usás `recrear-comfyui-robusto.ps1`**: `%USERPROFILE%\comfyui-models\`
- **Si usás docker-compose**: mismo path

Rutas concretas:

```
%USERPROFILE%\comfyui-models\
├── checkpoints\
│   └── ltx-2-19b-distilled-fp8.safetensors
├── loras\
│   └── ltx-2-19b-distilled-lora-384.safetensors
├── latent_upscale_models\
│   ├── ltx-2-spatial-upscaler-x2-1.0.safetensors
│   └── ltx-2-temporal-upscaler-x2-1.0.safetensors
└── text_encoders\
    └── gemma-3-12b-it-qat-q4_0-unquantized\
        └── (archivos del repositorio Gemma)
```

### Gemma 3: acceso restringido

Gemma 3 exige **aceptar la licencia de Google** en Hugging Face:

1. Cuenta en [huggingface.co/join](https://huggingface.co/join)
2. Ir a [gemma-3-12b-it-qat-q4_0-unquantized](https://huggingface.co/google/gemma-3-12b-it-qat-q4_0-unquantized)
3. Pulsar **"Agree and access repository"**
4. Crear un token de lectura en [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens)
5. Usar el token al descargar:

```powershell
# Con el script
$env:HF_TOKEN = "hf_tu_token"
.\scripts\descargar-gemma3-ltx2.ps1

# O con Hugging Face CLI
huggingface-cli login
huggingface-cli download google/gemma-3-12b-it-qat-q4_0-unquantized --local-dir "$env:USERPROFILE\comfyui-models\text_encoders\gemma-3-12b-it-qat-q4_0-unquantized"
```

---

## 🔧 3. Volúmenes Docker (latent_upscale_models)

Si usás `recrear-comfyui-robusto.ps1`, el script ahora incluye el volumen `latent_upscale_models`. Si no, agregalo al `docker run`:

```powershell
-v "${env:USERPROFILE}/comfyui-models/latent_upscale_models:/root/ComfyUI/models/latent_upscale_models"
```

---

## ⚡ 4. RTX 5070 (Blackwell)

Con RTX 5070 usá PyTorch con CUDA 12.8:

```powershell
.\scripts\recrear-comfyui-robusto.ps1 -RTX50
```

---

## 🚀 5. Uso en ComfyUI

1. Abrí ComfyUI: `http://localhost:7860`
2. Cargá un workflow de ejemplo:
   - Menú → **Load** → `custom_nodes/ComfyUI-LTXVideo/example_workflows/`
   - Ejemplo: `LTX-2_T2V_Distilled_wLora.json` (texto a video)
3. Ajustes para 12 GB VRAM:
   - Resolución: 576×576 o 720×720
   - Duración: 5–6 segundos
   - Usar nodos **Low VRAM** si ComfyUI-LTXVideo los expone

---

## 📋 Resumen de pasos

```powershell
# 1. Instalar custom node y crear directorios
.\scripts\setup-ltx2-comfyui.ps1

# 2. Descargar modelos (o usar Hugging Face CLI)
# Ver enlaces en la tabla de modelos arriba

# 3. Si usás recrear-comfyui-robusto, asegurarte de tener RTX50
.\scripts\recrear-comfyui-robusto.ps1 -RTX50

# 4. Reiniciar ComfyUI
docker restart comfyui
```

---

## 🔗 Referencias

- [LTX-2 GitHub](https://github.com/Lightricks/LTX-2)
- [ComfyUI-LTXVideo](https://github.com/Lightricks/ComfyUI-LTXVideo)
- [Modelos en Hugging Face](https://huggingface.co/Lightricks/LTX-2)
- [Documentación LTX](https://docs.ltx.video/open-source-model/integration-tools/comfy-ui)
