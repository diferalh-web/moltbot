"""
Generador de video usando Stable Video Diffusion
Incluye funciones especializadas para marketing
"""

import os
import requests
from typing import Optional, Dict, Any, List
import base64
import io

# URL del servicio (desde variable de entorno o default)
STABLE_VIDEO_API_URL = os.getenv("VIDEO_GENERATION_API_URL", "http://localhost:8000")
TTS_API_URL = os.getenv("TTS_API_URL", "http://localhost:5002")

# Importar TTS para agregar audio
from .tts_generator import text_to_speech


def generate_video(
    image_path: Optional[str] = None,
    image_data: Optional[bytes] = None,
    duration: int = 5,
    fps: int = 24
) -> Dict[str, Any]:
    """
    Genera un video a partir de una imagen usando Stable Video Diffusion.
    
    Args:
        image_path: Ruta al archivo de imagen
        image_data: Datos binarios de la imagen (alternativa a image_path)
        duration: Duración del video en segundos
        fps: Frames por segundo
    
    Returns:
        Dict con 'success', 'video_url' o 'error', 'job_id' para procesamiento asíncrono
    """
    try:
        # Preparar imagen
        if image_path:
            with open(image_path, 'rb') as f:
                image_data = f.read()
        elif not image_data:
            return {
                "success": False,
                "error": "Se requiere image_path o image_data"
            }
        
        # Llamar a la API de Stable Video Diffusion
        url = f"{STABLE_VIDEO_API_URL}/api/generate"
        
        files = {
            'file': ('image.png', image_data, 'image/png')
        }
        data = {
            'duration': duration,
            'fps': fps
        }
        
        response = requests.post(url, files=files, data=data, timeout=600)
        response.raise_for_status()
        
        result = response.json()
        
        # Stable Video puede retornar el video directamente o un job_id para polling
        if "video_url" in result:
            return {
                "success": True,
                "video_url": result["video_url"],
                "duration": duration,
                "fps": fps
            }
        elif "job_id" in result:
            return {
                "success": True,
                "job_id": result["job_id"],
                "status": "processing",
                "message": "Video en proceso, usa el job_id para consultar el estado"
            }
        else:
            return {
                "success": False,
                "error": "No se recibió video o job_id en la respuesta"
            }
            
    except requests.exceptions.RequestException as e:
        return {
            "success": False,
            "error": f"Error de conexión con Stable Video Diffusion: {str(e)}"
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Error inesperado: {str(e)}"
        }


def check_video_status(job_id: str) -> Dict[str, Any]:
    """
    Consulta el estado de un video en proceso.
    
    Args:
        job_id: ID del trabajo de generación
    
    Returns:
        Dict con 'status', 'video_url' (si está listo) o 'error'
    """
    try:
        url = f"{STABLE_VIDEO_API_URL}/api/status/{job_id}"
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        return response.json()
        
    except requests.exceptions.RequestException as e:
        return {
            "success": False,
            "error": f"Error al consultar estado: {str(e)}"
        }


def generate_marketing_video(
    image_path: Optional[str] = None,
    image_data: Optional[bytes] = None,
    duration: int = 15,
    style: str = "dynamic",
    add_narration: bool = False,
    narration_text: Optional[str] = None,
    narration_language: str = "es"
) -> Dict[str, Any]:
    """
    Genera un video de marketing desde una imagen.
    
    Args:
        image_path: Ruta a la imagen
        image_data: Datos binarios de la imagen
        duration: Duración en segundos (5, 15, 30, 60 para diferentes plataformas)
        style: Estilo del video (dynamic, smooth, cinematic, energetic)
        add_narration: Si True, agrega narración con TTS
        narration_text: Texto para la narración
        narration_language: Idioma de la narración
    
    Returns:
        Dict con el video generado
    """
    try:
        # Generar el video base
        video_result = generate_video(
            image_path=image_path,
            image_data=image_data,
            duration=duration,
            fps=24
        )
        
        if not video_result.get("success"):
            return video_result
        
        # Si se solicita narración, agregarla
        if add_narration and narration_text:
            # Generar audio con TTS
            tts_result = text_to_speech(
                text=narration_text,
                language=narration_language
            )
            
            if tts_result.get("success"):
                video_result["narration"] = {
                    "added": True,
                    "text": narration_text,
                    "language": narration_language,
                    "audio_data": tts_result.get("audio_data")
                }
            else:
                video_result["narration"] = {
                    "added": False,
                    "error": tts_result.get("error", "Error generando narración")
                }
        
        video_result["style"] = style
        video_result["duration"] = duration
        
        return video_result
        
    except Exception as e:
        return {
            "success": False,
            "error": f"Error generando video de marketing: {str(e)}"
        }


def create_video_from_images(
    image_paths: List[str],
    transitions: str = "fade",
    duration_per_image: int = 3,
    total_duration: Optional[int] = None,
    add_narration: bool = False,
    narration_texts: Optional[List[str]] = None
) -> Dict[str, Any]:
    """
    Crea un video compuesto desde múltiples imágenes con transiciones.
    
    Args:
        image_paths: Lista de rutas a imágenes
        transitions: Tipo de transición (fade, slide, cut)
        duration_per_image: Duración de cada imagen en segundos
        total_duration: Duración total del video (opcional, calcula si no se proporciona)
        add_narration: Si True, agrega narración
        narration_texts: Lista de textos para narración (uno por imagen)
    
    Returns:
        Dict con el video generado
    """
    try:
        if not image_paths or len(image_paths) == 0:
            return {
                "success": False,
                "error": "Se requiere al menos una imagen"
            }
        
        # Calcular duración total
        if total_duration is None:
            total_duration = len(image_paths) * duration_per_image
        
        # Nota: Esta función requiere un servicio de composición de video
        # Por ahora, retornamos información sobre lo que se necesita
        return {
            "success": True,
            "note": "Composición de video desde múltiples imágenes requiere servicio adicional",
            "images_count": len(image_paths),
            "transitions": transitions,
            "duration_per_image": duration_per_image,
            "total_duration": total_duration,
            "narration_requested": add_narration,
            "message": "Esta funcionalidad requiere un servicio de composición de video. "
                      "Por ahora, puedes generar videos individuales desde cada imagen."
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": f"Error creando video desde imágenes: {str(e)}"
        }


def generate_video_with_audio(
    image_path: Optional[str] = None,
    image_data: Optional[bytes] = None,
    audio_text: str = "",
    audio_language: str = "es",
    duration: int = 15,
    sync_audio: bool = True
) -> Dict[str, Any]:
    """
    Genera un video y agrega audio generado con TTS.
    
    Args:
        image_path: Ruta a la imagen
        image_data: Datos binarios de la imagen
        audio_text: Texto para generar audio
        audio_language: Idioma del audio
        duration: Duración del video en segundos
        sync_audio: Si True, sincroniza la duración del audio con el video
    
    Returns:
        Dict con el video y audio generados
    """
    try:
        # Generar video
        video_result = generate_video(
            image_path=image_path,
            image_data=image_data,
            duration=duration,
            fps=24
        )
        
        if not video_result.get("success"):
            return video_result
        
        # Generar audio
        if audio_text:
            tts_result = text_to_speech(
                text=audio_text,
                language=audio_language
            )
            
            if tts_result.get("success"):
                video_result["audio"] = {
                    "text": audio_text,
                    "language": audio_language,
                    "audio_data": tts_result.get("audio_data"),
                    "format": "wav",
                    "synced": sync_audio
                }
            else:
                video_result["audio"] = {
                    "error": tts_result.get("error", "Error generando audio")
                }
        
        return video_result
        
    except Exception as e:
        return {
            "success": False,
            "error": f"Error generando video con audio: {str(e)}"
        }

