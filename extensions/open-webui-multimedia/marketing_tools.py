"""
Herramientas especializadas para marketing
Incluye generación de copy, hashtags, análisis de competencia y briefs de campaña
"""

from typing import Dict, Any, List, Optional
import os

# Importar otras extensiones para integración
from .web_search import web_search, search_and_summarize


# Templates predefinidos para diferentes tipos de marketing
MARKETING_TEMPLATES = {
    "social_media_post": {
        "structure": "Hook + Value + CTA",
        "tone_options": ["profesional", "casual", "entusiasta", "educativo", "humorístico"]
    },
    "email_campaign": {
        "structure": "Asunto + Saludo + Cuerpo + CTA + Cierre",
        "tone_options": ["formal", "amigable", "persuasivo", "informativo"]
    },
    "landing_page": {
        "structure": "Headline + Subheadline + Beneficios + Testimonios + CTA",
        "tone_options": ["convincente", "claro", "emocional", "profesional"]
    },
    "product_description": {
        "structure": "Título + Características + Beneficios + Especificaciones",
        "tone_options": ["técnico", "comercial", "descriptivo"]
    }
}

# Dimensiones de redes sociales
SOCIAL_MEDIA_DIMENSIONS = {
    "instagram_post": {"width": 1080, "height": 1080},
    "instagram_story": {"width": 1080, "height": 1920},
    "twitter": {"width": 1200, "height": 675},
    "facebook_post": {"width": 1200, "height": 630},
    "facebook_cover": {"width": 1200, "height": 628},
    "linkedin_post": {"width": 1200, "height": 627},
    "linkedin_cover": {"width": 1584, "height": 396},
    "youtube_thumbnail": {"width": 1280, "height": 720}
}


def generate_marketing_copy(
    product: str,
    audience: str,
    tone: str = "profesional",
    template_type: str = "social_media_post"
) -> Dict[str, Any]:
    """
    Genera copy de marketing para un producto.
    
    Args:
        product: Nombre o descripción del producto
        audience: Audiencia objetivo
        tone: Tono del copy (profesional, casual, entusiasta, etc.)
        template_type: Tipo de template a usar
    
    Returns:
        Dict con el copy generado
    """
    try:
        template = MARKETING_TEMPLATES.get(template_type, MARKETING_TEMPLATES["social_media_post"])
        
        # Construir prompt para el LLM
        prompt = f"""Genera copy de marketing para el siguiente producto:

Producto: {product}
Audiencia: {audience}
Tono: {tone}
Tipo: {template_type}
Estructura sugerida: {template.get('structure', '')}

Genera un copy atractivo y efectivo que:
1. Capture la atención de la audiencia objetivo
2. Comunique claramente el valor del producto
3. Incluya un llamado a la acción claro
4. Use el tono especificado

Copy:"""
        
        return {
            "success": True,
            "product": product,
            "audience": audience,
            "tone": tone,
            "template_type": template_type,
            "prompt": prompt,
            "note": "Este prompt debe ser enviado a un LLM para generar el copy final"
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Error generando copy: {str(e)}"
        }


def generate_hashtags(
    topic: str,
    platform: str = "instagram",
    count: int = 10
) -> Dict[str, Any]:
    """
    Genera hashtags optimizados para una plataforma.
    
    Args:
        topic: Tema o palabra clave
        platform: Plataforma (instagram, twitter, linkedin, tiktok)
        count: Número de hashtags a generar
    
    Returns:
        Dict con lista de hashtags
    """
    try:
        # Estrategias por plataforma
        platform_strategies = {
            "instagram": {
                "mix": "mezcla de populares y nicho",
                "max_count": 30,
                "note": "Instagram permite hasta 30 hashtags"
            },
            "twitter": {
                "mix": "hashtags relevantes y trending",
                "max_count": 3,
                "note": "Twitter funciona mejor con pocos hashtags"
            },
            "linkedin": {
                "mix": "profesionales y de industria",
                "max_count": 5,
                "note": "LinkedIn prefiere hashtags profesionales"
            },
            "tiktok": {
                "mix": "trending y relacionados",
                "max_count": 5,
                "note": "TikTok usa hashtags trending"
            }
        }
        
        strategy = platform_strategies.get(platform, platform_strategies["instagram"])
        
        prompt = f"""Genera {count} hashtags para el tema "{topic}" optimizados para {platform}.

Estrategia: {strategy.get('mix', '')}
Nota: {strategy.get('note', '')}

Hashtags:"""
        
        return {
            "success": True,
            "topic": topic,
            "platform": platform,
            "count": count,
            "prompt": prompt,
            "strategy": strategy,
            "note": "Este prompt debe ser enviado a un LLM para generar los hashtags finales"
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Error generando hashtags: {str(e)}"
        }


def analyze_competitor(
    url: str,
    max_results: int = 10
) -> Dict[str, Any]:
    """
    Analiza un competidor usando búsqueda web.
    
    Args:
        url: URL del competidor
        max_results: Número máximo de resultados de búsqueda
    
    Returns:
        Dict con análisis del competidor
    """
    try:
        # Buscar información sobre el competidor
        search_query = f"site:{url} marketing strategy products services"
        search_result = web_search(search_query, max_results=max_results)
        
        if not search_result.get("success"):
            return search_result
        
        # Crear resumen del análisis
        results = search_result.get("results", [])
        
        analysis = {
            "url": url,
            "search_results_count": len(results),
            "top_results": results[:5],
            "summary": f"Se encontraron {len(results)} resultados relacionados con {url}"
        }
        
        return {
            "success": True,
            "competitor_url": url,
            "analysis": analysis,
            "results": results
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Error analizando competidor: {str(e)}"
        }


def create_campaign_brief(
    product: str,
    goals: List[str],
    target_audience: str,
    budget: Optional[str] = None,
    timeline: Optional[str] = None
) -> Dict[str, Any]:
    """
    Crea un brief de campaña estructurado.
    
    Args:
        product: Producto o servicio
        goals: Lista de objetivos de la campaña
        target_audience: Audiencia objetivo
        budget: Presupuesto (opcional)
        timeline: Timeline de la campaña (opcional)
    
    Returns:
        Dict con el brief de campaña
    """
    try:
        brief = {
            "product": product,
            "goals": goals,
            "target_audience": target_audience,
            "budget": budget or "No especificado",
            "timeline": timeline or "No especificado",
            "sections": {
                "overview": f"Campaña de marketing para {product}",
                "objectives": goals,
                "target_audience": target_audience,
                "key_messages": [],
                "channels": [],
                "content_types": [],
                "metrics": []
            }
        }
        
        # Generar sugerencias de contenido
        content_suggestions = [
            "Posts en redes sociales",
            "Imágenes promocionales",
            "Videos cortos",
            "Email marketing",
            "Landing page"
        ]
        
        brief["sections"]["content_types"] = content_suggestions
        
        return {
            "success": True,
            "brief": brief,
            "note": "Este es un brief base. Debe ser completado con más detalles específicos."
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Error creando brief: {str(e)}"
        }


def get_social_media_dimensions(platform: str, content_type: str = "post") -> Dict[str, Any]:
    """
    Obtiene las dimensiones recomendadas para una plataforma de redes sociales.
    
    Args:
        platform: Plataforma (instagram, twitter, facebook, linkedin, youtube)
        content_type: Tipo de contenido (post, story, cover, thumbnail)
    
    Returns:
        Dict con dimensiones
    """
    key = f"{platform}_{content_type}"
    dimensions = SOCIAL_MEDIA_DIMENSIONS.get(key)
    
    if dimensions:
        return {
            "success": True,
            "platform": platform,
            "content_type": content_type,
            "dimensions": dimensions
        }
    else:
        # Retornar dimensiones por defecto
        return {
            "success": True,
            "platform": platform,
            "content_type": content_type,
            "dimensions": {"width": 1200, "height": 1200},
            "note": "Dimensiones por defecto. Verifica las especificaciones de la plataforma."
        }


def get_marketing_templates() -> Dict[str, Any]:
    """
    Retorna todos los templates de marketing disponibles.
    
    Returns:
        Dict con templates
    """
    return {
        "success": True,
        "templates": MARKETING_TEMPLATES,
        "social_media_dimensions": SOCIAL_MEDIA_DIMENSIONS
    }









