"""
Generador de imágenes usando Flux (Ollama) y ComfyUI
Incluye funciones especializadas para marketing
"""

import os
import requests
import json
from typing import Optional, Dict, Any

# URLs de los servicios (desde variables de entorno o defaults)
FLUX_API_URL = os.getenv("FLUX_API_URL", "http://localhost:11439")
COMFYUI_API_URL = os.getenv("IMAGE_GENERATION_API_URL", "http://localhost:7860")

# Importar herramientas de marketing para dimensiones
from .marketing_tools import get_social_media_dimensions, SOCIAL_MEDIA_DIMENSIONS
from .comfyui_workflow import generate_image_via_comfyui


def generate_image(
    prompt: str,
    model: str = "flux",
    width: int = 1024,
    height: int = 1024,
    num_steps: int = 50,
    use_comfyui: bool = False
) -> Dict[str, Any]:
    """
    Genera una imagen a partir de un prompt de texto.
    
    Args:
        prompt: Descripción de la imagen a generar
        model: Modelo a usar ("flux" para Ollama, "comfyui" para ComfyUI)
        width: Ancho de la imagen
        height: Alto de la imagen
        num_steps: Número de pasos de generación
        use_comfyui: Si True, usa ComfyUI en lugar de Ollama-Flux
    
    Returns:
        Dict con 'success', 'image_url' o 'error'
    """
    try:
        if use_comfyui or model == "comfyui":
            return _generate_with_comfyui(prompt, width, height, num_steps)
        else:
            return _generate_with_flux(prompt, width, height, num_steps)
    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }


def _generate_with_flux(
    prompt: str,
    width: int,
    height: int,
    num_steps: int
) -> Dict[str, Any]:
    """Genera imagen usando Ollama-Flux"""
    try:
        # Ollama API para generación de imágenes
        url = f"{FLUX_API_URL}/api/generate"
        
        payload = {
            "model": "flux",
            "prompt": prompt,
            "stream": False,
            "options": {
                "width": width,
                "height": height,
                "num_steps": num_steps
            }
        }
        
        response = requests.post(url, json=payload, timeout=300)
        response.raise_for_status()
        
        result = response.json()
        
        # Ollama puede retornar la imagen en base64 o como URL
        if "image" in result:
            return {
                "success": True,
                "image_url": result["image"],
                "model": "flux",
                "prompt": prompt
            }
        else:
            return {
                "success": False,
                "error": "No se recibió imagen en la respuesta"
            }
            
    except requests.exceptions.RequestException as e:
        return {
            "success": False,
            "error": f"Error de conexión con Ollama-Flux: {str(e)}"
        }


def _generate_with_comfyui(
    prompt: str,
    width: int,
    height: int,
    num_steps: int
) -> Dict[str, Any]:
    """Genera imagen usando la API real de ComfyUI (workflow Flux/text-to-image)."""
    return generate_image_via_comfyui(
        prompt=prompt,
        width=width,
        height=height,
        steps=num_steps,
        checkpoint_name=None,
    )


def generate_marketing_image(
    prompt: str,
    style: str = "modern",
    dimensions: Optional[Dict[str, int]] = None,
    model: str = "flux"
) -> Dict[str, Any]:
    """
    Genera una imagen con estilo de marketing.
    
    Args:
        prompt: Descripción de la imagen
        style: Estilo (modern, classic, minimalist, bold, elegant)
        dimensions: Dimensiones personalizadas {"width": int, "height": int}
        model: Modelo a usar ("flux" o "comfyui")
    
    Returns:
        Dict con la imagen generada
    """
    try:
        # Mejorar el prompt con el estilo
        style_prompts = {
            "modern": "modern, clean design, contemporary style, professional",
            "classic": "classic design, timeless, elegant, traditional",
            "minimalist": "minimalist design, simple, clean, white space",
            "bold": "bold colors, vibrant, eye-catching, dynamic",
            "elegant": "elegant design, sophisticated, refined, luxury"
        }
        
        style_addition = style_prompts.get(style, style_prompts["modern"])
        enhanced_prompt = f"{prompt}, {style_addition}, marketing material, high quality"
        
        # Usar dimensiones proporcionadas o por defecto
        width = dimensions.get("width", 1200) if dimensions else 1200
        height = dimensions.get("height", 1200) if dimensions else 1200
        
        return generate_image(
            prompt=enhanced_prompt,
            model=model,
            width=width,
            height=height,
            use_comfyui=(model == "comfyui")
        )
    except Exception as e:
        return {
            "success": False,
            "error": f"Error generando imagen de marketing: {str(e)}"
        }


def generate_banner(
    prompt: str,
    size: str = "standard",
    model: str = "flux"
) -> Dict[str, Any]:
    """
    Genera un banner de marketing.
    
    Args:
        prompt: Descripción del banner
        size: Tamaño (standard: 1920x1080, wide: 2560x1440, square: 1080x1080)
        model: Modelo a usar
    
    Returns:
        Dict con el banner generado
    """
    try:
        size_dimensions = {
            "standard": {"width": 1920, "height": 1080},
            "wide": {"width": 2560, "height": 1440},
            "square": {"width": 1080, "height": 1080},
            "vertical": {"width": 1080, "height": 1920}
        }
        
        dimensions = size_dimensions.get(size, size_dimensions["standard"])
        
        # Mejorar prompt para banner
        banner_prompt = f"banner design, {prompt}, marketing banner, professional, eye-catching, high quality"
        
        return generate_image(
            prompt=banner_prompt,
            model=model,
            width=dimensions["width"],
            height=dimensions["height"],
            use_comfyui=(model == "comfyui")
        )
    except Exception as e:
        return {
            "success": False,
            "error": f"Error generando banner: {str(e)}"
        }


def generate_social_media_image(
    prompt: str,
    platform: str = "instagram",
    content_type: str = "post",
    model: str = "flux"
) -> Dict[str, Any]:
    """
    Genera una imagen optimizada para redes sociales.
    
    Args:
        prompt: Descripción de la imagen
        platform: Plataforma (instagram, twitter, facebook, linkedin, youtube)
        content_type: Tipo de contenido (post, story, cover, thumbnail)
        model: Modelo a usar
    
    Returns:
        Dict con la imagen generada
    """
    try:
        # Obtener dimensiones de la plataforma
        dims_result = get_social_media_dimensions(platform, content_type)
        dimensions = dims_result.get("dimensions", {"width": 1200, "height": 1200})
        
        # Mejorar prompt para redes sociales
        platform_styles = {
            "instagram": "Instagram style, vibrant colors, engaging, social media",
            "twitter": "Twitter style, clean, professional, social media",
            "facebook": "Facebook style, friendly, approachable, social media",
            "linkedin": "LinkedIn style, professional, business, corporate",
            "youtube": "YouTube thumbnail style, eye-catching, bold text, thumbnail"
        }
        
        style_addition = platform_styles.get(platform, "social media style, engaging")
        enhanced_prompt = f"{prompt}, {style_addition}, optimized for {platform} {content_type}, high quality"
        
        return generate_image(
            prompt=enhanced_prompt,
            model=model,
            width=dimensions["width"],
            height=dimensions["height"],
            use_comfyui=(model == "comfyui")
        )
    except Exception as e:
        return {
            "success": False,
            "error": f"Error generando imagen para redes sociales: {str(e)}"
        }


