# Cómo probar Deep Search desde Open WebUI

## Checklist antes de probar

| Comprobación | Cómo verificar |
|--------------|----------------|
| **web-search** en marcha | `docker ps` → contenedor `web-search` (puerto 5003). Draco lo usa para las búsquedas. |
| **draco-core** en marcha | `docker ps` → contenedor `draco-core` (puerto 8001). `Invoke-RestMethod http://localhost:8001/health` debe responder. |
| **ollama-mistral** (u otro Ollama) | Draco usa Ollama para evaluar relevancia y consolidar la respuesta. Modelo `mistral` (o `OLLAMA_CHAT_MODEL`) debe existir. |
| **open-webui** en marcha | `docker ps` → contenedor `open-webui`. Extensión montada: `./extensions/open-webui-multimedia` → `/app/extensions/multimedia`. |
| **Flujo deep_search** cargado | `Invoke-RestMethod http://localhost:8001/flows` → en `flows` debe aparecer `deep_search`. |
| **Config de fuentes** | Archivo `draco-core/config/preferred_sources.json` existe; en Docker se monta `./draco-core/config:/app/config`. |

Si algo falla al probar: revisar logs con `docker logs draco-core` y `docker logs open-webui`.

---

## Levantar solo los servicios necesarios (sin ComfyUI)

Si al hacer `docker compose up -d open-webui ...` ves **"Image ghcr.io/comfyanonymous/comfyui:latest Error ... denied"**, es porque Compose intenta descargar/iniciar ComfyUI. Para **deep_search** no hace falta ComfyUI. Levanta solo lo necesario con `--no-deps`:

```powershell
cd c:\code\moltbot

# 1. Servicios que no dependen de ComfyUI
docker compose -f docker-compose-unified.yml up -d web-search ollama-mistral

# 2. Draco Core (sin arrancar ComfyUI)
docker compose -f docker-compose-unified.yml up -d draco-core --no-deps

# 3. Open WebUI (sin arrancar ComfyUI, stable-video, etc.)
docker compose -f docker-compose-unified.yml up -d open-webui --no-deps
```

Comprueba que Draco responde:

```powershell
Invoke-RestMethod -Uri "http://localhost:8001/health" -Method GET
```

Luego abre la WebUI en **http://localhost:8082** y sigue los pasos de "Cómo probar en la WebUI" más abajo.

---

## Configuraciones necesarias (verificadas)

Para que **deep_search** funcione desde la WebUI deben estar correctos: la extensión, las variables de entorno de Open WebUI y Draco, y que el modelo tenga herramientas habilitadas.

---

### 1. Open WebUI (contenedor o instalación)

| Variable | Valor típico | Uso |
|----------|--------------|-----|
| `DRACO_CORE_URL` | `http://draco-core:8000` (Docker) / `http://localhost:8001` (local) | URL de la API de Draco Core. **Requerido** para que la herramienta `deep_search` y `execute_draco_flow` funcionen. |
| `DRACO_API_TOKEN` | *(opcional)* | Si en Draco tienes `DRACO_REQUIRE_AUTH=true`, define aquí el mismo token. La extensión enviará `Authorization: Bearer <token>`. |
| `WEB_SEARCH_API_URL` | `http://web-search:5003` (Docker) | Usado por `web_search` y `search_and_summarize`; el flujo deep_search llama a Draco, y Draco llama a web-search con su propia variable. |

**Extensión multimedia:** debe estar montada/cargada para que existan las herramientas `deep_search` y `execute_draco_flow`. En Docker (unified):

- Volumen: `./extensions/open-webui-multimedia:/app/extensions/multimedia:ro`

---

### 2. Draco Core

| Variable | Valor típico | Uso |
|----------|--------------|-----|
| `WEB_SEARCH_URL` | `http://web-search:5003` | URL del servicio web-search que usa el flujo deep_search. |
| `OLLAMA_URL` | `http://ollama-mistral:11434` | Ollama para `evaluate_search_relevance` y `consolidate_search_results`. |
| `OLLAMA_CHAT_MODEL` | `mistral` | Modelo usado por las herramientas de evaluación y consolidación. Debe existir en ese Ollama. |
| `FLOWS_DIR` | `/app/flows` | Directorio de flujos (en Docker se monta `./draco-core/flows`). |
| `DRACO_REQUIRE_AUTH` | `false` | Si es `true`, las llamadas a `/flows/execute` requieren `Authorization: Bearer <DRACO_API_TOKEN>`. |
| `DRACO_API_TOKEN` | *(opcional)* | Token que Open WebUI debe enviar si `DRACO_REQUIRE_AUTH=true`. |

**Puerto:** el contenedor escucha en 8000; en el host suele mapearse a **8001** (`8001:8000`).

---

### 3. Servicio web-search

Debe estar accesible desde **Draco Core** (misma red Docker o URL alcanzable). No hace falta configurar nada extra en la WebUI para deep_search; la WebUI solo llama a Draco, y Draco llama a web-search.

---

### 4. Ollama (para deep_search)

El flujo deep_search usa Ollama en dos pasos:

- **evaluate_search_relevance:** decidir si los resultados son suficientes.
- **consolidate_search_results:** generar la respuesta final a partir de los resultados.

En `docker-compose-unified.yml`, Draco tiene:

- `OLLAMA_URL=http://ollama-mistral:11434`
- El modelo por defecto en `draco-core/config.py` es `OLLAMA_CHAT_MODEL=mistral`.

Debe haber al menos un contenedor Ollama (p. ej. `ollama-mistral`) con el modelo **mistral** (o el que definas en `OLLAMA_CHAT_MODEL`) disponible.

---

### 5. Habilitar herramientas en el modelo (Open WebUI)

Para que el modelo pueda invocar `deep_search` (y el resto de herramientas multimedia), hay que **añadir el toolkit "Multimedia" al Workspace** y luego **activarlo en el modelo**.

#### A) Añadir el toolkit Multimedia al Workspace (solo una vez)

El mensaje "To select toolkits here, add them to the **Tools** workspace first" significa que antes debes registrar el toolkit:

1. Ve a **Workspace** (menú lateral) → **Tools** (no a Settings → External Tools).
2. Pulsa **Create** o **Import** (según tu versión de Open WebUI).
3. **Opción recomendada:** si hay **"Create new tool"** o **"Add tool"**:
   - Título: `Multimedia (Moltbot)` o `Multimedia`.
   - Pega el contenido del archivo **`extensions/open-webui-multimedia/multimedia_toolkit.py`** del proyecto (es el toolkit con docstring y clase `Tools` con `web_search`, `deep_search`, `generate_image`, `execute_draco_flow`).
   - Guarda.
4. **Si hay "Import from file":** sube el archivo `multimedia_toolkit.py` desde tu máquina (ruta: `c:\code\moltbot\extensions\open-webui-multimedia\multimedia_toolkit.py`).
5. Tras guardar, el toolkit **Multimedia (Moltbot)** debería aparecer en la lista de Tools del Workspace.

#### B) Activar el toolkit en el modelo

1. Ve a **Workspace** → **Models** (o **Settings** → **Models**).
2. **Edita** el modelo que usas en el chat.
3. En la sección **Tools**, marca el checkbox de **Multimedia (Moltbot)** (o "Multimedia").
4. Guarda.

Sin este paso, el modelo no verá las herramientas y no podrá usar `deep_search`.

---

## Resumen de comprobaciones

- [ ] **Open WebUI:** variable `DRACO_CORE_URL` definida y accesible desde el contenedor/host donde corre la WebUI.
- [ ] **Open WebUI:** extensión multimedia montada/cargada (ruta `/app/extensions/multimedia` en Docker).
- [ ] **Open WebUI:** si Draco tiene auth, `DRACO_API_TOKEN` definido en el entorno de la WebUI.
- [ ] **Draco Core:** `WEB_SEARCH_URL`, `OLLAMA_URL` y `OLLAMA_CHAT_MODEL` correctos; flujo `deep_search` cargado (p. ej. `GET /flows` debe listar `deep_search`).
- [ ] **web-search:** servicio en marcha y alcanzable desde Draco.
- [ ] **Ollama:** servicio en marcha con el modelo indicado en `OLLAMA_CHAT_MODEL`.
- [ ] **Modelo en Open WebUI:** herramientas habilitadas para ese modelo.

---

## Cómo probar en la WebUI

### 1. Comprobar que la extensión está activa

- **Configuración** → **Extensions**. Debe aparecer la extensión que incluye `deep_search` (multimedia).
- En Docker, la extensión se monta desde `./extensions/open-webui-multimedia` en `/app/extensions/multimedia`.

### 2. Crear o abrir un chat

- Abre un chat y elige un **modelo con herramientas habilitadas** (p. ej. mistral, llama3, qwen2).

### 3. Pedir una búsqueda profunda

Escribe por ejemplo:

- *"Haz una búsqueda profunda sobre qué es la inteligencia artificial generativa en 2025."*
- *"Usa deep search para investigar las últimas noticias sobre energías renovables."*
- *"¿Cuál es el precio de hoy de TSLA?"* o *"Precio actual de NVDA"* — para precios/cotizaciones el modelo debe usar **deep_search** (no web_search). Las descripciones de las herramientas están ajustadas para que prefiera deep_search en esas consultas.

El modelo debería invocar la herramienta **deep_search** y devolver una respuesta consolidada con fuentes. Si en una consulta seguida usa **web_search** en lugar de deep_search, vuelve a pedir explícitamente *"usa búsqueda profunda"* o actualiza el toolkit en Workspace con la versión actual de `multimedia_toolkit.py` (descripciones que priorizan deep_search para precios/acciones).

### 4. (Opcional) Forzar el flujo

- *"Usa la herramienta execute_draco_flow con flow_id deep_search e input: [tu pregunta]"*.

---

## Variables de entorno (Docker) – referencia

Contenedor **open-webui** en `docker-compose-unified.yml`:

- `DRACO_CORE_URL=http://draco-core:8000`
- `WEB_SEARCH_API_URL=http://web-search:5003`
- Opcional: `DRACO_API_TOKEN=...` si en Draco está `DRACO_REQUIRE_AUTH=true`

Si ejecutas Open WebUI **fuera de Docker**, define por ejemplo:

- `DRACO_CORE_URL=http://localhost:8001`
- `DRACO_API_TOKEN=...` si aplica.

---

## Por qué no se usa deep_search (diagnóstico con logs)

Si en `docker logs open-webui` ves **"External search results"** y **"Fetching pages"** pero **nunca** aparece **`[WEBUI-DRACO]`**, significa:

- Open WebUI está usando la **búsqueda web integrada** (Admin → External Web Search URL). Ese flujo llama a tu URL de búsqueda, obtiene resultados, hace RAG y le inyecta contexto al modelo. **No pasa por las herramientas de la extensión** (no se ejecuta `call_tool` de multimedia).
- Por tanto, **Draco no recibe ninguna petición** y deep_search no se usa.

**Qué hacer:**

1. **Habilitar el toolkit Multimedia en el modelo** (si no lo has hecho):
   - **Workspace** → **Tools** → crear/importar el toolkit (p. ej. desde `extensions/open-webui-multimedia/multimedia_toolkit.py`).
   - **Workspace** → **Models** → editar el modelo que usas en el chat → en **Tools**, activar **Multimedia (Moltbot)** o el nombre que tenga → guardar.

2. **Para que el modelo use deep_search en lugar de la búsqueda integrada**, una de estas dos:
   - **Opción A:** En el chat, **desactiva el toggle "Web Search"** (o "Búsqueda web") si está activado. Así el modelo no recibe el contexto de la búsqueda nativa y tendrá que usar las herramientas; pide por ejemplo: *"Haz una búsqueda profunda sobre [tema]"*.
   - **Opción B:** Deja "Web Search" como esté, pero en el mensaje **sé muy explícito**: *"Usa solo la herramienta deep_search para investigar [tema], no uses la búsqueda web normal."*

3. **Comprobar que la extensión sí se ejecuta:**  
   Tras hacer una consulta que debería usar deep_search, ejecuta:
   ```powershell
   docker logs open-webui --tail 100 2>&1 | Select-String "WEBUI-DRACO"
   ```
   - Si **aparecen** líneas `[WEBUI-DRACO]` (call_tool invoked, draco_request, draco_response): la extensión está llamando a Draco; si falla, revisa el mensaje en draco_error o los logs de `draco-core`.
   - Si **no aparece** ninguna línea: el modelo no está invocando la herramienta (toolkit no activado en el modelo, o el mensaje no hace que el modelo elija deep_search).

### Cómo detectar el error cuando el toolkit está activo pero no se usa

Hay instrumentación en la extensión que escribe líneas `[WEBUI-DRACO]` en los logs. Después de **reiniciar open-webui** (para cargar el código nuevo) y hacer **una sola consulta** en el chat (por ejemplo: *"Haz una búsqueda profunda sobre el precio de NVDA"*), ejecuta:

```powershell
docker logs open-webui --tail 150 2>&1 | Select-String "WEBUI-DRACO"
```

Interpretación:

| Lo que ves | Significado |
|------------|-------------|
| **`tools.py module loaded`** (al arrancar) | La extensión multimedia se cargó. Si solo ves esto y nada más al hacer la consulta, el modelo no está recibiendo o no está usando nuestras herramientas (ver fila "Nada"). |
| **Nada** | Open WebUI no está pidiendo nuestras herramientas ni el modelo las invoca. **Primero comprueba:** `docker logs open-webui --tail 300 2>&1 | Select-String "WEBUI-DRACO"` — si **ni siquiera** aparece `tools.py module loaded` al arrancar, la extensión no se está cargando (reinicia con `docker compose ... restart open-webui` y asegura el volumen `./extensions/open-webui-multimedia:/app/extensions/multimedia:ro`). Si sí aparece `tools.py module loaded` pero nunca `get_tools called` ni `toolkit deep_search entered`, entonces: (1) Workspace → Models → el modelo del chat tiene activado el toolkit **Multimedia**. (2) En ese chat, desactiva el toggle "Web Search". (3) Pregunta explícito: *"Usa la herramienta deep_search para investigar X"*. Si añadiste el toolkit **pegando** el .py en Workspace, el script se ejecuta en otro contexto y no puede importar la extensión; por eso antes salía "Error: extensión multimedia no disponible." El toolkit actual tiene **fallback HTTP**: cuando no hay `call_tool`, llama a Draco directamente con `DRACO_CORE_URL` y `DRACO_API_TOKEN` (variables de entorno del contenedor open-webui). Asegúrate de tener `DRACO_CORE_URL` definida en el entorno de Open WebUI (p. ej. `http://draco-core:8000` en Docker). Tras actualizar el archivo, vuelve a pegarlo en Workspace → Tools o reimporta el toolkit. |
| **Solo `get_tools called`** | Open WebUI sí carga nuestras herramientas y las envía al modelo, pero el **modelo no está llamando** a ninguna. Prueba: ser más explícito (*"Usa solo deep_search para..."*), o desactivar "Web Search" en el chat. |
| **`toolkit deep_search entered`** y/o **`call_tool invoked`** (name: deep_search) | El modelo sí invocó deep_search. Si después ves `draco_error` o no ves `draco_response` con success, el fallo está en la conexión con Draco o en el flujo; revisa `docker logs draco-core --tail 50`. |
| **`call_tool invoked`** con otro name (web_search, generate_image...) | El modelo está usando otras herramientas del toolkit, no deep_search. Pide explícitamente *"búsqueda profunda"* o *"usa deep_search"*. |

### Revisar qué query se envió y qué respondió Draco

Para ver si al pedir "profundice" o "análisis" se está enviando una query útil o solo texto vago:

```powershell
# Open WebUI: ver la query exacta que el modelo pasó a deep_search
docker logs open-webui --tail 200 2>&1 | Select-String "WEBUI-DRACO|deep_search query"

# Draco: ver qué input recibió el flujo
docker logs draco-core --tail 100 2>&1 | Select-String "DRACO"
```

- Si en **open-webui** ves `deep_search query` con `"query": "profundice"` o similar: el modelo no está rellenando la consulta completa. Las descripciones de la herramienta indican que debe pasar tema + lo solicitado (ej. "análisis del precio de Meta, lista de precios recientes").
- Si en **draco-core** ves `execute_flow flow_id=deep_search input='...'`: esa es la consulta que se usó para buscar. Si los valores en chats siguientes no coinciden con el primer resultado correcto, puede que el modelo esté respondiendo de memoria en vez de usar la respuesta del flujo; conviene pedir explícitamente *"Haz otra búsqueda profunda con: [tu pregunta completa]"*.

---

## Si no responde o no usa la herramienta

1. **Comprobar servicios:**
   - Draco: `http://localhost:8001/health`
   - web-search: `http://localhost:5003/health` (o el puerto que uses).

2. **Prompt más explícito:**  
   *"Usa la herramienta deep_search con query: [tu pregunta]"*.

3. **Logs de open-webui:**  
   `docker logs open-webui --tail 50`  
   Busca errores al llamar a `draco-core` (timeout, conexión rechazada, 401 si hay auth).

4. **Herramientas del modelo:**  
   En Workspace → Models → editar modelo → Tools: asegúrate de que la herramienta que incluye `deep_search` está activada.

5. **Si Draco tiene auth:**  
   Si `DRACO_REQUIRE_AUTH=true`, en el entorno del contenedor **open-webui** debe estar definido `DRACO_API_TOKEN` con el mismo valor que en Draco.

---

## Logs de Draco: ver qué flujo se ejecutó (deep_search, web_search, etc.)

En cada ejecución de un flujo, Draco escribe dos líneas claras en el log:

- **Al iniciar:** `[Draco] flow=deep_search execution_id=... event=started input_preview="..."`
- **Al terminar:** `[Draco] flow=deep_search execution_id=... event=completed success=true` (o `success=false` y `error=...`)

Para verlas en el contenedor:

```powershell
docker logs draco-core --tail 100
```

Solo ejecuciones de **deep_search**:

```powershell
docker logs draco-core --tail 200 2>&1 | Select-String "flow=deep_search"
```

Solo líneas de inicio y fin de flujos (resumen):

```powershell
docker logs draco-core --tail 200 2>&1 | Select-String "\[Draco\]"
```

---

## Cómo validar que se usó búsqueda profunda (deep_search)

- **En el chat:** En muchas versiones de Open WebUI, al usar una herramienta aparece un texto tipo "Used tool: …" o un icono de herramienta junto al mensaje. Si el modelo usó el toolkit **Multimedia** y eligió `deep_search`, debería verse esa llamada.
- **Por el contenido:** Las respuestas de **deep_search** pasan por Draco (búsqueda → evaluación → consolidación con Ollama). Suelen ser un **único bloque de texto** consolidado y a veces el toolkit añade "Fuentes: X ronda(s) de búsqueda" al final. La **búsqueda web normal** suele mostrar "Retrieved N sources" y listar fuentes por separado.
- **Por el tiempo:** El flujo deep_search tarda más (varios segundos) porque hace búsqueda, evaluación de relevancia y consolidación; una respuesta muy rápida puede ser solo conocimiento del modelo o web_search.

---

## Si el precio o dato devuelto no es el actual (ej. NVDA ~190 pero sale 135)

Puede ser (1) que Draco esté devolviendo un dato antiguo (búsqueda o consolidación), o (2) que el modelo del chat no esté usando la respuesta del flujo y conteste con su conocimiento interno.

**Diagnóstico:** Tras hacer una consulta de precio (ej. "precio actual de NVDA"), revisa los logs de open-webui:

```powershell
docker logs open-webui --tail 100 2>&1 | Select-String "WEBUI-DRACO"
```

Busca la línea **`deep_search answer_from_draco (preview):`**. Ahí se muestra el inicio de la respuesta que devolvió Draco.

- Si en ese preview **sale la cifra incorrecta** (ej. 135): el fallo está en Draco (resultados de búsqueda antiguos o el LLM de consolidación). Se reforzó el prompt de consolidación para que use solo los resultados y no conocimiento interno; si aun así sale mal, revisa qué devuelve el servicio web-search (snippets) para esa consulta.
- Si en el preview **sale la cifra correcta** (ej. 190): Draco está bien; el modelo del chat está ignorando o reescribiendo la respuesta de la herramienta. Prueba con un modelo que siga mejor las instrucciones o con un prompt que pida "responde solo con el resultado de la búsqueda profunda".

**Draco:** En `draco-core/tools/registry.py` el consolidador tiene instrucciones para preguntas de precio/valor: usar solo cifras de los resultados y no conocimiento interno. Tras cambiar ese archivo, reconstruye la imagen de draco-core si usas Docker.

---

## Cómo mejora los resultados (varias fuentes y cotejo)

El flujo **deep_search** está configurado para:

1. **Interpretar la consulta (genérico):** antes de buscar, una herramienta **refine_search_query** usa el LLM (Ollama) para reescribir la pregunta del usuario en una consulta de búsqueda clara: desambigua nombres (ej. empresa vs ticker bursátil), refuerza contexto temporal (ej. "últimos 12 meses") y se aplica a cualquier tema (acciones, noticias, ciencia, etc.). No hay listas fijas en código; el modelo interpreta cada consulta.
2. **Siempre dos rondas de búsqueda:** el evaluador devuelve "no suficiente" en la primera ronda, así que siempre se ejecutan 2 búsquedas antes de consolidar (más fuentes para cotejar).
3. **Prioridad por tema (ronda 1):** en la primera ronda se detecta el **tema** de la consulta por palabras clave y se buscan primero dominios conocidos para ese tema:
   - **stocks:** Yahoo Finance, Investing.com  
   - **crypto:** CoinMarketCap, CoinGecko  
   - **tech_news:** TechCrunch, The Verge, Ars Technica  
   - **health:** WHO, Mayo Clinic, WebMD  
   - **science:** Nature, Science Daily  
   - **general_news:** Reuters, BBC  

   **Configuración dinámica:** temas y sitios se leen desde un **archivo JSON**; no hace falta tocar código ni reiniciar para aplicar cambios.
   - **Archivo:** `draco-core/config/preferred_sources.json`
   - **Estructura:** `preferred_sources` (objeto tema → lista de `["site:dominio.com", max_results]`) y `topic_keywords` (objeto tema → lista de palabras clave). El orden de los temas en `topic_keywords` importa: más específicos primero (p. ej. crypto antes que stocks).
   - **Ruta alternativa:** variable de entorno `PREFERRED_SOURCES_CONFIG` con la ruta absoluta al JSON.
   - En Docker se monta `./draco-core/config:/app/config:ro`; edita el JSON en tu máquina y los cambios se usan en la siguiente búsqueda sin reiniciar.
   - **Ejemplo:** para añadir el tema "deportes" con Marca y ESPN: en `preferred_sources` agrega `"sports": [["site:marca.com", 5], ["site:espn.com", 5]]` y en `topic_keywords` agrega `"sports": ["deportes", "fútbol", "liga", "partido"]`. Guarda el archivo y lanza otra búsqueda; no hace falta reiniciar.
4. **Más resultados por búsqueda:** hasta 18 resultados por ronda (y hasta 40 pasados al consolidador).
5. **Consolidación con cotejo:** el LLM recibe instrucciones de considerar todas las fuentes, comparar cifras cuando varias dan un dato y proponer una respuesta citando al menos 2 fuentes cuando sea posible.

La lógica está en `draco-core/tools/registry.py` y el flujo en `draco-core/flows/deep_search_flow.json`. Para cambiar **temas o sitios** basta con editar `draco-core/config/preferred_sources.json` (sin reiniciar). Solo hay que reconstruir la imagen de draco-core si modificas el código (registry o flujo).

---

## Análisis con fechas (últimos 12 meses, fecha actual)

Si pides un **análisis del precio en los últimos 12 meses** (o similar), el flujo deep_search ahora:

1. **Inyecta la fecha de referencia** en la consolidación: el LLM recibe "Fecha de referencia (hoy): YYYY-MM-DD" y debe interpretar "últimos 12 meses", "actual", "hoy" respecto a esa fecha.
2. **Refuerza la búsqueda** cuando detecta rangos temporales ("últimos 12 meses", "análisis reciente", "evolución"): añade el año actual (y el anterior) a la query para priorizar resultados recientes.

Si en un **seguimiento** indicas la fecha (ej. "considerando que hoy es 11 de febrero de 2025") y el modelo no vuelve a buscar: las descripciones de la herramienta indican que debe invocar **deep_search de nuevo** con la consulta completa (incluyendo la fecha). Puedes pedir explícitamente: *"Haz otra búsqueda profunda con la fecha actual para el análisis de los últimos 12 meses"*.

---

## Mejorar la exactitud de la respuesta (precios, datos actuales)

- **Pregunta más concreta:** Para precios o datos numéricos, formula la pregunta de forma explícita, por ejemplo:  
  *"¿Cuál es el precio de Bitcoin en USD hoy? Indica la cifra exacta y la fuente o fecha del dato."*
- **Prompt de consolidación en Draco:** El flujo deep_search ya incluye una instrucción extra cuando detecta preguntas de "precio", "valor", "actual", "hoy", etc.: pide al LLM que incluya la **cifra exacta**, moneda y fuente, y que no invente datos si no aparecen en los resultados. Tras cambiar `draco-core/tools/registry.py`, hay que **reconstruir la imagen** de draco-core para que use el nuevo prompt:  
  `docker compose -f docker-compose-unified.yml build draco-core --no-cache`  
  y luego  
  `docker compose -f docker-compose-unified.yml up -d draco-core --no-deps`.
- **Límite de la búsqueda:** Los resultados dependen del proveedor (DuckDuckGo, etc.) y de los snippets; si ninguna fuente trae un precio reciente, el modelo no puede inventarlo. Para cripto, suele ayudar pedir "precio Bitcoin CoinMarketCap hoy" o similar para que la query coincida mejor con páginas que sí muestran el dato.
