"""
Registro de herramientas (tools) para Open WebUI
Este archivo registra las funciones como herramientas que el modelo LLM puede usar
"""

import os
import requests
from typing import Dict, Any, List
from .web_search import web_search, search_and_summarize, list_search_providers
from .image_generator import generate_image
from .functions import (
    generate_marketing_image_with_slogan,
    create_promotional_campaign_image
)

# Definir las herramientas disponibles para el modelo
TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "web_search",
            "description": "Busca información actualizada en internet. Úsala cuando necesites información reciente, noticias actuales, o datos que no están en el conocimiento del modelo.",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "El término de búsqueda o pregunta a buscar en internet"
                    },
                    "provider": {
                        "type": "string",
                        "enum": ["duckduckgo", "tavily"],
                        "default": "duckduckgo",
                        "description": "El proveedor de búsqueda a usar. DuckDuckGo no requiere API key."
                    },
                    "max_results": {
                        "type": "integer",
                        "default": 10,
                        "description": "Número máximo de resultados a retornar"
                    }
                },
                "required": ["query"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "search_and_summarize",
            "description": "Busca información en internet y retorna un resumen de los resultados. Úsala cuando necesites información actualizada y un resumen de múltiples fuentes.",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "El término de búsqueda o pregunta a buscar"
                    },
                    "provider": {
                        "type": "string",
                        "enum": ["duckduckgo", "tavily"],
                        "default": "duckduckgo",
                        "description": "El proveedor de búsqueda a usar"
                    },
                    "max_results": {
                        "type": "integer",
                        "default": 5,
                        "description": "Número máximo de resultados a incluir en el resumen"
                    }
                },
                "required": ["query"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "generate_image",
            "description": "Genera una imagen a partir de un texto (prompt) vía Draco/ComfyUI. Úsala cuando el usuario pida crear, generar o dibujar una imagen. Ejemplos: 'crea una imagen de un gato', 'genera un paisaje', 'dibuja un dragón'. Devuelve la imagen generada.",
            "parameters": {
                "type": "object",
                "properties": {
                    "prompt": {
                        "type": "string",
                        "description": "Descripción detallada de la imagen a generar (en español o inglés)"
                    },
                    "width": {
                        "type": "integer",
                        "default": 1024,
                        "description": "Ancho de la imagen en píxeles"
                    },
                    "height": {
                        "type": "integer",
                        "default": 1024,
                        "description": "Alto de la imagen en píxeles"
                    }
                },
                "required": ["prompt"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "execute_draco_flow",
            "description": "Ejecuta un flujo Draco. flow_id=image_generation para imágenes, web_search para búsqueda (vía Draco), learning para memoria. Para buscar en web suele ser mejor usar la herramienta web_search directamente.",
            "parameters": {
                "type": "object",
                "properties": {
                    "flow_id": {
                        "type": "string",
                        "enum": ["image_generation", "web_search", "learning"],
                        "description": "ID del flujo: image_generation (generar imagen), web_search (buscar en web), learning (guardar en memoria)"
                    },
                    "input": {
                        "type": "string",
                        "description": "Entrada del usuario: para image_generation es el prompt, para web_search es la consulta, para learning es lo que guardar"
                    }
                },
                "required": ["flow_id", "input"]
            }
        }
    }
]


def get_tools() -> List[Dict[str, Any]]:
    """
    Retorna la lista de herramientas disponibles para el modelo
    
    Returns:
        Lista de herramientas en formato OpenAI Function Calling
    """
    return TOOLS


def call_tool(name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
    """
    Ejecuta una herramienta por su nombre.
    web_search y search_and_summarize llaman al servicio web-search directamente (rápido y fiable).
    generate_image e execute_draco_flow usan Draco.
    """
    if name == "web_search":
        # Llamada directa al servicio web-search (sin Draco) para respuesta rápida y fiable
        result = web_search(
            query=arguments.get("query", ""),
            provider=arguments.get("provider", "duckduckgo"),
            max_results=arguments.get("max_results", 10),
        )
        return result
    elif name == "search_and_summarize":
        result = search_and_summarize(
            query=arguments.get("query", ""),
            provider=arguments.get("provider", "duckduckgo"),
            max_results=arguments.get("max_results", 5),
        )
        if result.get("success") and result.get("results"):
            parts = [f"{i}. {x.get('title','')}: {str(x.get('snippet',''))[:150]}..." for i, x in enumerate(result.get("results", [])[:5], 1)]
            result["summary"] = "\n".join(parts)
        return result
    elif name == "generate_image":
        result = _execute_draco_flow(
            flow_id="image_generation",
            input_text=arguments.get("prompt", ""),
            is_learning_flow=False,
        )
        if result.get("success") and result.get("result"):
            img_result = result["result"]
            if isinstance(img_result, dict) and img_result.get("success") and img_result.get("image_url"):
                return img_result
        return result if not result.get("success") else {"success": False, "error": "No se recibió imagen de Draco"}
    elif name == "execute_draco_flow":
        return _execute_draco_flow(
            flow_id=arguments.get("flow_id", "web_search"),
            input_text=arguments.get("input", ""),
            is_learning_flow=(arguments.get("flow_id") == "learning")
        )
    else:
        return {
            "success": False,
            "error": f"Herramienta desconocida: {name}"
        }


def _execute_draco_flow(
    flow_id: str,
    input_text: str,
    is_learning_flow: bool = False,
) -> Dict[str, Any]:
    """Call Draco Core API to execute a flow."""
    base_url = os.getenv("DRACO_CORE_URL", "http://draco-core:8000")
    try:
        resp = requests.post(
            f"{base_url.rstrip('/')}/flows/execute",
            json={
                "flow_id": flow_id,
                "input": {"input": input_text},
                "is_learning_flow": is_learning_flow,
            },
            timeout=120,
        )
        resp.raise_for_status()
        data = resp.json()
        if data.get("success"):
            return {"success": True, "result": data.get("result"), "execution_id": data.get("execution_id")}
        return {"success": False, "error": data.get("error", "Unknown error")}
    except requests.exceptions.RequestException as e:
        return {"success": False, "error": f"Draco Core no disponible: {str(e)}"}


__all__ = ['get_tools', 'call_tool', 'TOOLS']








