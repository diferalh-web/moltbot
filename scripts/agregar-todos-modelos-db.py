import sqlite3
import json
import requests
import uuid
from datetime import datetime
import time

db_path = '/app/backend/data/webui.db'

# URLs de los backends Ollama
ollama_backends = [
    {
        'name': 'Mistral',
        'url': 'http://ollama-mistral:11434',
        'port': 11436
    },
    {
        'name': 'Qwen',
        'url': 'http://ollama-qwen:11434',
        'port': 11437
    },
    {
        'name': 'Code',
        'url': 'http://ollama-code:11434',
        'port': 11438
    },
    {
        'name': 'Flux',
        'url': 'http://ollama-flux:11434',
        'port': 11439
    }
]

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Verificar estructura de la tabla model
cursor.execute("PRAGMA table_info(model)")
columns = [row[1] for row in cursor.fetchall()]
print(f"Columnas en tabla 'model': {columns}")

# Obtener todos los modelos de cada backend
all_models = []
for backend in ollama_backends:
    try:
        response = requests.get(f"{backend['url']}/api/tags", timeout=5)
        if response.status_code == 200:
            data = response.json()
            if 'models' in data:
                for model_info in data['models']:
                    model_name = model_info.get('name', '')
                    if model_name:
                        all_models.append({
                            'name': model_name,
                            'backend': backend['name'],
                            'url': backend['url'],
                            'port': backend['port']
                        })
                        print(f"✓ Encontrado: {model_name} en {backend['name']}")
        else:
            print(f"✗ Error {response.status_code} desde {backend['name']}")
    except Exception as e:
        print(f"✗ No se pudo conectar a {backend['name']}: {e}")

print(f"\nTotal de modelos encontrados: {len(all_models)}")

# Obtener un user_id válido (el primer usuario disponible)
cursor.execute("SELECT id FROM user LIMIT 1")
user_row = cursor.fetchone()
if not user_row:
    print("✗ No se encontró ningún usuario en la base de datos")
    conn.close()
    exit(1)

user_id = user_row[0]
print(f"Usando user_id: {user_id[:8]}...")

# Agregar modelos a la base de datos
if 'model' in [row[0] for row in cursor.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]:
    # Verificar si la tabla tiene las columnas necesarias
    if 'id' in columns and 'name' in columns:
        for model in all_models:
            model_name = model['name']
            # Verificar si el modelo ya existe
            cursor.execute("SELECT id FROM model WHERE name = ?", (model_name,))
            existing = cursor.fetchone()
            
            if not existing:
                # Insertar nuevo modelo con todos los campos requeridos
                try:
                    model_id = str(uuid.uuid4())
                    now = int(time.time() * 1000)  # Timestamp en milisegundos
                    meta = json.dumps({"backend": model['backend'], "url": model['url'], "port": model['port']})
                    params = json.dumps({})
                    
                    cursor.execute(
                        """INSERT INTO model 
                           (id, user_id, name, meta, params, created_at, updated_at, is_active) 
                           VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
                        (model_id, user_id, model_name, meta, params, now, now, 1)
                    )
                    
                    print(f"  ✓ Agregado a DB: {model_name} (ID: {model_id[:8]}...)")
                except Exception as e:
                    print(f"  ✗ Error al agregar {model_name}: {e}")
                    import traceback
                    traceback.print_exc()
            else:
                print(f"  - Ya existe: {model_name}")
        
        conn.commit()
        print(f"\n✓ {len(all_models)} modelos procesados en la base de datos")
    else:
        print("La tabla 'model' no tiene la estructura esperada")
else:
    print("No se encontró la tabla 'model'")

conn.close()

