"""
Servidor Flask para síntesis de voz y clonación de voz usando Coqui TTS
Soporta TTS estándar y clonación de voz con XTTS
"""

from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
from TTS.api import TTS
import os
import tempfile
import io
import base64

app = Flask(__name__)
CORS(app)

# Inicializar TTS estándar
print("Inicializando Coqui TTS...")
tts_standard = TTS(model_name="tts_models/es/css10/vits", gpu=True)
print("TTS estándar inicializado correctamente")

# Inicializar XTTS para clonación (se inicializa bajo demanda)
xtts_model = None
XTTS_LOADED = False


def load_xtts():
    """Carga el modelo XTTS para clonación de voz (lazy loading)"""
    global xtts_model, XTTS_LOADED
    
    if XTTS_LOADED:
        return xtts_model
    
    try:
        print("Cargando modelo XTTS para clonación de voz...")
        xtts_model = TTS(model_name="tts_models/multilingual/multi-dataset/xtts_v2", gpu=True)
        XTTS_LOADED = True
        print("XTTS cargado correctamente")
        return xtts_model
    except Exception as e:
        print(f"Error al cargar XTTS: {str(e)}")
        return None


@app.route('/health', methods=['GET'])
def health():
    """Endpoint de salud del servicio"""
    return jsonify({
        "status": "ok",
        "service": "coqui-tts",
        "features": {
            "tts": "available",
            "voice_cloning": "available" if XTTS_LOADED else "loading_on_demand"
        }
    })


@app.route('/api/tts', methods=['POST'])
def generate_speech():
    """
    Genera síntesis de voz estándar.
    
    Body JSON:
    {
        "text": "texto a convertir",
        "language": "es" | "en",
        "voice": "default"
    }
    """
    global tts_standard
    
    try:
        data = request.json
        text = data.get('text', '')
        language = data.get('language', 'es')
        voice = data.get('voice', 'default')
        
        if not text:
            return jsonify({"error": "Text is required"}), 400
        
        # Seleccionar modelo según idioma
        if language == 'es':
            model_name = "tts_models/es/css10/vits"
        elif language == 'en':
            model_name = "tts_models/en/ljspeech/tacotron2-DDC"
        else:
            model_name = "tts_models/es/css10/vits"
        
        # Si el modelo actual no coincide, recargar
        current_model = tts_standard.model_name if hasattr(tts_standard, 'model_name') else None
        if current_model != model_name:
            tts_standard = TTS(model_name=model_name, gpu=True)
        
        # Generar audio
        output_path = os.path.join(tempfile.gettempdir(), f"tts_output_{os.getpid()}.wav")
        tts_standard.tts_to_file(text=text, file_path=output_path)
        
        # Leer archivo y enviarlo
        with open(output_path, 'rb') as f:
            audio_data = f.read()
        
        os.remove(output_path)
        
        return send_file(
            io.BytesIO(audio_data),
            mimetype='audio/wav',
            as_attachment=True,
            download_name='output.wav'
        )
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/clone-voice', methods=['POST'])
def clone_voice():
    """
    Clona una voz usando XTTS.
    
    Body JSON:
    {
        "text": "texto a generar",
        "reference_audio": "base64_encoded_audio" o "url",
        "language": "es" | "en" | "fr" | "de" | etc.,
        "reference_audio_path": "ruta local" (alternativa)
    }
    """
    try:
        data = request.json
        text = data.get('text', '')
        reference_audio = data.get('reference_audio', '')
        language = data.get('language', 'es')
        reference_audio_path = data.get('reference_audio_path', '')
        
        if not text:
            return jsonify({"error": "Text is required"}), 400
        
        # Cargar XTTS si no está cargado
        xtts = load_xtts()
        if xtts is None:
            return jsonify({
                "error": "XTTS no está disponible. El modelo se está cargando o hubo un error."
            }), 503
        
        # Preparar audio de referencia
        ref_audio_path = None
        
        if reference_audio_path:
            # Usar ruta local
            ref_audio_path = reference_audio_path
        elif reference_audio:
            # Decodificar base64 o descargar desde URL
            if reference_audio.startswith('http'):
                # Descargar desde URL
                import requests
                response = requests.get(reference_audio, timeout=30)
                ref_audio_path = os.path.join(tempfile.gettempdir(), f"ref_audio_{os.getpid()}.wav")
                with open(ref_audio_path, 'wb') as f:
                    f.write(response.content)
            else:
                # Decodificar base64
                try:
                    audio_bytes = base64.b64decode(reference_audio)
                    ref_audio_path = os.path.join(tempfile.gettempdir(), f"ref_audio_{os.getpid()}.wav")
                    with open(ref_audio_path, 'wb') as f:
                        f.write(audio_bytes)
                except Exception as e:
                    return jsonify({"error": f"Error decodificando audio: {str(e)}"}), 400
        else:
            return jsonify({"error": "reference_audio o reference_audio_path es requerido"}), 400
        
        if not os.path.exists(ref_audio_path):
            return jsonify({"error": "No se pudo acceder al audio de referencia"}), 400
        
        # Generar audio clonado
        output_path = os.path.join(tempfile.gettempdir(), f"cloned_output_{os.getpid()}.wav")
        
        try:
            xtts.tts_to_file(
                text=text,
                file_path=output_path,
                speaker_wav=ref_audio_path,
                language=language
            )
            
            # Leer archivo y enviarlo
            with open(output_path, 'rb') as f:
                audio_data = f.read()
            
            # Limpiar archivos temporales
            os.remove(output_path)
            if ref_audio_path and os.path.exists(ref_audio_path) and ref_audio_path.startswith(tempfile.gettempdir()):
                os.remove(ref_audio_path)
            
            return send_file(
                io.BytesIO(audio_data),
                mimetype='audio/wav',
                as_attachment=True,
                download_name='cloned_output.wav'
            )
        except Exception as e:
            # Limpiar en caso de error
            if os.path.exists(output_path):
                os.remove(output_path)
            if ref_audio_path and os.path.exists(ref_audio_path) and ref_audio_path.startswith(tempfile.gettempdir()):
                os.remove(ref_audio_path)
            raise e
            
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/models', methods=['GET'])
def list_models():
    """Lista los modelos disponibles"""
    models = [
        {"id": "es", "name": "Español (CSS10)", "model": "tts_models/es/css10/vits"},
        {"id": "en", "name": "English (LJSpeech)", "model": "tts_models/en/ljspeech/tacotron2-DDC"}
    ]
    
    if XTTS_LOADED:
        models.append({
            "id": "xtts",
            "name": "XTTS v2 (Multilingual + Voice Cloning)",
            "model": "tts_models/multilingual/multi-dataset/xtts_v2",
            "supports_cloning": True
        })
    
    return jsonify({
        "models": models,
        "voice_cloning_available": XTTS_LOADED
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=False)

