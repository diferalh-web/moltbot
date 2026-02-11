# 🎨 Solución: Crear Imágenes Promocionales con Lema

## 🔍 Problema Identificado

El modelo LLM en Open WebUI no está reconociendo automáticamente las funciones de extensión y está dando respuestas genéricas sobre bibliotecas de Python que no existen.

## ✅ Soluciones Prácticas

### Solución 1: Usar Comandos Naturales en el Chat (Más Fácil)

Simplemente escribe en el chat de Open WebUI (`http://localhost:8082`) de manera natural y específica:

**Ejemplo para imagen promocional con lema:**

```
Crea una imagen promocional para una campaña publicitaria de tecnología. 
Tema: Productos innovadores de IA. 
Lema: "Innovación que transforma". 
Formato: Banner web (1920x1080). 
Estilo: Moderno, profesional, colores azul y plata, diseño minimalista con el lema destacado
```

**Otro ejemplo:**

```
Genera una imagen de Instagram (1080x1080) para promocionar un café. 
Tema: Café artesanal de alta calidad. 
Lema: "Cada taza cuenta una historia". 
Estilo: Cálido, acogedor, colores tierra y marrón, iluminación natural, texto del lema visible
```

### Solución 2: Usar ComfyUI Directamente (Más Control)

1. **Abre ComfyUI**: `http://localhost:7860`
2. **Crea o carga un workflow**
3. **En el nodo de prompt**, escribe:
   ```
   Promotional campaign image: [tu tema]. 
   Tagline: "[tu lema]". 
   Marketing material, professional design, high quality, 
   [estilo], [colores], text visible and prominent
   ```
4. **Genera la imagen**

### Solución 3: Usar la API Directamente (Para Desarrolladores)

#### Opción A: Usar Flux (Ollama)

```powershell
# Verificar que Flux esté disponible
docker exec ollama-flux ollama list

# Si no está, descargarlo:
docker exec ollama-flux ollama pull flux

# Generar imagen
$body = @{
    model = "flux"
    prompt = "Promotional campaign image: Technology products. Tagline: 'Innovation that transforms'. Marketing banner, modern style, blue and silver colors, professional design, text visible"
    stream = $false
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:11439/api/generate" `
  -Method POST `
  -ContentType "application/json" `
  -Body $body
```

#### Opción B: Usar ComfyUI API

```powershell
$body = @{
    prompt = "Promotional campaign image: Technology products. Tagline: 'Innovation that transforms'. Marketing banner, modern style, blue and silver colors, professional design"
    width = 1920
    height = 1080
    steps = 50
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:7860/api/v1/generate" `
  -Method POST `
  -ContentType "application/json" `
  -Body $body
```

## 📋 Plantillas de Prompts para Diferentes Casos

### Banner Web con Lema

```
Crea un banner promocional (1920x1080) para una campaña de [tema]. 
Lema: "[tu lema]". 
Estilo: [moderno/clásico/minimalista]. 
Colores: [especifica colores]. 
El lema debe ser visible y destacado en el diseño
```

### Imagen de Instagram con Slogan

```
Genera una imagen de Instagram (1080x1080) para promocionar [producto/servicio]. 
Slogan: "[tu slogan]". 
Tema: [descripción del tema]. 
Estilo: [estilo deseado]. 
Colores: [paleta de colores]. 
El texto del slogan debe ser legible y atractivo
```

### Campaña Publicitaria Completa

```
Crea una imagen promocional para una campaña de [tipo de campaña]. 
Tema: [tema de la campaña]. 
Lema: "[lema de la campaña]". 
Audiencia objetivo: [audiencia]. 
Formato: [plataforma/tamaño]. 
Estilo: [estilo]. 
Colores: [colores]. 
El lema debe ser el elemento central del diseño
```

## 🎯 Ejemplos Específicos Listos para Usar

### Ejemplo 1: Tecnología

```
Crea una imagen promocional con el lema "Innovación que transforma" 
para una campaña de tecnología dirigida a profesionales. 
Tema: Soluciones de IA empresarial. 
Formato: Banner web (1920x1080). 
Estilo: Moderno, profesional, minimalista. 
Colores: Azul (#0066CC) y plata (#C0C0C0). 
El lema debe estar destacado en el centro
```

### Ejemplo 2: Café/Restaurante

```
Genera una imagen de Instagram (1080x1080) para promocionar un café. 
Tema: Café artesanal de alta calidad. 
Lema: "Cada taza cuenta una historia". 
Estilo: Cálido, acogedor, rústico. 
Colores: Tierra (#8B4513), beige (#F5F5DC), crema (#FFF8DC). 
Iluminación natural, el lema debe ser visible y atractivo
```

### Ejemplo 3: Sostenibilidad

```
Crea una imagen promocional para una campaña de sostenibilidad. 
Tema: Cuidado del medio ambiente y reciclaje. 
Lema: "Tu planeta te necesita". 
Audiencia: Jóvenes conscientes (18-35 años). 
Formato: Facebook post (1200x630). 
Estilo: Vibrante, ecológico, moderno. 
Colores: Verde (#228B22), azul cielo (#87CEEB), blanco. 
El lema debe ser el mensaje principal
```

### Ejemplo 4: Moda

```
Genera una imagen promocional para una campaña de moda sostenible. 
Tema: Ropa ética y sostenible. 
Lema: "Estilo con conciencia". 
Formato: Instagram post (1080x1080). 
Estilo: Elegante, moderno, sofisticado. 
Colores: Negro, blanco, verde menta (#98FB98). 
El lema debe estar integrado de manera elegante
```

## 🔧 Verificación de Servicios

Antes de generar imágenes, verifica que los servicios estén corriendo:

```powershell
# Verificar Ollama-Flux
docker ps --filter "name=ollama-flux"

# Verificar ComfyUI
docker ps --filter "name=comfyui"

# Probar conectividad
Invoke-WebRequest -Uri "http://localhost:11439/api/tags" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:7860" -UseBasicParsing
```

## 💡 Consejos para Mejores Resultados

1. **Sé específico con el lema**: Menciona explícitamente que el lema debe aparecer en la imagen
2. **Describe el estilo**: Moderno, clásico, minimalista, etc.
3. **Especifica colores**: Menciona la paleta de colores deseada
4. **Define el formato**: Banner, post de Instagram, etc.
5. **Menciona la audiencia**: Esto ayuda a ajustar el estilo
6. **Pide que el texto sea visible**: Especifica que el lema debe ser legible

## 🚀 Próximos Pasos

1. **Prueba con comandos naturales** en el chat de Open WebUI
2. **Si no funciona**, usa ComfyUI directamente en `http://localhost:7860`
3. **Para automatización**, usa las APIs mostradas arriba
4. **Experimenta con diferentes prompts** hasta obtener el resultado deseado

## 📝 Nota Importante

Las extensiones de Open WebUI pueden no estar siendo reconocidas automáticamente por el modelo LLM. Por eso, es mejor usar:
- **Comandos naturales y específicos** en el chat
- **ComfyUI directamente** para más control
- **Las APIs** para integración programática









