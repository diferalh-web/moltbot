"""
Integración con APIs externas (Gemini, Hugging Face)
"""

import os
import requests
from typing import Optional, Dict, Any

# URL del gateway (desde variable de entorno o default)
EXTERNAL_APIS_GATEWAY_URL = os.getenv("EXTERNAL_APIS_GATEWAY_URL", "http://localhost:5004")


def call_gemini(
    prompt: str,
    model: str = "gemini-pro",
    api_key: Optional[str] = None
) -> Dict[str, Any]:
    """
    Llama a la API de Google Gemini.
    
    Args:
        prompt: Texto del prompt
        model: Modelo a usar (default: gemini-pro)
        api_key: API key (opcional, usa variable de entorno si no se proporciona)
    
    Returns:
        Dict con 'success', 'response', o 'error'
    """
    try:
        if not prompt or not prompt.strip():
            return {
                "success": False,
                "error": "El prompt no puede estar vacío"
            }
        
        # Llamar al gateway
        url = f"{EXTERNAL_APIS_GATEWAY_URL}/api/gemini"
        
        payload = {
            "prompt": prompt,
            "model": model
        }
        
        if api_key:
            payload["api_key"] = api_key
        
        response = requests.post(url, json=payload, timeout=120)
        response.raise_for_status()
        
        result = response.json()
        
        if result.get("success"):
            return {
                "success": True,
                "response": result.get("response", ""),
                "model": result.get("model", model),
                "provider": "gemini"
            }
        else:
            return {
                "success": False,
                "error": result.get("error", "Error desconocido")
            }
            
    except requests.exceptions.RequestException as e:
        return {
            "success": False,
            "error": f"Error de conexión con el gateway de APIs: {str(e)}"
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Error inesperado: {str(e)}"
        }


def call_huggingface(
    model: str,
    prompt: str,
    api_key: Optional[str] = None
) -> Dict[str, Any]:
    """
    Llama a la API de Hugging Face Inference.
    
    Args:
        model: ID del modelo en Hugging Face (ej: "gpt2", "mistralai/Mistral-7B-Instruct-v0.2")
        prompt: Texto del prompt
        api_key: API key (opcional, usa variable de entorno si no se proporciona)
    
    Returns:
        Dict con 'success', 'response', o 'error'
    """
    try:
        if not model or not model.strip():
            return {
                "success": False,
                "error": "El modelo no puede estar vacío"
            }
        
        if not prompt or not prompt.strip():
            return {
                "success": False,
                "error": "El prompt no puede estar vacío"
            }
        
        # Llamar al gateway
        url = f"{EXTERNAL_APIS_GATEWAY_URL}/api/huggingface"
        
        payload = {
            "model": model,
            "prompt": prompt
        }
        
        if api_key:
            payload["api_key"] = api_key
        
        response = requests.post(url, json=payload, timeout=180)
        response.raise_for_status()
        
        result = response.json()
        
        if result.get("success"):
            return {
                "success": True,
                "response": result.get("response", ""),
                "model": result.get("model", model),
                "provider": "huggingface"
            }
        else:
            return {
                "success": False,
                "error": result.get("error", "Error desconocido")
            }
            
    except requests.exceptions.RequestException as e:
        return {
            "success": False,
            "error": f"Error de conexión con el gateway de APIs: {str(e)}"
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Error inesperado: {str(e)}"
        }


def list_available_providers() -> Dict[str, Any]:
    """
    Lista los proveedores de APIs externas disponibles.
    
    Returns:
        Dict con lista de proveedores
    """
    try:
        url = f"{EXTERNAL_APIS_GATEWAY_URL}/api/providers"
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        return response.json()
        
    except requests.exceptions.RequestException as e:
        return {
            "success": False,
            "error": f"Error al listar proveedores: {str(e)}"
        }









