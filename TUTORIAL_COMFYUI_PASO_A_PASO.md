# 🎨 Tutorial ComfyUI: Paso a Paso desde tu Estado Actual

## 📍 Estado Actual

Tienes el nodo **"Load Checkpoint"** en el canvas. Este nodo carga el modelo de IA.

## 🚀 Pasos para Completar el Workflow

### Paso 1: Configurar el Modelo (Load Checkpoint)

1. **Haz doble clic** en el nodo "Load Checkpoint"
2. En el campo **"ckpt_name"**, haz clic en el dropdown o escribe el nombre del modelo
3. Si no tienes modelos, ComfyUI descargará uno automáticamente la primera vez
4. **Modelos recomendados para empezar:**
   - `sd_xl_base_1.0.safetensors` (Stable Diffusion XL)
   - `v1-5-pruned-emaonly.safetensors` (Stable Diffusion 1.5)
   - O cualquier modelo que veas en la lista

### Paso 2: Agregar Nodo de Texto (Prompt)

1. **Haz clic derecho** en el área de trabajo (fuera del nodo existente)
2. Selecciona **"Add Node"** → **"conditioning"** → **"CLIP Text Encode"**
   - O busca "CLIP Text Encode" en el menú
3. Aparecerá un nuevo nodo en el canvas

### Paso 3: Conectar el Checkpoint al Text Encoder

1. **Arrastra** desde el output **"CLIP"** (círculo amarillo) del nodo "Load Checkpoint"
2. **Conecta** al input **"CLIP"** del nodo "CLIP Text Encode"
3. Verás una línea amarilla conectando ambos nodos

### Paso 4: Configurar el Prompt

1. **Haz doble clic** en el nodo "CLIP Text Encode"
2. En el campo **"text"**, escribe tu descripción, por ejemplo:
   ```
   a beautiful sunset over the ocean, high quality, detailed, 4k
   ```
3. (Opcional) Si hay un campo para **negative prompt**, escribe:
   ```
   blurry, low quality, distorted, ugly
   ```

### Paso 5: Agregar Nodo de Tamaño (Empty Latent Image)

1. **Clic derecho** en el canvas → **"Add Node"** → **"latent"** → **"Empty Latent Image"**
2. **Haz doble clic** en este nodo para configurar:
   - **width**: 512 o 768 (ancho)
   - **height**: 512 o 768 (alto)
   - **batch_size**: 1 (número de imágenes)

### Paso 6: Agregar el Sampler (KSampler)

1. **Clic derecho** → **"Add Node"** → **"sampling"** → **"KSampler"**
2. **Conecta los nodos:**
   - Del output **"MODEL"** (morado) de "Load Checkpoint" → input **"model"** del KSampler
   - Del output de "CLIP Text Encode" → input **"positive"** del KSampler
   - Del output de "Empty Latent Image" → input **"latent_image"** del KSampler
3. **Configura el KSampler** (doble clic):
   - **seed**: -1 (aleatorio) o un número específico
   - **steps**: 20-30 (más = mejor calidad pero más lento)
   - **cfg_scale**: 7-9
   - **sampler_name**: `euler` o `dpmpp_2m`
   - **scheduler**: `normal` o `karras`

### Paso 7: Agregar VAE Decode

1. **Clic derecho** → **"Add Node"** → **"vae"** → **"VAE Decode"**
2. **Conecta:**
   - Del output **"VAE"** (rojo) de "Load Checkpoint" → input **"vae"** de VAE Decode
   - Del output **"LATENT"** del KSampler → input **"samples"** de VAE Decode

### Paso 8: Agregar Save Image

1. **Clic derecho** → **"Add Node"** → **"image"** → **"Save Image"**
2. **Conecta:**
   - Del output **"IMAGE"** del VAE Decode → input **"images"** de Save Image

### Paso 9: Generar la Imagen

1. **Haz clic en "Queue Prompt"** o el botón **"Run"** en la barra superior
2. Espera 30 segundos - 2 minutos
3. La imagen aparecerá en el nodo "Save Image"
4. **Haz clic en la imagen** para verla en tamaño completo

## 📊 Diagrama del Workflow Completo

```
Load Checkpoint
    ├─ MODEL (morado) ──────┐
    ├─ CLIP (amarillo) ────┐│
    └─ VAE (rojo) ─────────┐││
                           │││
CLIP Text Encode           │││
    └─ output ─────────────┘││
                             ││
Empty Latent Image          ││
    └─ LATENT ───────────────┘│
                              │
KSampler                     │
    ├─ positive ──────────────┘
    └─ LATENT ───────────────┐
                              │
VAE Decode                   │
    └─ IMAGE ─────────────────┘
                              │
Save Image                    │
    └─ (muestra la imagen) ────┘
```

## 🎯 Configuración Recomendada para Empezar

### KSampler:
- **steps**: 25
- **cfg_scale**: 7.5
- **sampler_name**: `euler`
- **scheduler**: `normal`

### Empty Latent Image:
- **width**: 512
- **height**: 512
- **batch_size**: 1

## 💡 Tips

1. **Si no ves modelos en el dropdown:**
   - ComfyUI descargará el modelo automáticamente la primera vez
   - Puede tardar varios minutos dependiendo del tamaño

2. **Para cambiar el modelo:**
   - Haz doble clic en "Load Checkpoint"
   - Selecciona otro modelo del dropdown

3. **Para generar múltiples imágenes:**
   - Aumenta **batch_size** en "Empty Latent Image"

4. **Para mejor calidad:**
   - Aumenta **steps** a 30-50
   - Aumenta **width** y **height** a 768 o 1024

## 🐛 Problemas Comunes

### El modelo no carga
- Espera unos minutos (primera descarga)
- Verifica que tengas espacio en disco

### La imagen no se genera
- Verifica que todos los nodos estén conectados
- Asegúrate de hacer clic en "Queue Prompt"

### Error al conectar nodos
- Los colores deben coincidir (morado con morado, amarillo con amarillo, etc.)
- Algunas conexiones no son compatibles

---

¡Sigue estos pasos y tendrás tu primera imagen generada! 🎨









