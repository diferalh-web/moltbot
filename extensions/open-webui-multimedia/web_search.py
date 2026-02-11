"""
Búsqueda web usando DuckDuckGo y Tavily
"""

import os
import requests
from typing import Optional, Dict, Any, List

# URL del servicio (desde variable de entorno o default)
WEB_SEARCH_API_URL = os.getenv("WEB_SEARCH_API_URL", "http://localhost:5003")


def web_search(
    query: str,
    provider: str = "duckduckgo",
    max_results: int = 10
) -> Dict[str, Any]:
    """
    Busca información en la web.
    
    Args:
        query: Término de búsqueda
        provider: Proveedor a usar ("duckduckgo" o "tavily")
        max_results: Número máximo de resultados
    
    Returns:
        Dict con 'success', 'results' (lista de resultados), o 'error'
    """
    try:
        if not query or not query.strip():
            return {
                "success": False,
                "error": "La consulta de búsqueda no puede estar vacía"
            }
        
        # Llamar a la API de búsqueda web
        url = f"{WEB_SEARCH_API_URL}/api/search"
        
        payload = {
            "query": query,
            "provider": provider,
            "max_results": max_results
        }
        
        response = requests.post(url, json=payload, timeout=60)
        response.raise_for_status()
        
        result = response.json()
        
        if result.get("success"):
            return {
                "success": True,
                "query": query,
                "provider": result.get("provider", provider),
                "results": result.get("results", []),
                "count": result.get("count", 0)
            }
        else:
            return {
                "success": False,
                "error": result.get("error", "Error desconocido en la búsqueda")
            }
            
    except requests.exceptions.RequestException as e:
        return {
            "success": False,
            "error": f"Error de conexión con el servicio de búsqueda web: {str(e)}"
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Error inesperado: {str(e)}"
        }


def list_search_providers() -> Dict[str, Any]:
    """
    Lista los proveedores de búsqueda disponibles.
    
    Returns:
        Dict con lista de proveedores
    """
    try:
        url = f"{WEB_SEARCH_API_URL}/api/providers"
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        return response.json()
        
    except requests.exceptions.RequestException as e:
        return {
            "success": False,
            "error": f"Error al listar proveedores: {str(e)}"
        }


def search_and_summarize(
    query: str,
    provider: str = "duckduckgo",
    max_results: int = 5
) -> Dict[str, Any]:
    """
    Busca información y retorna un resumen de los resultados.
    
    Args:
        query: Término de búsqueda
        provider: Proveedor a usar
        max_results: Número máximo de resultados
    
    Returns:
        Dict con resumen de los resultados
    """
    search_result = web_search(query, provider, max_results)
    
    if not search_result.get("success"):
        return search_result
    
    results = search_result.get("results", [])
    
    # Crear resumen
    summary_parts = []
    for i, result in enumerate(results[:max_results], 1):
        summary_parts.append(
            f"{i}. {result.get('title', 'Sin título')}\n"
            f"   {result.get('snippet', 'Sin descripción')}\n"
            f"   Fuente: {result.get('url', 'N/A')}\n"
        )
    
    summary = "\n".join(summary_parts)
    
    return {
        "success": True,
        "query": query,
        "provider": search_result.get("provider"),
        "summary": summary,
        "results": results,
        "count": len(results)
    }









