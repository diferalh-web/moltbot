#!/usr/bin/env python3
"""
Proxy Ollama que agrega modelos de múltiples backends
Permite que Open WebUI vea todos los modelos como si vinieran de un solo backend
"""

from flask import Flask, jsonify, request, Response, stream_with_context
import requests
import json
from typing import List, Dict

app = Flask(__name__)

# Configuración de backends Ollama
BACKENDS = [
    {'name': 'Mistral', 'url': 'http://ollama-mistral:11434'},
    {'name': 'Qwen', 'url': 'http://ollama-qwen:11434'},
    {'name': 'Code', 'url': 'http://ollama-code:11434'},
    {'name': 'Flux', 'url': 'http://ollama-flux:11434'},
]

def get_all_models() -> List[Dict]:
    """Obtiene todos los modelos de todos los backends"""
    all_models = []
    
    for backend in BACKENDS:
        try:
            response = requests.get(f"{backend['url']}/api/tags", timeout=5)
            if response.status_code == 200:
                data = response.json()
                if 'models' in data:
                    for model in data['models']:
                        # Agregar información del backend al modelo
                        model_info = model.copy()
                        model_info['backend_url'] = backend['url']
                        model_info['backend_name'] = backend['name']
                        all_models.append(model_info)
        except Exception as e:
            print(f"Error conectando a {backend['name']}: {e}")
    
    return all_models

def find_model_backend(model_name: str) -> str:
    """Encuentra el backend que tiene el modelo"""
    for backend in BACKENDS:
        try:
            response = requests.get(f"{backend['url']}/api/tags", timeout=5)
            if response.status_code == 200:
                data = response.json()
                if 'models' in data:
                    for model in data['models']:
                        if model.get('name') == model_name:
                            return backend['url']
        except:
            continue
    return None

@app.route('/api/tags', methods=['GET'])
def api_tags():
    """Endpoint que devuelve todos los modelos de todos los backends"""
    models = get_all_models()
    
    # Formatear como respuesta de Ollama
    response_data = {
        'models': models
    }
    
    return jsonify(response_data)

@app.route('/api/generate', methods=['POST'])
def api_generate():
    """Proxy para /api/generate - redirige al backend correcto"""
    data = request.json
    model_name = data.get('model')
    
    backend_url = find_model_backend(model_name)
    if not backend_url:
        return jsonify({'error': f'Model {model_name} not found'}), 404
    
    # Redirigir la petición al backend correcto
    try:
        # Aumentar timeout para modelos grandes que tardan en cargar
        response = requests.post(
            f"{backend_url}/api/generate",
            json=data,
            stream=data.get('stream', False),
            timeout=600  # 10 minutos para modelos grandes
        )
        
        if data.get('stream', False):
            def generate():
                for chunk in response.iter_content(chunk_size=None):
                    if chunk:
                        yield chunk
            return Response(stream_with_context(generate()), mimetype='application/json')
        else:
            return jsonify(response.json())
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/chat', methods=['POST'])
def api_chat():
    """Proxy para /api/chat"""
    data = request.json
    model_name = data.get('model')
    
    backend_url = find_model_backend(model_name)
    if not backend_url:
        return jsonify({'error': f'Model {model_name} not found'}), 404
    
    try:
        # Aumentar timeout para modelos grandes
        response = requests.post(
            f"{backend_url}/api/chat",
            json=data,
            stream=data.get('stream', False),
            timeout=600  # 10 minutos para modelos grandes
        )
        
        if data.get('stream', False):
            def generate():
                for chunk in response.iter_content(chunk_size=None):
                    if chunk:
                        yield chunk
            return Response(stream_with_context(generate()), mimetype='application/json')
        else:
            return jsonify(response.json())
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/show', methods=['POST'])
def api_show():
    """Proxy para /api/show"""
    data = request.json
    model_name = data.get('name')
    
    backend_url = find_model_backend(model_name)
    if not backend_url:
        return jsonify({'error': f'Model {model_name} not found'}), 404
    
    try:
        response = requests.post(
            f"{backend_url}/api/show",
            json=data,
            timeout=30
        )
        return jsonify(response.json())
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/version', methods=['GET'])
def api_version():
    """Devuelve la versión de Ollama"""
    try:
        # Obtener versión del primer backend disponible
        for backend in BACKENDS:
            try:
                response = requests.get(f"{backend['url']}/api/version", timeout=5)
                if response.status_code == 200:
                    return jsonify(response.json())
            except:
                continue
        return jsonify({'version': 'unknown'})
    except:
        return jsonify({'version': 'unknown'})

if __name__ == '__main__':
    print("Proxy Ollama iniciado")
    print("Backends configurados:")
    for backend in BACKENDS:
        print(f"  - {backend['name']}: {backend['url']}")
    print("\nEscuchando en 0.0.0.0:11440")
    app.run(host='0.0.0.0', port=11440, debug=False)

