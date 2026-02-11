"""
Funciones personalizadas para Open WebUI
Este archivo define las funciones que el modelo LLM puede usar directamente
"""

from typing import Dict, Any, Optional
from .image_generator import (
    generate_image,
    generate_marketing_image,
    generate_banner,
    generate_social_media_image
)
from .marketing_tools import (
    generate_marketing_copy,
    generate_hashtags,
    analyze_competitor,
    create_campaign_brief
)
from .web_search import (
    web_search,
    search_and_summarize,
    list_search_providers
)


def generate_marketing_image_with_slogan(
    product_description: str,
    slogan: str,
    platform: str = "instagram_square",
    style: str = "modern"
) -> Dict[str, Any]:
    """
    Genera una imagen promocional con un lema/slogan para una campaña publicitaria.
    
    Args:
        product_description: Descripción del producto o tema de la campaña
        slogan: El lema o slogan a incluir en la imagen
        platform: Plataforma de redes sociales (instagram_square, facebook_post, twitter_post, etc.)
        style: Estilo de la imagen (modern, classic, minimalist, bold, elegant)
    
    Returns:
        Dict con 'success', 'image_url' o 'error'
    """
    # Crear un prompt mejorado que incluya el slogan
    enhanced_prompt = f"{product_description}. Include the slogan: '{slogan}'. Marketing promotional image, professional design, {style} style, high quality"
    
    # Usar la función de generación de imágenes para redes sociales
    return generate_social_media_image(
        prompt=enhanced_prompt,
        platform=platform,
        use_comfyui=False  # Usar Flux por defecto
    )


def create_promotional_campaign_image(
    campaign_theme: str,
    tagline: str,
    target_audience: str = "general",
    image_type: str = "banner"
) -> Dict[str, Any]:
    """
    Crea una imagen promocional completa para una campaña publicitaria con lema.
    
    Args:
        campaign_theme: Tema o concepto de la campaña
        tagline: Lema o tagline de la campaña
        target_audience: Audiencia objetivo (general, youth, professionals, etc.)
        image_type: Tipo de imagen (banner, social_media, square, vertical)
    
    Returns:
        Dict con la imagen generada y metadata
    """
    # Construir prompt completo
    style_hints = {
        "general": "professional, appealing, universal",
        "youth": "vibrant, energetic, modern, bold colors",
        "professionals": "sophisticated, clean, corporate, elegant",
        "general": "balanced, attractive, clear messaging"
    }
    
    style_hint = style_hints.get(target_audience, style_hints["general"])
    
    full_prompt = f"Promotional campaign image: {campaign_theme}. Tagline: '{tagline}'. Style: {style_hint}. Marketing material, high quality, professional design"
    
    # Seleccionar función según tipo
    if image_type == "banner":
        return generate_banner(
            prompt=full_prompt,
            size="standard",
            model="flux"
        )
    elif image_type == "social_media":
        return generate_social_media_image(
            prompt=full_prompt,
            platform="instagram_square",
            use_comfyui=False
        )
    else:
        # Imagen estándar
        return generate_marketing_image(
            prompt=full_prompt,
            style="modern",
            model="flux"
        )


# Exportar todas las funciones disponibles
__all__ = [
    'generate_marketing_image_with_slogan',
    'create_promotional_campaign_image',
    'generate_marketing_image',
    'generate_banner',
    'generate_social_media_image',
    'generate_marketing_copy',
    'generate_hashtags',
    'analyze_competitor',
    'create_campaign_brief',
    # Funciones de búsqueda web
    'web_search',
    'search_and_summarize',
    'list_search_providers'
]

