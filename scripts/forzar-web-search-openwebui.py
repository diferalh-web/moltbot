"""
Fuerza la configuración de Web Search (external) en la base de datos de Open WebUI.
Ejecutar DENTRO del contenedor open-webui, donde existe /app/backend/data/webui.db

Uso desde el host:
  docker cp scripts/forzar-web-search-openwebui.py open-webui:/tmp/
  docker exec open-webui python /tmp/forzar-web-search-openwebui.py
"""
import sqlite3
import json
import os

DB_PATH = "/app/backend/data/webui.db"
# Open WebUI usa EXTERNAL_WEB_SEARCH_URL en la UI; el JSON puede ser external_web_search_url o external_search_url
EXTERNAL_URL = os.environ.get("EXTERNAL_WEB_SEARCH_URL") or os.environ.get("EXTERNAL_SEARCH_URL", "http://web-search:5003/search")
API_KEY = os.environ.get("EXTERNAL_WEB_SEARCH_API_KEY") or os.environ.get("EXTERNAL_SEARCH_API_KEY", "opcional")

def main():
    if not os.path.exists(DB_PATH):
        print(f"Error: No existe {DB_PATH}. Ejecuta este script dentro del contenedor open-webui.")
        return 1

    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute("SELECT id, data, version FROM config ORDER BY id DESC LIMIT 1")
    row = cursor.fetchone()
    if not row:
        print("No hay fila en config. Creando configuración inicial.")
        config = {"version": 0, "ui": {}}
    else:
        config = json.loads(row["data"])
        print(f"Config actual cargada (id={row['id']})")

    # Open WebUI puede guardar web search en varias rutas; intentamos las más habituales
    updated = False

    # Ruta 1: tools.web_search (estilo config_path "tools.web_search.*")
    if "tools" not in config:
        config["tools"] = {}
    if "web_search" not in config["tools"]:
        config["tools"]["web_search"] = {}
    ws = config["tools"]["web_search"]
    # Open WebUI puede leer external_web_search_url o external_search_url
    if ws.get("external_web_search_url") != EXTERNAL_URL or ws.get("external_search_url") != EXTERNAL_URL:
        updated = True
    for url_key in ("external_web_search_url", "external_search_url"):
        ws[url_key] = EXTERNAL_URL
    for key_key in ("external_web_search_api_key", "external_search_api_key"):
        ws[key_key] = API_KEY
    ws["enable"] = True
    ws["engine"] = "external"
    updated = True
    print("Actualizado tools.web_search")

    # Ruta 2: clave top-level "web_search" (por si el frontend la usa)
    if "web_search" not in config:
        config["web_search"] = {}
    ws2 = config["web_search"]
    for url_key in ("external_web_search_url", "external_search_url"):
        ws2[url_key] = EXTERNAL_URL
    for key_key in ("external_web_search_api_key", "external_search_api_key"):
        ws2[key_key] = API_KEY
    ws2["enable"] = True
    ws2["engine"] = "external"
    updated = True
    print("Actualizado web_search (top-level)")

    if not updated:
        print("La config de Web Search ya tenía la URL correcta.")
    else:
        config_id = row["id"] if row else None
        if config_id is not None:
            cursor.execute(
                "UPDATE config SET data = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
                (json.dumps(config), config_id),
            )
        else:
            cursor.execute("INSERT INTO config (data, version) VALUES (?, 0)", (json.dumps(config),))
        conn.commit()
        print("Config guardada. Reinicia open-webui para que cargue los cambios:")
        print("  docker restart open-webui")

    # Mostrar qué quedó para web search
    print("\nValores actuales para búsqueda externa:")
    for key in ["tools", "web_search"]:
        if key in config and isinstance(config[key], dict):
            sub = config[key].get("web_search") if key == "tools" else config[key]
            if sub and isinstance(sub, dict):
                url = sub.get("external_web_search_url") or sub.get("external_search_url")
                print(f"  {key}: enable={sub.get('enable')}, engine={sub.get('engine')}, url={url}")

    # Si quieres ver toda la config (para depurar): descomenta la línea siguiente
    # print("\nConfig completo (fragmento):", json.dumps({k: config[k] for k in list(config.keys())[:15]}, indent=2))

    conn.close()
    return 0

if __name__ == "__main__":
    exit(main())
