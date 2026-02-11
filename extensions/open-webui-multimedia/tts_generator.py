"""
Generador de síntesis de voz usando Coqui TTS
"""

import os
import requests
from typing import Optional, Dict, Any
import io

# URL del servicio (desde variable de entorno o default)
COQUI_TTS_API_URL = os.getenv("TTS_API_URL", "http://localhost:5002")


def text_to_speech(
    text: str,
    language: str = "es",
    voice: str = "default",
    output_format: str = "wav"
) -> Dict[str, Any]:
    """
    Genera audio a partir de texto usando Coqui TTS.
    
    Args:
        text: Texto a convertir en voz
        language: Idioma ("es" para español, "en" para inglés)
        voice: Voz específica a usar
        output_format: Formato de salida ("wav", "mp3")
    
    Returns:
        Dict con 'success', 'audio_url' o 'audio_data' (base64), o 'error'
    """
    try:
        if not text or not text.strip():
            return {
                "success": False,
                "error": "El texto no puede estar vacío"
            }
        
        # Llamar a la API de Coqui TTS
        url = f"{COQUI_TTS_API_URL}/api/tts"
        
        payload = {
            "text": text,
            "language": language,
            "voice": voice
        }
        
        response = requests.post(url, json=payload, timeout=120)
        response.raise_for_status()
        
        # Coqui TTS retorna el audio directamente
        if response.headers.get('content-type', '').startswith('audio/'):
            # Audio en formato binario
            audio_data = response.content
            
            # Convertir a base64 para fácil transmisión
            import base64
            audio_base64 = base64.b64encode(audio_data).decode('utf-8')
            
            return {
                "success": True,
                "audio_data": audio_base64,
                "audio_format": output_format,
                "text": text,
                "language": language,
                "size_bytes": len(audio_data)
            }
        else:
            # Respuesta JSON con error
            result = response.json()
            return {
                "success": False,
                "error": result.get("error", "Error desconocido")
            }
            
    except requests.exceptions.RequestException as e:
        return {
            "success": False,
            "error": f"Error de conexión con Coqui TTS: {str(e)}"
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Error inesperado: {str(e)}"
        }


def list_available_voices() -> Dict[str, Any]:
    """
    Lista las voces disponibles en Coqui TTS.
    
    Returns:
        Dict con lista de voces disponibles
    """
    try:
        url = f"{COQUI_TTS_API_URL}/api/models"
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        return response.json()
        
    except requests.exceptions.RequestException as e:
        return {
            "success": False,
            "error": f"Error al listar voces: {str(e)}"
        }












