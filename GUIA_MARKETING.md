# Guía de Herramientas de Marketing

## Descripción

Las herramientas de marketing integradas permiten crear contenido completo de marketing desde una sola interfaz:

- Generación de copy
- Hashtags optimizados
- Análisis de competencia
- Briefs de campaña
- Imágenes para redes sociales
- Videos de marketing

## Funcionalidades Principales

### 1. Generación de Copy de Marketing

Crea textos optimizados para diferentes canales y audiencias.

#### Uso Básico

```python
from extensions.open-webui-multimedia import generate_marketing_copy

copy = generate_marketing_copy(
    product="Nuevo smartphone",
    audience="Jóvenes profesionales",
    tone="profesional",
    template_type="social_media_post"
)
```

#### Tipos de Templates

- **social_media_post**: Posts para redes sociales
- **email_campaign**: Emails de marketing
- **landing_page**: Contenido para landing pages
- **product_description**: Descripciones de productos

#### Tonos Disponibles

- profesional
- casual
- entusiasta
- educativo
- humorístico
- persuasivo

### 2. Generación de Hashtags

Crea hashtags optimizados por plataforma.

```python
from extensions.open-webui-multimedia import generate_hashtags

hashtags = generate_hashtags(
    topic="tecnología",
    platform="instagram",
    count=10
)
```

#### Plataformas Soportadas

- **instagram**: Hasta 30 hashtags, mezcla de populares y nicho
- **twitter**: 1-3 hashtags, relevantes y trending
- **linkedin**: 3-5 hashtags, profesionales
- **tiktok**: 3-5 hashtags, trending

### 3. Análisis de Competencia

Analiza competidores usando búsqueda web.

```python
from extensions.open-webui-multimedia import analyze_competitor

analysis = analyze_competitor(
    url="https://competidor.com",
    max_results=10
)
```

### 4. Briefs de Campaña

Genera briefs estructurados para campañas.

```python
from extensions.open-webui-multimedia import create_campaign_brief

brief = create_campaign_brief(
    product="Producto X",
    goals=@("Aumentar ventas", "Mejorar brand awareness"),
    target_audience="Jóvenes 18-35",
    budget="5000 USD",
    timeline="1 mes"
)
```

### 5. Imágenes para Marketing

#### Crear Imagen Promocional con Lema

Para crear una imagen promocional con un lema o slogan para una campaña publicitaria:

**Opción A: Desde el Chat (Comando Natural)**
```
Crea una imagen promocional con el lema "Innovación que transforma" 
para una campaña de tecnología. 
Tema: Productos tecnológicos innovadores. 
Formato: Banner web (1920x1080). 
Estilo: Moderno y profesional
```

**Opción B: Usando Función Específica**
```python
from extensions.open-webui-multimedia import generate_marketing_image_with_slogan

result = generate_marketing_image_with_slogan(
    product_description="Productos tecnológicos innovadores",
    slogan="Innovación que transforma",
    platform="banner_web",
    style="modern"
)
```

**Opción C: Campaña Completa**
```python
from extensions.open-webui-multimedia import create_promotional_campaign_image

result = create_promotional_campaign_image(
    campaign_theme="Lanzamiento de nuevo producto tecnológico",
    tagline="El futuro es ahora",
    target_audience="professionals",
    image_type="banner"
)
```

#### Ejemplos de Prompts para Imágenes con Lema

**Banner Promocional:**
```
Crea un banner promocional (1920x1080) para una campaña de café. 
Tema: Café artesanal de alta calidad. 
Lema: "Cada taza cuenta una historia". 
Estilo: Cálido, acogedor, colores tierra, diseño moderno
```

**Imagen de Redes Sociales:**
```
Genera una imagen de Instagram (1080x1080) para promocionar sostenibilidad. 
Tema: Cuidado del medio ambiente. 
Lema: "Tu planeta te necesita". 
Estilo: Vibrante, ecológico, colores verdes
```

**Campaña Publicitaria:**
```
Crea una imagen promocional para una campaña de moda. 
Tema: Ropa sostenible y ética. 
Lema: "Estilo con conciencia". 
Audiencia: Jóvenes conscientes. 
Formato: Facebook post (1200x630)
```

### 5.1. Imágenes para Marketing (Continuación)

#### Imágenes para Redes Sociales

```python
from extensions.open-webui-multimedia import generate_social_media_image

image = generate_social_media_image(
    prompt="Nuevo producto innovador",
    platform="instagram",
    content_type="post"
)
```

#### Banners

```python
from extensions.open-webui-multimedia import generate_banner

banner = generate_banner(
    prompt="Oferta especial de lanzamiento",
    size="standard"  # standard, wide, square, vertical
)
```

#### Imágenes con Estilo de Marketing

```python
from extensions.open-webui-multimedia import generate_marketing_image

image = generate_marketing_image(
    prompt="Producto destacado",
    style="modern",  # modern, bold, elegant, minimalist, vibrant, corporate, creative
    dimensions={"width": 1200, "height": 1200}
)
```

### 6. Videos para Marketing

#### Video Básico

```python
from extensions.open-webui-multimedia import generate_marketing_video

video = generate_marketing_video(
    image_path="producto.png",
    duration=15,  # 5, 15, 30, 60 segundos
    style="dynamic",
    add_narration=True,
    narration_text="Descubre nuestro nuevo producto",
    narration_language="es"
)
```

#### Video con Audio

```python
from extensions.open-webui-multimedia import generate_video_with_audio

video = generate_video_with_audio(
    image_path="banner.png",
    audio_text="Narración del video",
    audio_language="es",
    duration=30,
    sync_audio=True
)
```

## Dimensiones por Plataforma

### Instagram
- Post: 1080x1080
- Story: 1080x1920

### Twitter
- Post: 1200x675

### Facebook
- Post: 1200x630
- Cover: 1200x628

### LinkedIn
- Post: 1200x627
- Cover: 1584x396

### YouTube
- Thumbnail: 1280x720

## Workflows Predefinidos

### Campaña de Redes Sociales

1. Generar copy de marketing
2. Generar hashtags optimizados
3. Crear imagen para la plataforma
4. Generar video corto (opcional)
5. Agregar narración con TTS (opcional)

### Lanzamiento de Producto

1. Crear brief de campaña
2. Generar copy para diferentes canales
3. Crear imágenes promocionales
4. Generar videos promocionales
5. Crear hashtags para el lanzamiento

## Templates Disponibles

### Prompts Predefinidos

```python
from extensions.open-webui-multimedia import get_prompt_template

# Template para post de Instagram
prompt = get_prompt_template(
    "instagram_post",
    topic="Nuevo producto",
    audience="Jóvenes",
    tone="entusiasta"
)
```

### Estilos de Imagen

```python
from extensions.open-webui-multimedia import get_image_style

style = get_image_style("modern")
# Retorna: "moderno, limpio, contemporáneo, profesional, diseño minimalista"
```

## Ejemplos Completos

### Crear Campaña Completa

```python
from extensions.open-webui-multimedia import (
    generate_marketing_copy,
    generate_hashtags,
    generate_social_media_image,
    generate_marketing_video
)

# 1. Copy
copy = generate_marketing_copy(
    product="Smartphone Pro",
    audience="Tech enthusiasts",
    tone="entusiasta",
    template_type="social_media_post"
)

# 2. Hashtags
hashtags = generate_hashtags("smartphone", "instagram", 10)

# 3. Imagen
image = generate_social_media_image(
    prompt="Smartphone Pro con características destacadas",
    platform="instagram",
    content_type="post"
)

# 4. Video
video = generate_marketing_video(
    image_path=image["image_url"],
    duration=15,
    add_narration=True,
    narration_text=copy["prompt"],
    narration_language="es"
)
```

## Mejores Prácticas

1. **Define tu audiencia**: Conoce bien a quién te diriges
2. **Consistencia de marca**: Usa los mismos estilos y tonos
3. **Optimiza por plataforma**: Cada plataforma tiene sus mejores prácticas
4. **Prueba y ajusta**: Experimenta con diferentes enfoques
5. **Combina medios**: Usa texto, imagen y video juntos

## Troubleshooting

### Copy no es efectivo

- Ajusta el tono según tu audiencia
- Prueba diferentes templates
- Usa prompts más específicos

### Hashtags no relevantes

- Especifica mejor el tema
- Ajusta la cantidad según la plataforma
- Revisa los hashtags generados manualmente

### Imágenes no se ven bien

- Verifica las dimensiones para la plataforma
- Prueba diferentes estilos
- Ajusta el prompt para ser más específico

### Videos muy largos

- Usa duraciones optimizadas (5s, 15s, 30s)
- Considera la atención de tu audiencia
- Diferentes plataformas prefieren diferentes duraciones

Crea un post de Instagram para Aesthetic Nails, servicio de uñas a domicilio en Quito, Ecuador.
Mensaje: "Belleza en la comodidad de tu hogar".
Audiencia: Mujeres profesionales y amas de casa de 25-45 años en Quito.
Tono: Elegante, profesional y acogedor.
Incluye: Beneficios del servicio a domicilio, calidad profesional, horarios flexibles.
Call-to-action: "Reserva tu cita hoy".

profile
mistral:latest
Today at 3:20 PM
Aquí tienes un ejemplo de un post de Instagram para la marca Aesthetic Nails, que ofrece servicios de uñas a domicilio en Quito, Ecuador:

Post de Instagram de Aesthetic Nails

Este post utiliza una imagen elegante y acogedora que muestra una mano con uñas estéticas y un fondo blanco, junto con una leyenda en negrita que destaca la oferta de belleza en el confort de su hogar. También se mencionan algunos beneficios del servicio a domicilio, como la calidad profesional y los horarios flexibles.

El tono del post es elegante y acogedor, y está dirigido a mujeres profesionales y amas de casa de 25-45 años en Quito que buscan un servicio de uñas estéticas de alta calidad en la comodidad de su hogar.

El call-to-action final invita a las personas a reservar una cita para el servicio, para que puedan disfrutar de una experiencia de belleza y relajación sin salir de casa.









