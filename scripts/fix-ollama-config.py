import sqlite3
import json
import sys

db_path = '/app/backend/data/webui.db'

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Leer configuración actual
cursor.execute("SELECT id, data, version FROM config ORDER BY id DESC LIMIT 1")
row = cursor.fetchone()

if row:
    config_id, config_data, config_version = row
    config_json = json.loads(config_data)
    
    # Eliminar OLLAMA_BASE_URLS de la configuración (causa problemas)
    if 'ollama' in config_json:
        if 'base_urls' in config_json['ollama']:
            del config_json['ollama']['base_urls']
            print("✓ Eliminado OLLAMA_BASE_URLS de la configuración")
    
    # Actualizar en la base de datos
    updated_data = json.dumps(config_json)
    cursor.execute("UPDATE config SET data = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?", (updated_data, config_id))
    conn.commit()
    print("✓ Configuración actualizada")
    print(f"Configuración final: {json.dumps(config_json, indent=2)}")
else:
    print("No se encontró configuración")
    sys.exit(1)

conn.close()










