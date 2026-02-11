"""
Templates y workflows predefinidos para marketing
"""

from typing import Dict, Any, List

# Workflows predefinidos para diferentes tipos de campañas
MARKETING_WORKFLOWS = {
    "social_media_campaign": {
        "name": "Campaña de Redes Sociales",
        "steps": [
            "1. Generar copy de marketing",
            "2. Generar hashtags optimizados",
            "3. Crear imagen para la plataforma",
            "4. Generar video corto (opcional)",
            "5. Agregar narración con TTS (opcional)"
        ],
        "platforms": ["instagram", "twitter", "facebook", "linkedin"],
        "content_types": ["post", "story", "video"]
    },
    "product_launch": {
        "name": "Lanzamiento de Producto",
        "steps": [
            "1. Crear brief de campaña",
            "2. Generar copy para diferentes canales",
            "3. Crear imágenes promocionales (banners, posts)",
            "4. Generar videos promocionales",
            "5. Crear hashtags para el lanzamiento"
        ],
        "channels": ["email", "social_media", "landing_page"],
        "assets": ["banner", "social_post", "video", "email_template"]
    },
    "brand_awareness": {
        "name": "Campaña de Brand Awareness",
        "steps": [
            "1. Analizar competencia",
            "2. Generar mensajes clave de marca",
            "3. Crear contenido visual consistente",
            "4. Generar videos de marca",
            "5. Optimizar para diferentes plataformas"
        ],
        "focus": "consistency",
        "content_types": ["visual_identity", "video", "social_content"]
    },
    "email_campaign": {
        "name": "Campaña de Email Marketing",
        "steps": [
            "1. Generar asunto de email",
            "2. Crear cuerpo del email",
            "3. Generar CTA (Call to Action)",
            "4. Crear imágenes para el email",
            "5. Optimizar para diferentes clientes de email"
        ],
        "components": ["subject", "body", "cta", "images"]
    }
}

# Templates de prompts para diferentes tipos de contenido
PROMPT_TEMPLATES = {
    "instagram_post": {
        "template": "Crea un post de Instagram sobre {topic} para {audience}. Tono: {tone}. Incluye un hook atractivo y un CTA claro.",
        "variables": ["topic", "audience", "tone"]
    },
    "twitter_post": {
        "template": "Crea un tweet sobre {topic}. Máximo 280 caracteres. Tono: {tone}. Incluye un hashtag relevante.",
        "variables": ["topic", "tone"]
    },
    "facebook_post": {
        "template": "Crea un post de Facebook sobre {topic} para {audience}. Tono: {tone}. Formato: párrafo corto con CTA.",
        "variables": ["topic", "audience", "tone"]
    },
    "linkedin_post": {
        "template": "Crea un post profesional de LinkedIn sobre {topic}. Tono profesional. Incluye insights o consejos valiosos.",
        "variables": ["topic"]
    },
    "email_subject": {
        "template": "Genera 5 opciones de asunto de email para: {topic}. Objetivo: {goal}. Tono: {tone}.",
        "variables": ["topic", "goal", "tone"]
    },
    "product_description": {
        "template": "Escribe una descripción de producto para {product_name}. Destaca: {features}. Audiencia: {audience}.",
        "variables": ["product_name", "features", "audience"]
    },
    "banner_prompt": {
        "template": "Crea un banner de marketing para {product}. Estilo: {style}. Incluye texto: {text}. Dimensiones: {width}x{height}.",
        "variables": ["product", "style", "text", "width", "height"]
    },
    "video_prompt": {
        "template": "Genera un video de marketing de {duration} segundos para {platform}. Tema: {topic}. Estilo: {style}.",
        "variables": ["duration", "platform", "topic", "style"]
    }
}

# Estilos predefinidos para imágenes
IMAGE_STYLES = {
    "modern": "moderno, limpio, contemporáneo, profesional, diseño minimalista",
    "bold": "colores vibrantes, llamativo, dinámico, audaz, alto contraste",
    "elegant": "elegante, sofisticado, refinado, lujo, premium",
    "minimalist": "minimalista, simple, espacios en blanco, limpio, esencial",
    "vibrant": "vibrante, colorido, energético, alegre, llamativo",
    "corporate": "corporativo, profesional, serio, confiable, empresarial",
    "creative": "creativo, artístico, único, innovador, original"
}

# Tono de voz para copy
VOICE_TONES = {
    "profesional": "profesional, formal, confiable, autoritativo",
    "casual": "casual, amigable, accesible, conversacional",
    "entusiasta": "entusiasta, energético, emocionante, apasionado",
    "educativo": "educativo, informativo, claro, didáctico",
    "humorístico": "humorístico, divertido, ligero, entretenido",
    "persuasivo": "persuasivo, convincente, motivador, inspirador"
}


def get_workflow(workflow_name: str) -> Dict[str, Any]:
    """
    Obtiene un workflow predefinido.
    
    Args:
        workflow_name: Nombre del workflow
    
    Returns:
        Dict con el workflow
    """
    return MARKETING_WORKFLOWS.get(workflow_name, {})


def get_prompt_template(template_name: str, **kwargs) -> str:
    """
    Obtiene un template de prompt con variables reemplazadas.
    
    Args:
        template_name: Nombre del template
        **kwargs: Variables para reemplazar en el template
    
    Returns:
        String con el prompt completo
    """
    template = PROMPT_TEMPLATES.get(template_name, {})
    template_str = template.get("template", "")
    
    # Reemplazar variables
    for key, value in kwargs.items():
        template_str = template_str.replace(f"{{{key}}}", str(value))
    
    return template_str


def get_image_style(style_name: str) -> str:
    """
    Obtiene la descripción de un estilo de imagen.
    
    Args:
        style_name: Nombre del estilo
    
    Returns:
        Descripción del estilo
    """
    return IMAGE_STYLES.get(style_name, IMAGE_STYLES["modern"])


def get_voice_tone(tone_name: str) -> str:
    """
    Obtiene la descripción de un tono de voz.
    
    Args:
        tone_name: Nombre del tono
    
    Returns:
        Descripción del tono
    """
    return VOICE_TONES.get(tone_name, VOICE_TONES["profesional"])


def list_all_workflows() -> List[str]:
    """Lista todos los workflows disponibles"""
    return list(MARKETING_WORKFLOWS.keys())


def list_all_templates() -> List[str]:
    """Lista todos los templates de prompts disponibles"""
    return list(PROMPT_TEMPLATES.keys())


def list_all_styles() -> List[str]:
    """Lista todos los estilos de imagen disponibles"""
    return list(IMAGE_STYLES.keys())


def list_all_tones() -> List[str]:
    """Lista todos los tonos de voz disponibles"""
    return list(VOICE_TONES.keys())









