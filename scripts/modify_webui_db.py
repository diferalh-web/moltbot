import sqlite3
import json
import os
import sys

db_path = '/app/backend/data/webui.db'

if not os.path.exists(db_path):
    print(f"Error: Base de datos no encontrada en {db_path}")
    sys.exit(1)

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Verificar estructura de la base de datos
cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
tables = [row[0] for row in cursor.fetchall()]
print(f"Tablas encontradas: {', '.join(tables)}")

# Buscar tabla de configuraciones o settings
config_table = None
for table in ['config', 'settings', 'app_config', 'user_config']:
    if table in tables:
        config_table = table
        break

if config_table:
    print(f"Usando tabla: {config_table}")
    cursor.execute(f"SELECT * FROM {config_table} LIMIT 5")
    rows = cursor.fetchall()
    print(f"Filas de ejemplo: {rows}")
else:
    # Intentar crear tabla de configuraciones si no existe
    print("No se encontró tabla de configuraciones, intentando crear...")
    try:
        cursor.execute("CREATE TABLE IF NOT EXISTS app_config (key TEXT PRIMARY KEY, value TEXT)")
        config_table = 'app_config'
        conn.commit()
        print("Tabla app_config creada")
    except Exception as e:
        print(f"Error al crear tabla: {e}")

# Configurar OLLAMA_BASE_URLS en la base de datos
if config_table:
    ollama_urls = "http://ollama-mistral:11434|http://ollama-qwen:11434|http://ollama-code:11434|http://ollama-flux:11434"
    try:
        # Leer configuración actual
        cursor.execute(f"SELECT id, data, version FROM {config_table} ORDER BY id DESC LIMIT 1")
        row = cursor.fetchone()
        
        if row:
            config_id, config_data, config_version = row
            # Parsear JSON
            config_json = json.loads(config_data)
            
            # Agregar OLLAMA_BASE_URLS al JSON
            if 'ollama' not in config_json:
                config_json['ollama'] = {}
            config_json['ollama']['base_urls'] = ollama_urls
            
            # Actualizar en la base de datos
            updated_data = json.dumps(config_json)
            cursor.execute(f"UPDATE {config_table} SET data = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?", (updated_data, config_id))
            conn.commit()
            print(f"✓ OLLAMA_BASE_URLS configurado: {ollama_urls}")
        else:
            # Crear nueva configuración si no existe
            config_json = {
                'version': 0,
                'ollama': {
                    'base_urls': ollama_urls
                }
            }
            cursor.execute(f"INSERT INTO {config_table} (data, version) VALUES (?, ?)", (json.dumps(config_json), 0))
            conn.commit()
            print(f"✓ Nueva configuración creada con OLLAMA_BASE_URLS: {ollama_urls}")
    except Exception as e:
        print(f"Error al configurar OLLAMA_BASE_URLS: {e}")
        import traceback
        traceback.print_exc()

# Buscar tabla de modelos o connections
models_table = None
for table in ['models', 'connections', 'ollama_connections', 'model_config']:
    if table in tables:
        models_table = table
        break

if models_table:
    print(f"Tabla de modelos encontrada: {models_table}")
    cursor.execute(f"SELECT * FROM {models_table} LIMIT 5")
    rows = cursor.fetchall()
    print(f"Filas de ejemplo: {rows}")

conn.close()
print("✓ Base de datos modificada exitosamente")

