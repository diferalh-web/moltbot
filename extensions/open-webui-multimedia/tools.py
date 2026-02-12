"""
Registro de herramientas (tools) para Open WebUI
Este archivo registra las funciones como herramientas que el modelo LLM puede usar
"""

import os
import sys
import requests
from typing import Dict, Any, List

# Instrumentación: confirmar que la extensión se carga (visible en docker logs open-webui)
def _diag_log(msg: str, **kwargs) -> None:
    out = f"[WEBUI-DRACO] {msg}"
    if kwargs:
        try:
            import json
            out += " " + json.dumps(kwargs, ensure_ascii=False)
        except Exception:
            pass
    try:
        print(out, flush=True)
    except Exception:
        pass
    try:
        import logging
        log = logging.getLogger("open_webui")
        if log and getattr(log, "handlers", None):
            log.info(out)
    except Exception:
        pass

try:
    _diag_log("tools.py module loaded")
except Exception:
    pass
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
            "description": "Busca rápida en internet (listado de resultados). Para preguntas de 'precio de hoy', 'precio actual', cotización o acciones (NVDA, TSLA, etc.) NO uses web_search; usa deep_search en su lugar. Úsala solo para búsquedas genéricas o noticias cuando no se pida un dato numérico actual.",
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
            "name": "deep_search",
            "description": "Búsqueda profunda: primero se interpreta tu consulta (aclarando tema, tickers, fechas) y luego se busca y consolida. Sirve para cualquier tema: acciones, noticias, ciencia, etc. Pasa la pregunta del usuario tal cual en query; el flujo la refina internamente antes de buscar.",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "La pregunta o petición del usuario tal como la formuló (ej. 'precio de Meta al cierre de hoy', 'cómo ha variado el precio en los últimos 12 meses'). No hace falta reescribirla; el sistema la interpreta antes de buscar."
                    },
                    "max_rounds": {
                        "type": "integer",
                        "default": 2,
                        "description": "Número máximo de rondas de búsqueda (por defecto 2)"
                    }
                },
                "required": ["query"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "execute_draco_flow",
            "description": "Ejecuta un flujo Draco. flow_id=image_generation para imágenes, web_search para búsqueda (vía Draco), deep_search para búsqueda profunda, learning para memoria. Para buscar en web suele ser mejor usar web_search (rápido) o deep_search (profundo con fuentes).",
            "parameters": {
                "type": "object",
                "properties": {
                    "flow_id": {
                        "type": "string",
                        "enum": ["image_generation", "web_search", "deep_search", "learning"],
                        "description": "ID del flujo: image_generation (generar imagen), web_search (buscar en web), deep_search (búsqueda profunda con fuentes), learning (guardar en memoria)"
                    },
                    "input": {
                        "type": "string",
                        "description": "Entrada del usuario: para image_generation es el prompt, para web_search/deep_search es la consulta, para learning es lo que guardar"
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
    # Instrumentación: comprobar si Open WebUI pide nuestras herramientas
    _debug_log("get_tools called", {"count": len(TOOLS), "names": [t.get("function", {}).get("name") for t in TOOLS]})
    return TOOLS


def _debug_log(message: str, data: dict) -> None:
    _diag_log(message, **data)


def call_tool(name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
    """
    Ejecuta una herramienta por su nombre.
    web_search y search_and_summarize llaman al servicio web-search directamente (rápido y fiable).
    generate_image e execute_draco_flow usan Draco.
    """
    # #region agent log
    if name in ("deep_search", "execute_draco_flow", "generate_image"):
        _debug_log("call_tool invoked", {"name": name, "arguments_keys": list(arguments.keys()) if isinstance(arguments, dict) else []})
    # #endregion
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
    elif name == "deep_search":
        query = (arguments.get("query") or "").strip()
        _debug_log("deep_search query", {"query": query, "len": len(query)})
        return _execute_draco_flow(
            flow_id="deep_search",
            input_text=query,
            is_learning_flow=False,
        )
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
    api_token = os.getenv("DRACO_API_TOKEN", "")
    url = f"{base_url.rstrip('/')}/flows/execute"
    # #region agent log
    _debug_log("draco_request", {"base_url": base_url, "url": url, "flow_id": flow_id, "input_len": len(input_text or "")})
    # #endregion
    headers = {"Content-Type": "application/json"}
    if api_token:
        headers["Authorization"] = f"Bearer {api_token}"
    try:
        resp = requests.post(
            url,
            json={
                "flow_id": flow_id,
                "input": {"input": input_text},
                "is_learning_flow": is_learning_flow,
            },
            headers=headers,
            timeout=120,
        )
        # #region agent log
        _debug_log("draco_response", {"status_code": resp.status_code, "success": resp.status_code == 200})
        # #endregion
        resp.raise_for_status()
        data = resp.json()
        if data.get("success"):
            return {"success": True, "result": data.get("result"), "execution_id": data.get("execution_id")}
        return {"success": False, "error": data.get("error", "Unknown error")}
    except requests.exceptions.RequestException as e:
        # #region agent log
        _debug_log("draco_error", {"error": str(e)})
        # #endregion
        return {"success": False, "error": f"Draco Core no disponible: {str(e)}"}


__all__ = ['get_tools', 'call_tool', 'TOOLS']








