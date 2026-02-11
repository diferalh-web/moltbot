"""
Router para endpoints de multimedia en Open WebUI
"""
from fastapi import APIRouter, HTTPException, UploadFile, File
from fastapi.responses import JSONResponse, StreamingResponse
import os
import requests
from typing import Optional
import base64
import io

router = APIRouter()

# URLs de servicios desde variables de entorno
FLUX_API_URL = os.getenv("FLUX_API_URL", "http://ollama-flux:11434")
COMFYUI_API_URL = os.getenv("IMAGE_GENERATION_API_URL", "http://comfyui:8188")
STABLE_VIDEO_API_URL = os.getenv("VIDEO_GENERATION_API_URL", "http://stable-video:8000")
COQUI_TTS_API_URL = os.getenv("TTS_API_URL", "http://coqui-tts:5002")

# Generación ComfyUI (API real con workflow Flux)
from .comfyui_workflow import generate_image_via_comfyui


@router.post("/api/v1/multimedia/image/generate")
async def generate_image(
    prompt: str,
    model: str = "flux",
    width: int = 1024,
    height: int = 1024,
    steps: int = 50
):
    """Genera una imagen a partir de un prompt"""
    try:
        if model == "flux":
            # Usar Ollama-Flux
            url = f"{FLUX_API_URL}/api/generate"
            payload = {
                "model": "flux",
                "prompt": prompt,
                "stream": False
            }
            response = requests.post(url, json=payload, timeout=600)
            response.raise_for_status()
            result = response.json()
            
            if "response" in result and "image" in result["response"]:
                # Decodificar imagen base64
                image_data = base64.b64decode(result["response"]["image"])
                return StreamingResponse(
                    io.BytesIO(image_data),
                    media_type="image/png",
                    headers={"Content-Disposition": f'inline; filename="generated_{prompt[:20]}.png"'}
                )
            else:
                raise HTTPException(status_code=500, detail="No se recibió imagen en la respuesta")
        else:
            # Usar ComfyUI (API real: workflow Flux/text-to-image)
            result = generate_image_via_comfyui(
                prompt=prompt,
                width=width,
                height=height,
                steps=steps,
            )
            if not result.get("success"):
                raise HTTPException(
                    status_code=500,
                    detail=result.get("error", "Error generando imagen con ComfyUI")
                )
            image_bytes = result.get("image_bytes")
            content_type = result.get("content_type", "image/png")
            if not image_bytes:
                raise HTTPException(status_code=500, detail="No se recibió imagen en la respuesta")
            return StreamingResponse(
                io.BytesIO(image_bytes),
                media_type=content_type,
                headers={"Content-Disposition": f'inline; filename="generated_{prompt[:20].replace(" ", "_")}.png"'}
            )
                
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=500, detail=f"Error de conexión: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error inesperado: {str(e)}")


@router.post("/api/v1/multimedia/video/generate")
async def generate_video(
    file: UploadFile = File(...),
    duration: int = 5,
    fps: int = 24
):
    """Genera un video a partir de una imagen"""
    try:
        image_data = await file.read()
        
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
        
        if "video_url" in result:
            # Descargar video
            video_response = requests.get(result["video_url"], timeout=300, stream=True)
            return StreamingResponse(
                video_response.iter_content(chunk_size=8192),
                media_type="video/mp4",
                headers={"Content-Disposition": f'inline; filename="generated_video.mp4"'}
            )
        elif "job_id" in result:
            return JSONResponse({
                "job_id": result["job_id"],
                "status": "processing",
                "message": "Video en proceso, consulta el estado con /api/v1/multimedia/video/status/{job_id}"
            })
        else:
            raise HTTPException(status_code=500, detail="No se recibió video en la respuesta")
            
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=500, detail=f"Error de conexión: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error inesperado: {str(e)}")


@router.get("/api/v1/multimedia/video/status/{job_id}")
async def check_video_status(job_id: str):
    """Consulta el estado de un video en proceso"""
    try:
        url = f"{STABLE_VIDEO_API_URL}/api/status/{job_id}"
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=500, detail=f"Error de conexión: {str(e)}")


@router.post("/api/v1/multimedia/tts/generate")
async def text_to_speech(
    text: str,
    language: str = "es",
    voice: str = "default"
):
    """Genera audio a partir de texto"""
    try:
        if not text or not text.strip():
            raise HTTPException(status_code=400, detail="El texto no puede estar vacío")
        
        url = f"{COQUI_TTS_API_URL}/api/tts"
        payload = {
            "text": text,
            "language": language,
            "voice": voice
        }
        
        response = requests.post(url, json=payload, timeout=120)
        response.raise_for_status()
        
        if response.headers.get('content-type', '').startswith('audio/'):
            return StreamingResponse(
                io.BytesIO(response.content),
                media_type=response.headers.get('content-type', 'audio/wav'),
                headers={"Content-Disposition": f'inline; filename="tts_output.wav"'}
            )
        else:
            result = response.json()
            raise HTTPException(status_code=500, detail=result.get("error", "Error desconocido"))
            
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=500, detail=f"Error de conexión: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error inesperado: {str(e)}")


@router.get("/api/v1/multimedia/tts/voices")
async def list_voices():
    """Lista las voces disponibles"""
    try:
        url = f"{COQUI_TTS_API_URL}/api/models"
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=500, detail=f"Error de conexión: {str(e)}")









