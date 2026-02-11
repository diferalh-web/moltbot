"""
Clonación de voz usando XTTS (Coqui TTS)
"""

import os
import requests
from typing import Optional, Dict, Any
import base64

# URL del servicio (desde variable de entorno o default)
COQUI_TTS_API_URL = os.getenv("TTS_API_URL", "http://localhost:5002")


def clone_voice(
    text: str,
    reference_audio: Optional[str] = None,
    reference_audio_path: Optional[str] = None,
    language: str = "es"
) -> Dict[str, Any]:
    """
    Clona una voz usando XTTS.
    
    Args:
        text: Texto a generar con la voz clonada
        reference_audio: Audio de referencia en base64 o URL
        reference_audio_path: Ruta local al audio de referencia (alternativa)
        language: Idioma del texto ("es", "en", "fr", "de", etc.)
    
    Returns:
        Dict con 'success', 'audio_data' (base64), o 'error'
    """
    try:
        if not text or not text.strip():
            return {
                "success": False,
                "error": "El texto no puede estar vacío"
            }
        
        if not reference_audio and not reference_audio_path:
            return {
                "success": False,
                "error": "Se requiere reference_audio o reference_audio_path"
            }
        
        # Preparar payload
        payload = {
            "text": text,
            "language": language
        }
        
        if reference_audio:
            payload["reference_audio"] = reference_audio
        if reference_audio_path:
            payload["reference_audio_path"] = reference_audio_path
        
        # Llamar a la API de clonación
        url = f"{COQUI_TTS_API_URL}/api/clone-voice"
        
        response = requests.post(url, json=payload, timeout=300)
        response.raise_for_status()
        
        # Coqui TTS retorna el audio directamente
        if response.headers.get('content-type', '').startswith('audio/'):
            # Audio en formato binario
            audio_data = response.content
            
            # Convertir a base64 para fácil transmisión
            audio_base64 = base64.b64encode(audio_data).decode('utf-8')
            
            return {
                "success": True,
                "audio_data": audio_base64,
                "audio_format": "wav",
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


def clone_voice_from_file(
    text: str,
    audio_file_path: str,
    language: str = "es"
) -> Dict[str, Any]:
    """
    Clona una voz desde un archivo de audio local.
    
    Args:
        text: Texto a generar
        audio_file_path: Ruta al archivo de audio de referencia
        language: Idioma del texto
    
    Returns:
        Dict con resultado de la clonación
    """
    return clone_voice(
        text=text,
        reference_audio_path=audio_file_path,
        language=language
    )


def clone_voice_from_url(
    text: str,
    audio_url: str,
    language: str = "es"
) -> Dict[str, Any]:
    """
    Clona una voz desde una URL de audio.
    
    Args:
        text: Texto a generar
        audio_url: URL del audio de referencia
        language: Idioma del texto
    
    Returns:
        Dict con resultado de la clonación
    """
    return clone_voice(
        text=text,
        reference_audio=audio_url,
        language=language
    )


def is_voice_cloning_available() -> bool:
    """
    Verifica si la clonación de voz está disponible.
    
    Returns:
        True si está disponible, False en caso contrario
    """
    try:
        url = f"{COQUI_TTS_API_URL}/api/models"
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        result = response.json()
        return result.get("voice_cloning_available", False)
        
    except Exception:
        return False









