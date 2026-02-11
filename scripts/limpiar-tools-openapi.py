#!/usr/bin/env python3
"""
Script para limpiar configuraciones de herramientas OpenAPI en Open WebUI
que estén apuntando incorrectamente a puertos de Ollama
"""
import sqlite3
import json
import sys

DB_PATH = '/app/backend/data/webui.db'

try:
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Listar todas las tablas
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
    tables = [row[0] for row in cursor.fetchall()]
    print(f"Tablas encontradas: {', '.join(tables)}")
    
    # Buscar tabla de tools o tool_servers
    tool_tables = [t for t in tables if 'tool' in t.lower() or 'server' in t.lower()]
    print(f"\nTablas relacionadas con tools: {tool_tables}")
    
    # Buscar en tabla 'tool' o similar
    for table_name in tool_tables:
        try:
            cursor.execute(f"SELECT * FROM {table_name}")
            rows = cursor.fetchall()
            print(f"\n=== Tabla: {table_name} ===")
            if rows:
                # Obtener nombres de columnas
                cursor.execute(f"PRAGMA table_info({table_name})")
                columns = [col[1] for col in cursor.fetchall()]
                print(f"Columnas: {columns}")
                
                for row in rows:
                    print(f"Fila: {dict(zip(columns, row))}")
                    
                    # Buscar URLs que apunten a puertos de Ollama
                    for i, col in enumerate(columns):
                        if 'url' in col.lower() or 'base' in col.lower() or 'endpoint' in col.lower():
                            value = row[i]
                            if value and ('11437' in str(value) or '11438' in str(value) or '11439' in str(value)):
                                print(f"\n⚠️  ENCONTRADO: {table_name}.{col} = {value}")
                                print(f"   Esta URL apunta a un puerto de Ollama, no a un servidor OpenAPI")
                                
                                # Eliminar esta entrada
                                try:
                                    # Intentar obtener el ID
                                    if 'id' in columns:
                                        id_col = columns.index('id')
                                        row_id = row[id_col]
                                        cursor.execute(f"DELETE FROM {table_name} WHERE id = ?", (row_id,))
                                        conn.commit()
                                        print(f"   ✓ Eliminada entrada con ID: {row_id}")
                                    else:
                                        # Si no hay ID, usar la primera columna
                                        cursor.execute(f"DELETE FROM {table_name} WHERE {columns[0]} = ?", (row[0],))
                                        conn.commit()
                                        print(f"   ✓ Eliminada entrada")
                                except Exception as e:
                                    print(f"   ✗ Error al eliminar: {e}")
            else:
                print("  (vacía)")
        except Exception as e:
            print(f"  Error al leer tabla {table_name}: {e}")
    
    # También buscar en tabla 'config' por configuraciones de tools
    if 'config' in tables:
        print("\n=== Buscando en tabla 'config' ===")
        cursor.execute("SELECT id, data FROM config ORDER BY id DESC LIMIT 5")
        configs = cursor.fetchall()
        
        for config_id, config_data in configs:
            try:
                config_json = json.loads(config_data)
                # Buscar referencias a tools o tool_servers
                if 'tools' in config_json or 'tool_servers' in config_json or 'external_tools' in config_json:
                    print(f"\nConfig ID {config_id} contiene configuración de tools:")
                    print(json.dumps(config_json, indent=2))
                    
                    # Buscar URLs problemáticas
                    def find_problematic_urls(obj, path=""):
                        if isinstance(obj, dict):
                            for key, value in obj.items():
                                current_path = f"{path}.{key}" if path else key
                                if isinstance(value, str) and ('11437' in value or '11438' in value or '11439' in value):
                                    if 'tool' in key.lower() or 'server' in key.lower():
                                        print(f"⚠️  URL problemática encontrada en {current_path}: {value}")
                                        return True
                                elif isinstance(value, (dict, list)):
                                    if find_problematic_urls(value, current_path):
                                        return True
                        elif isinstance(obj, list):
                            for i, item in enumerate(obj):
                                if find_problematic_urls(item, f"{path}[{i}]"):
                                    return True
                        return False
                    
                    if find_problematic_urls(config_json):
                        print("   (Se encontraron URLs problemáticas, pero no se modifican automáticamente)")
            except Exception as e:
                print(f"  Error al parsear config {config_id}: {e}")
    
    conn.close()
    print("\n✓ Verificación completada")
    
except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)









