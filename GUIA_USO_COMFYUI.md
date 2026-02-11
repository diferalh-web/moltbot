# 🎨 Guía de Uso de ComfyUI

## 🚀 Inicio Rápido

ComfyUI es una interfaz visual para crear **workflows** (flujos de trabajo) de generación de imágenes usando **nodos conectados**.

### Interfaz Principal

La interfaz de ComfyUI tiene:
- **Área de trabajo central**: Donde arrastras y conectas nodos
- **Menú lateral derecho**: Para agregar nuevos nodos
- **Barra superior**: Para cargar/guardar workflows y ejecutar

---

## 📝 Primer Workflow: Generar una Imagen Simple

### Paso 1: Cargar un Workflow Básico

1. **Haz clic en el menú "Load"** (cargar) en la barra superior
2. ComfyUI tiene workflows de ejemplo, o puedes empezar desde cero

### Paso 2: Crear un Workflow Básico Manualmente

Si prefieres crear uno desde cero:

1. **Haz clic derecho** en el área de trabajo
2. **Selecciona "Add Node"** → **"Load Checkpoint"**
   - Este nodo carga el modelo de generación de imágenes
3. **Haz clic derecho** de nuevo → **"Add Node"** → **"CLIP Text Encode"** (Prompt)
   - Este nodo procesa tu prompt de texto
4. **Haz clic derecho** → **"Add Node"** → **"KSampler"**
   - Este nodo genera la imagen
5. **Haz clic derecho** → **"Add Node"** → **"VAE Decode"**
   - Este nodo decodifica la imagen
6. **Haz clic derecho** → **"Add Node"** → **"Save Image"**
   - Este nodo guarda la imagen generada

### Paso 3: Conectar los Nodos

Conecta los nodos en este orden:
```
Load Checkpoint → CLIP Text Encode (Prompt) → KSampler → VAE Decode → Save Image
```

**Cómo conectar:**
- Haz clic en un **punto de salida** (output) de un nodo
- Arrastra hasta el **punto de entrada** (input) del siguiente nodo
- Suelta para crear la conexión

### Paso 4: Configurar el Prompt

1. **Haz doble clic** en el nodo **"CLIP Text Encode (Prompt)"**
2. **Escribe tu prompt** en el campo de texto, por ejemplo:
   ```
   a beautiful sunset over the ocean, high quality, detailed
   ```
3. También puedes configurar un **negative prompt** (lo que NO quieres):
   ```
   blurry, low quality, distorted
   ```

### Paso 5: Configurar el Sampler

1. **Haz doble clic** en el nodo **"KSampler"**
2. Configura:
   - **Steps**: 20-30 (más pasos = mejor calidad pero más lento)
   - **CFG Scale**: 7-9 (control sobre el prompt)
   - **Sampler**: `euler` o `dpmpp_2m` (buenos para empezar)
   - **Scheduler**: `normal` o `karras`

### Paso 6: Generar la Imagen

1. **Haz clic en "Queue Prompt"** en la barra superior
2. Espera a que se genere la imagen (puede tardar 30 segundos - 2 minutos)
3. La imagen aparecerá en el nodo **"Save Image"**
4. **Haz clic en la imagen** para verla en tamaño completo

---

## 🎯 Nodos Importantes

### Nodos Básicos

| Nodo | Función |
|------|---------|
| **Load Checkpoint** | Carga el modelo de IA (Stable Diffusion, Flux, etc.) |
| **CLIP Text Encode** | Convierte texto en representación que el modelo entiende |
| **KSampler** | Genera la imagen paso a paso |
| **VAE Decode** | Convierte la representación interna en imagen visible |
| **Save Image** | Guarda la imagen generada |

### Nodos Avanzados

| Nodo | Función |
|------|---------|
| **Empty Latent Image** | Define el tamaño de la imagen |
| **Image Upscale** | Aumenta la resolución de la imagen |
| **ControlNet** | Controla la composición usando otra imagen |
| **Image to Image** | Modifica una imagen existente |
| **Inpainting** | Rellena áreas específicas de una imagen |

---

## 💡 Tips y Trucos

### 1. Guardar Workflows

- **Haz clic en "Save"** en la barra superior
- Guarda tu workflow para reutilizarlo después
- Los workflows se guardan como archivos JSON

### 2. Cargar Workflows Existentes

- **Haz clic en "Load"** en la barra superior
- Selecciona un archivo JSON de workflow
- ComfyUI tiene workflows de ejemplo incluidos

### 3. Ajustar el Tamaño de la Imagen

1. Agrega un nodo **"Empty Latent Image"**
2. Conéctalo antes del **KSampler**
3. Configura:
   - **Width**: 512, 768, 1024 (ancho)
   - **Height**: 512, 768, 1024 (alto)
   - **Batch Size**: 1-4 (cuántas imágenes generar a la vez)

### 4. Mejorar la Calidad

- **Aumenta Steps**: 30-50 para mejor calidad
- **Usa CFG Scale**: 7-9 para mejor adherencia al prompt
- **Aumenta la resolución**: 1024x1024 o más

### 5. Generar Múltiples Imágenes

- Configura **Batch Size** en el nodo **Empty Latent Image**
- O usa **Batch Count** en el **KSampler**

---

## 🔧 Configuración Avanzada

### Descargar Modelos

ComfyUI descarga modelos automáticamente cuando los usas, pero puedes descargarlos manualmente:

1. Los modelos se guardan en: `C:\Users\TU_USUARIO\comfyui-models\`
2. Puedes descargar modelos desde:
   - **Hugging Face**: https://huggingface.co/models
   - **Civitai**: https://civitai.com/

### Tipos de Modelos

- **Checkpoints**: Modelos completos (Stable Diffusion, Flux, etc.)
- **LoRA**: Modelos pequeños que modifican el estilo
- **VAE**: Mejoran la calidad y los colores
- **ControlNet**: Controlan la composición

---

## 📚 Ejemplos de Workflows

### Ejemplo 1: Generación Simple

```
Load Checkpoint → CLIP Text Encode → KSampler → VAE Decode → Save Image
```

### Ejemplo 2: Con Tamaño Personalizado

```
Load Checkpoint → CLIP Text Encode → Empty Latent Image → KSampler → VAE Decode → Save Image
```

### Ejemplo 3: Image to Image

```
Load Checkpoint → Load Image → CLIP Text Encode → VAE Encode → KSampler → VAE Decode → Save Image
```

---

## 🐛 Solución de Problemas

### La imagen no se genera

1. **Verifica que todos los nodos estén conectados**
2. **Revisa que el modelo esté cargado** (Load Checkpoint)
3. **Asegúrate de hacer clic en "Queue Prompt"**

### La imagen es de baja calidad

1. **Aumenta Steps** a 30-50
2. **Aumenta la resolución** (1024x1024 o más)
3. **Usa un modelo mejor** (Flux, SDXL, etc.)

### El servidor se cuelga

1. **Reduce la resolución** de la imagen
2. **Reduce Batch Size** a 1
3. **Reduce Steps** a 20-30

---

## 🎓 Recursos Adicionales

- **Documentación oficial**: https://github.com/comfyanonymous/ComfyUI
- **Tutoriales en YouTube**: Busca "ComfyUI tutorial"
- **Workflows de ejemplo**: ComfyUI incluye varios workflows de ejemplo

---

## 🚀 Próximos Pasos

1. **Experimenta** con diferentes prompts
2. **Prueba diferentes modelos** (Stable Diffusion, Flux, SDXL)
3. **Crea workflows más complejos** con múltiples pasos
4. **Guarda tus mejores workflows** para reutilizarlos

---

¡Disfruta creando imágenes con ComfyUI! 🎨









