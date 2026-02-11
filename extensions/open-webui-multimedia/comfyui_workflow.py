"""
Integración con la API real de ComfyUI para generación de imágenes (Flux / SD).
Construye un workflow JSON, lo envía a /prompt, espera el resultado en /history
y devuelve la imagen vía /view.
"""

import os
import random
import time
import requests
from typing import Dict, Any, Optional, Tuple

COMFYUI_BASE_URL = os.getenv("IMAGE_GENERATION_API_URL", "http://comfyui:8188")
# Checkpoint por defecto: Flux schnell o el que tengas en models/checkpoints
COMFYUI_CHECKPOINT = os.getenv("COMFYUI_CHECKPOINT_NAME", "flux1-schnell.safetensors")
POLL_INTERVAL = 0.5
MAX_POLL_WAIT = 600  # 10 minutos


def build_flux_workflow(
    prompt: str,
    width: int = 1024,
    height: int = 1024,
    steps: int = 4,
    cfg: float = 1.0,
    seed: Optional[int] = None,
    checkpoint_name: Optional[str] = None,
    negative_prompt: str = "",
) -> Dict[str, Any]:
    """
    Construye el JSON de workflow en formato API de ComfyUI para text-to-image.
    Compatible con Flux (schnell/dev) y otros checkpoints que usen la misma cadena de nodos.
    Nodos: CheckpointLoaderSimple -> CLIPTextEncode (+/-) -> EmptyLatentImage -> KSampler -> VAEDecode -> SaveImage.
    """
    ckpt = checkpoint_name or COMFYUI_CHECKPOINT
    if seed is None:
        seed = random.randint(0, 2**32 - 1)

    # Formato API: cada clave es un node_id, el valor es class_type + inputs.
    # Las conexiones entre nodos son ["node_id", output_index].
    workflow = {
        "1": {
            "class_type": "CheckpointLoaderSimple",
            "inputs": {"ckpt_name": ckpt},
        },
        "2": {
            "class_type": "CLIPTextEncode",
            "inputs": {"text": prompt, "clip": ["1", 1]},
        },
        "3": {
            "class_type": "CLIPTextEncode",
            "inputs": {"text": negative_prompt, "clip": ["1", 1]},
        },
        "4": {
            "class_type": "EmptyLatentImage",
            "inputs": {"width": width, "height": height, "batch_size": 1},
        },
        "5": {
            "class_type": "KSampler",
            "inputs": {
                "model": ["1", 0],
                "positive": ["2", 0],
                "negative": ["3", 0],
                "latent_image": ["4", 0],
                "seed": seed,
                "steps": steps,
                "cfg": cfg,
                "sampler_name": "euler",
                "scheduler": "simple",
                "denoise": 1.0,
            },
        },
        "6": {
            "class_type": "VAEDecode",
            "inputs": {"samples": ["5", 0], "vae": ["1", 2]},
        },
        "7": {
            "class_type": "SaveImage",
            "inputs": {"images": ["6", 0]},
        },
    }
    return workflow


def _get_available_checkpoints(base_url: str) -> list:
    """Obtiene la lista de checkpoints disponibles en ComfyUI (opcional)."""
    try:
        r = requests.get(f"{base_url.rstrip('/')}/object_info/CheckpointLoaderSimple", timeout=10)
        if r.status_code != 200:
            return []
        info = r.json()
        if "CheckpointLoaderSimple" in info and "input" in info["CheckpointLoaderSimple"]:
            required = info["CheckpointLoaderSimple"].get("input", {}).get("required", {})
            if "ckpt_name" in required and "content" in required["ckpt_name"]:
                return list(required["ckpt_name"][0])
        return []
    except Exception:
        return []


def run_workflow_and_get_image(
    prompt: str,
    width: int = 1024,
    height: int = 1024,
    steps: int = 4,
    checkpoint_name: Optional[str] = None,
    base_url: Optional[str] = None,
) -> Tuple[bytes, str]:
    """
    Envía el workflow a ComfyUI, espera a que termine y devuelve los bytes de la imagen
    y el content-type (p. ej. image/png).
    """
    base = (base_url or COMFYUI_BASE_URL).rstrip("/")
    ckpt = checkpoint_name or COMFYUI_CHECKPOINT

    workflow = build_flux_workflow(prompt, width=width, height=height, steps=steps, checkpoint_name=ckpt)

    # 1. Enviar workflow
    resp = requests.post(
        f"{base}/prompt",
        json={"prompt": workflow},
        timeout=30,
    )
    resp.raise_for_status()
    data = resp.json()
    if "error" in data:
        raise RuntimeError(data.get("node_errors") or data["error"])
    prompt_id = data["prompt_id"]

    # 2. Esperar a que aparezca en history con salida
    started = time.monotonic()
    while True:
        if time.monotonic() - started > MAX_POLL_WAIT:
            raise TimeoutError("ComfyUI no devolvió resultado a tiempo")
        time.sleep(POLL_INTERVAL)
        hist = requests.get(f"{base}/history/{prompt_id}", timeout=10)
        hist.raise_for_status()
        hist_data = hist.json()
        if prompt_id not in hist_data:
            continue
        entry = hist_data[prompt_id]
        if "outputs" not in entry:
            continue
        # SaveImage suele ser el nodo "7" en nuestro workflow
        for node_id, out in entry["outputs"].items():
            if "images" in out and out["images"]:
                img_info = out["images"][0]
                filename = img_info.get("filename")
                subfolder = img_info.get("subfolder", "")
                img_type = img_info.get("type", "output")
                if not filename:
                    continue
                # 3. Descargar imagen desde /view
                params = {"filename": filename, "subfolder": subfolder, "type": img_type}
                view = requests.get(f"{base}/view", params=params, timeout=60)
                view.raise_for_status()
                return view.content, view.headers.get("Content-Type", "image/png")
        # Si hay status con error
        if entry.get("status", {}).get("status_str") == "error":
            raise RuntimeError(entry.get("status", {}).get("messages", ["Error en ComfyUI"]))

    raise RuntimeError("No se encontró imagen en la respuesta de ComfyUI")


def generate_image_via_comfyui(
    prompt: str,
    width: int = 1024,
    height: int = 1024,
    steps: int = 4,
    checkpoint_name: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Genera una imagen con ComfyUI (Flux u otro checkpoint) y devuelve un dict
    compatible con el resto de la extensión: success, image_bytes (opcional),
    image_url (opcional), error.
    """
    try:
        image_bytes, content_type = run_workflow_and_get_image(
            prompt=prompt,
            width=width,
            height=height,
            steps=steps,
            checkpoint_name=checkpoint_name,
        )
        import base64
        b64 = base64.b64encode(image_bytes).decode("ascii")
        data_uri = f"data:{content_type};base64,{b64}"
        return {
            "success": True,
            "image_url": data_uri,
            "image_bytes": image_bytes,
            "content_type": content_type,
            "model": "comfyui",
            "prompt": prompt,
        }
    except requests.exceptions.RequestException as e:
        return {"success": False, "error": f"Error de conexión con ComfyUI: {str(e)}"}
    except Exception as e:
        return {"success": False, "error": str(e)}
