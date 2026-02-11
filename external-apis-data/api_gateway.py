"""
Gateway para APIs externas
Soporta Google Gemini y Hugging Face Inference API
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import requests
from typing import Dict, Any, Optional

app = Flask(__name__)
CORS(app)

# API Keys (opcionales)
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
HUGGINGFACE_API_KEY = os.getenv("HUGGINGFACE_API_KEY", "")


def call_gemini(prompt: str, model: str = "gemini-pro", api_key: Optional[str] = None) -> Dict[str, Any]:
    """
    Llama a la API de Google Gemini.
    
    Args:
        prompt: Texto del prompt
        model: Modelo a usar (default: gemini-pro)
        api_key: API key (si no se proporciona, usa la variable de entorno)
    
    Returns:
        Dict con la respuesta
    """
    key = api_key or GEMINI_API_KEY
    if not key:
        return {
            "success": False,
            "error": "GEMINI_API_KEY no configurada. Configura la variable de entorno o proporciona api_key."
        }
    
    try:
        import google.generativeai as genai
        
        genai.configure(api_key=key)
        model_instance = genai.GenerativeModel(model)
        
        response = model_instance.generate_content(prompt)
        
        return {
            "success": True,
            "model": model,
            "response": response.text,
            "provider": "gemini"
        }
    except ImportError:
        # Fallback usando requests si no está instalado google-generativeai
        try:
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={key}"
            payload = {
                "contents": [{
                    "parts": [{"text": prompt}]
                }]
            }
            
            response = requests.post(url, json=payload, timeout=60)
            response.raise_for_status()
            
            data = response.json()
            text = data.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")
            
            return {
                "success": True,
                "model": model,
                "response": text,
                "provider": "gemini"
            }
        except Exception as e:
            return {
                "success": False,
                "error": f"Error llamando a Gemini API: {str(e)}"
            }
    except Exception as e:
        return {
            "success": False,
            "error": f"Error llamando a Gemini: {str(e)}"
        }


def call_huggingface(model: str, prompt: str, api_key: Optional[str] = None) -> Dict[str, Any]:
    """
    Llama a la API de Hugging Face Inference.
    
    Args:
        model: ID del modelo en Hugging Face (ej: "gpt2", "mistralai/Mistral-7B-Instruct-v0.2")
        prompt: Texto del prompt
        api_key: API key (si no se proporciona, usa la variable de entorno)
    
    Returns:
        Dict con la respuesta
    """
    key = api_key or HUGGINGFACE_API_KEY
    
    try:
        url = f"https://api-inference.huggingface.co/models/{model}"
        headers = {}
        if key:
            headers["Authorization"] = f"Bearer {key}"
        
        payload = {
            "inputs": prompt,
            "parameters": {
                "max_new_tokens": 500,
                "return_full_text": False
            }
        }
        
        response = requests.post(url, json=payload, headers=headers, timeout=120)
        
        # Hugging Face puede retornar 503 si el modelo está cargando
        if response.status_code == 503:
            return {
                "success": False,
                "error": "El modelo está cargando. Intenta de nuevo en unos momentos.",
                "retry_after": response.headers.get("Retry-After", "30")
            }
        
        response.raise_for_status()
        data = response.json()
        
        # La respuesta puede ser una lista o un dict
        if isinstance(data, list):
            text = data[0].get("generated_text", "") if data else ""
        elif isinstance(data, dict):
            text = data.get("generated_text", "")
        else:
            text = str(data)
        
        return {
            "success": True,
            "model": model,
            "response": text,
            "provider": "huggingface"
        }
    except requests.exceptions.RequestException as e:
        return {
            "success": False,
            "error": f"Error llamando a Hugging Face API: {str(e)}"
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Error inesperado: {str(e)}"
        }


@app.route('/health', methods=['GET'])
def health():
    """Endpoint de salud del servicio"""
    return jsonify({
        "status": "ok",
        "service": "external-apis-gateway",
        "providers": {
            "gemini": {
                "available": bool(GEMINI_API_KEY),
                "api_key_configured": bool(GEMINI_API_KEY)
            },
            "huggingface": {
                "available": True,
                "api_key_configured": bool(HUGGINGFACE_API_KEY),
                "note": "Algunos modelos funcionan sin API key"
            }
        }
    })


@app.route('/api/gemini', methods=['POST'])
def gemini_endpoint():
    """
    Endpoint para llamar a Google Gemini.
    
    Body JSON:
    {
        "prompt": "texto del prompt",
        "model": "gemini-pro" (opcional),
        "api_key": "tu_api_key" (opcional, usa variable de entorno si no se proporciona)
    }
    """
    try:
        data = request.json
        prompt = data.get('prompt', '')
        model = data.get('model', 'gemini-pro')
        api_key = data.get('api_key', None)
        
        if not prompt:
            return jsonify({
                "success": False,
                "error": "El parámetro 'prompt' es requerido"
            }), 400
        
        result = call_gemini(prompt, model, api_key)
        
        if result.get("success"):
            return jsonify(result), 200
        else:
            return jsonify(result), 500
            
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error en el servidor: {str(e)}"
        }), 500


@app.route('/api/huggingface', methods=['POST'])
def huggingface_endpoint():
    """
    Endpoint para llamar a Hugging Face Inference API.
    
    Body JSON:
    {
        "model": "gpt2" o "mistralai/Mistral-7B-Instruct-v0.2",
        "prompt": "texto del prompt",
        "api_key": "tu_api_key" (opcional, usa variable de entorno si no se proporciona)
    }
    """
    try:
        data = request.json
        model = data.get('model', '')
        prompt = data.get('prompt', '')
        api_key = data.get('api_key', None)
        
        if not model:
            return jsonify({
                "success": False,
                "error": "El parámetro 'model' es requerido"
            }), 400
        
        if not prompt:
            return jsonify({
                "success": False,
                "error": "El parámetro 'prompt' es requerido"
            }), 400
        
        result = call_huggingface(model, prompt, api_key)
        
        if result.get("success"):
            return jsonify(result), 200
        else:
            return jsonify(result), 500
            
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error en el servidor: {str(e)}"
        }), 500


@app.route('/api/providers', methods=['GET'])
def list_providers():
    """Lista los proveedores disponibles"""
    providers = [
        {
            "id": "gemini",
            "name": "Google Gemini",
            "requires_api_key": True,
            "available": bool(GEMINI_API_KEY),
            "models": ["gemini-pro", "gemini-pro-vision"]
        },
        {
            "id": "huggingface",
            "name": "Hugging Face",
            "requires_api_key": False,
            "available": True,
            "note": "Algunos modelos requieren API key, otros funcionan sin ella",
            "popular_models": [
                "gpt2",
                "mistralai/Mistral-7B-Instruct-v0.2",
                "meta-llama/Llama-2-7b-chat-hf"
            ]
        }
    ]
    
    return jsonify({
        "success": True,
        "providers": providers
    })


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5004))
    app.run(host='0.0.0.0', port=port, debug=False)









