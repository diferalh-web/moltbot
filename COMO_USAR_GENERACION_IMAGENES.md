# 🎨 Cómo Usar la Generación de Imágenes en Open WebUI

## ⚠️ Problema Actual

El modelo LLM no está reconociendo las funciones de extensión correctamente. Está dando respuestas genéricas en lugar de usar las funciones reales.

## ✅ Solución: Instrucciones Directas para el Usuario

### Método 1: Comandos Naturales (Recomendado)

Simplemente escribe en el chat de Open WebUI de manera natural:

**Ejemplos:**

```
Crea una imagen de un gato astronauta flotando en el espacio
```

```
Genera un banner moderno para mi producto de tecnología
```

```
Crea una imagen promocional con el lema "Innovación que transforma" para una campaña de tecnología
```

```
Genera una imagen de Instagram para promocionar un café, con el slogan "El mejor café de la ciudad"
```

### Método 2: Usar ComfyUI Directamente

Si las funciones de extensión no funcionan, puedes usar ComfyUI directamente:

1. **Abre ComfyUI**: `http://localhost:7860`
2. **Crea un workflow** o usa uno existente
3. **Escribe tu prompt** en el campo correspondiente
4. **Genera la imagen**

### Método 3: Usar la API Directamente

Puedes llamar a la API de generación de imágenes directamente:

```powershell
# Usando Flux (si está disponible)
Invoke-WebRequest -Uri "http://localhost:11439/api/generate" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"model":"flux","prompt":"Un gato astronauta en el espacio","stream":false}'

# O usando ComfyUI
Invoke-WebRequest -Uri "http://localhost:7860/api/v1/generate" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"prompt":"Un paisaje futurista","width":1024,"height":1024}'
```

## 🎯 Para Imágenes Promocionales con Lema

### Ejemplo 1: Banner con Slogan

**Prompt sugerido:**
```
Crea un banner promocional de 1920x1080 para una campaña de tecnología. 
Tema: Innovación en IA. 
Lema: "El futuro es ahora". 
Estilo: Moderno, profesional, colores azul y blanco, diseño minimalista
```

### Ejemplo 2: Imagen de Redes Sociales con Tagline

**Prompt sugerido:**
```
Genera una imagen de Instagram (1080x1080) para promocionar un café. 
Tema: Café artesanal. 
Lema: "Cada taza cuenta una historia". 
Estilo: Cálido, acogedor, colores tierra y marrón, iluminación natural
```

### Ejemplo 3: Campaña Publicitaria Completa

**Prompt sugerido:**
```
Crea una imagen promocional para una campaña de sostenibilidad. 
Tema: Cuidado del medio ambiente. 
Lema: "Tu planeta te necesita". 
Audiencia: Jóvenes conscientes. 
Estilo: Vibrante, ecológico, colores verdes y naturales, diseño moderno
```

## 🔧 Configuración de Servicios

### Generación con ComfyUI + Flux (API real)

La extensión usa la **API real de ComfyUI**: construye un workflow text-to-image (Flux/Stable Diffusion), lo envía a `/prompt`, espera el resultado en `/history` y devuelve la imagen. No hace falta crear el flujo a mano en la interfaz de ComfyUI.

**Requisitos:**

1. **ComfyUI** corriendo (contenedor `comfyui` en puerto 8188 interno / 7860 externo).
2. **Checkpoint de Flux** (o cualquier checkpoint compatible) en la carpeta de checkpoints de ComfyUI. Por defecto se usa el archivo `flux1-schnell.safetensors`. Si tu archivo tiene otro nombre, configura la variable de entorno:
   - `COMFYUI_CHECKPOINT_NAME=tu_archivo.safetensors`
   - En Docker (open-webui): ya está en `docker-compose-extended.yml` como `COMFYUI_CHECKPOINT_NAME` (por defecto `flux1-schnell.safetensors`).

**En la WebUI:** al pedir una imagen, usa el modelo **ComfyUI** (no Flux/Ollama) para que la petición vaya a ComfyUI con este workflow. Si la interfaz permite elegir “motor de imágenes”, selecciona ComfyUI y URL `http://comfyui:8188`.

### Verificar que los Servicios Estén Corriendo

```powershell
# Verificar Ollama-Flux
docker ps --filter "name=ollama-flux"

# Verificar ComfyUI
docker ps --filter "name=comfyui"

# Probar conectividad
Invoke-WebRequest -Uri "http://localhost:11439/api/tags" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:7860" -UseBasicParsing
```

### Si Flux No Está Disponible

1. **Descargar Flux en Ollama:**
   ```powershell
   docker exec ollama-flux ollama pull flux
   ```

2. **O usar ComfyUI** que ya está configurado en `http://localhost:7860`

## 📝 Notas Importantes

1. **Las extensiones de Open WebUI** pueden no estar siendo reconocidas automáticamente por el modelo LLM
2. **Usa comandos naturales** en el chat - el sistema debería interpretarlos
3. **Si no funciona**, usa ComfyUI directamente o las APIs
4. **Los prompts detallados** funcionan mejor que comandos técnicos

## 🎨 Mejores Prácticas para Prompts

1. **Sé específico**: Describe exactamente lo que quieres
2. **Incluye el lema**: Menciona explícitamente el texto que debe aparecer
3. **Define el estilo**: Moderno, clásico, minimalista, etc.
4. **Especifica dimensiones**: Si necesitas un tamaño específico
5. **Menciona colores**: Si tienes una paleta de colores preferida

## 💡 Ejemplo Completo

**Usuario escribe:**
```
Crea una imagen promocional con el lema "Innovación que transforma" 
para una campaña de tecnología dirigida a profesionales. 
Formato: Banner web (1920x1080). 
Estilo: Moderno y profesional, colores azul y plata
```

**El sistema debería:**
1. Interpretar el comando
2. Llamar a la función de generación de imágenes
3. Crear la imagen con el lema incluido
4. Mostrarla en el chat

Si esto no funciona automáticamente, usa ComfyUI directamente o las APIs mencionadas arriba.









