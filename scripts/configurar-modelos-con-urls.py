import sqlite3
import json
import requests
import uuid
import time

db_path = '/app/backend/data/webui.db'

# Configuración de backends
backends_config = {
    'mistral:latest': {
        'url': 'http://ollama-mistral:11434',
        'display_name': 'Mistral Latest'
    },
    'qwen2.5:7b': {
        'url': 'http://ollama-qwen:11434',
        'display_name': 'Qwen 2.5 7B'
    },
    'codellama:34b': {
        'url': 'http://ollama-code:11434',
        'display_name': 'CodeLlama 34B'
    },
    'deepseek-coder:33b': {
        'url': 'http://ollama-code:11434',
        'display_name': 'DeepSeek Coder 33B'
    }
}

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Obtener user_id
cursor.execute("SELECT id FROM user LIMIT 1")
user_id = cursor.fetchone()[0]

print(f"Actualizando modelos con URLs de backend...")
print(f"User ID: {user_id[:8]}...\n")

for model_name, config in backends_config.items():
    # Verificar si el modelo existe
    cursor.execute("SELECT id, meta FROM model WHERE name = ?", (model_name,))
    row = cursor.fetchone()
    
    if row:
        model_id, current_meta = row
        # Actualizar meta con la URL del backend
        meta = json.dumps({
            'backend': config['display_name'],
            'url': config['url'],
            'ollama_url': config['url']
        })
        
        # Verificar conexión al backend
        try:
            response = requests.get(f"{config['url']}/api/tags", timeout=5)
            if response.status_code == 200:
                models = response.json().get('models', [])
                model_exists = any(m.get('name') == model_name for m in models)
                if model_exists:
                    cursor.execute(
                        "UPDATE model SET meta = ?, updated_at = ? WHERE id = ?",
                        (meta, int(time.time() * 1000), model_id)
                    )
                    print(f"✓ Actualizado: {model_name} -> {config['url']}")
                else:
                    print(f"⚠ Modelo {model_name} no encontrado en {config['url']}")
            else:
                print(f"✗ Error conectando a {config['url']}: {response.status_code}")
        except Exception as e:
            print(f"✗ Error verificando {model_name}: {e}")
    else:
        print(f"⚠ Modelo {model_name} no existe en la base de datos")

conn.commit()
conn.close()

print("\n✓ Configuración completada")










