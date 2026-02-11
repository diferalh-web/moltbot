# Guía de Búsqueda Web

## Descripción

El servicio de búsqueda web permite obtener información actualizada de internet directamente desde Open WebUI (Mistral, Qwen, etc.). Soporta dos proveedores:

- **DuckDuckGo**: Sin API key requerida, ilimitado
- **Tavily**: Requiere API key, 1,000 búsquedas/mes gratis

El servidor expone un endpoint compatible con **Open WebUI External Web Search** (`POST /search`), para que el modelo pueda consultar la red cuando tú activas la búsqueda en el chat.

---

## Activar consultas a la red en Open WebUI (paso a paso)

Para que Mistral (y otros modelos) puedan **consultar la web** en el chat:

### 0. Misma red Docker (importante)

Open WebUI debe poder resolver el host **web-search**. Si ves *"An error occurred while searching the web"* y en los logs de Open WebUI aparece *"Failed to resolve 'web-search'"*, conecta el contenedor a la red:

```powershell
docker network connect ai-network open-webui
```

Si levantas todo con `docker compose -f docker-compose-extended.yml up -d`, ambos servicios usan la red `ai-network` y no deberías necesitar este paso.

### 1. Configurar Web Search en Admin Panel

1. Entra en **http://localhost:8082** e inicia sesión como **admin**.
2. Ve a **Admin Panel** (icono de engranaje o menú) → **Settings** → pestaña **Web Search**.
3. Activa **Enable Web Search** (toggle en ON).
4. En **Web Search Engine** elige **external**.
5. En **External Search URL** pon exactamente:
   ```text
   http://web-search:5003/search
   ```
   (Cuando Open WebUI y web-search corren en el mismo Docker Compose, el backend usa el nombre del servicio `web-search`.)
6. **External Web Search API Key**: escribe exactamente **`opcional`** (en minúsculas). El servicio está configurado para aceptar esta clave; si cambias la clave en el compose, usa la misma aquí.
7. Pulsa **Save**.

### 2. Activar la búsqueda en cada consulta

En el chat, **cada vez que quieras que el modelo consulte la red**:

- En el campo del mensaje, usa el botón **"+"** (o la opción de adjuntar/herramientas) y activa **Web Search** / **Búsqueda web**, **o**
- Abre la conversación con: **http://localhost:8082/?web-search=true**

Si no activas la búsqueda web para ese mensaje, el modelo responderá solo con su conocimiento interno (sin consultar internet).

### 3. Para que el modelo muestre el precio (o datos concretos)

Si ves "Retrieved X sources" pero el modelo no escribe el **precio** ni el dato que buscas:

1. **Sé explícito en la pregunta**  
   En lugar de solo "¿cuál es el precio de hoy?", indica la acción:  
   *"Busca el precio actual de las acciones de **NVIDIA (símbolo NVDA)** hoy y escribe el precio en dólares que aparezca."*

2. **Nombre o símbolo correcto**  
   Si pides "precio de hoy" sin decir la empresa, el modelo o la búsqueda pueden usar otra (p. ej. Pinterest). Usa siempre el nombre o el ticker: **NVIDIA**, **NVDA**, **Pinterest**, **PINS**, etc.

3. **Configuración en Admin → Web Search**  
   - **Search Result Count**: pon al menos **5** para que cargue varias fuentes.  
   - **No desactives** "Web Loader" / "Bypass Web Loader": Open WebUI necesita cargar el contenido de cada enlace para que el modelo pueda leer el precio en la página.  
   - Si el modelo tiene contexto corto, en **Admin → Models → (tu modelo) → Advanced** sube el **context length** (p. ej. 8192 o más) para que quepa el texto de las páginas.

4. **Ejemplo de prompt que suele funcionar**  
   ```text
   Busca en Yahoo Finance o Google Finance el precio actual de las acciones de NVIDIA (NVDA) y dime el precio en dólares que figure hoy.
   ```

### 4. Si el modelo dice "no tengo acceso a las herramientas de búsqueda"

Si Mistral (u otro modelo) responde algo como *"No tengo acceso a las herramientas que permiten buscar información en la web"* o *"te puedo mostrar cómo habría una respuesta con esa función"*:

**Causa:** Open WebUI **no está llamando** al servicio de búsqueda. En los logs de `web-search` no aparecerá ninguna línea `[Open WebUI /search] recibido` para ese mensaje. Si ya tenías todo activado (Admin + toggle por mensaje) y aun así no llega la petición, la URL puede estar mal guardada en la base de datos de Open WebUI (PersistentConfig).

**Qué revisar (en este orden):**

1. **Activar búsqueda en este mensaje**  
   En el chat, junto al campo donde escribes, hay un botón **"+"** (o un icono de herramientas). Ábrelo y **activa "Web Search" / "Búsqueda web"** para ese mensaje. Si no lo activas, Open WebUI no enviará la petición a `http://web-search:5003/search` y el modelo responderá sin datos reales de internet.

2. **Configuración en Admin Panel**  
   - **Admin Panel** → **Settings** → pestaña **Web Search**.  
   - **Enable Web Search**: debe estar **ON**.  
   - **Web Search Engine**: **external**.  
   - **External Search URL**: exactamente `http://web-search:5003/search`.  
   - Guarda con **Save**.

3. **Comprobar que el servicio responde** (desde PowerShell):
   ```powershell
   Invoke-RestMethod -Uri "http://localhost:5003/search" -Method POST -ContentType "application/json" -Body '{"query":"precio NVIDIA","count":3}'
   ```
   Si ves un JSON con `link`, `title`, `snippet`, el servicio está bien. Si ves `[]`, revisa `docker logs web-search --tail 20`.

4. **Forzar la URL en la base de datos** (si Admin ya está bien y aun así no llega la petición a web-search):  
   Open WebUI guarda la config en la base de datos (PersistentConfig). A veces el valor guardado no es el esperado. Puedes forzar la URL ejecutando dentro del contenedor:
   ```powershell
   docker cp scripts/forzar-web-search-openwebui.py open-webui:/tmp/
   docker exec open-webui python /tmp/forzar-web-search-openwebui.py
   docker restart open-webui
   ```
   Luego vuelve a probar con **Web Search** activado en el mensaje.

5. **Alternativa: herramientas de la extensión**  
   Si usas la extensión open-webui-multimedia, el modelo puede tener la herramienta **web_search**. En **Admin Panel** → **Workspace** → **Models** → (tu modelo, p. ej. Mistral) revisa que las herramientas de la extensión estén habilitadas. Luego puedes pedir explícitamente: *"Usa la función web_search para buscar el precio actual de NVIDIA."*

   **Si pides "Usa web_search" y el modelo responde sin llamar a la herramienta** (dice que no puede o da pasos manuales):
   - **Function Calling en Default:** En **Admin Panel** → **Workspace** → **Models** → Mistral → **Advanced Params**, busca **Function Calling** y ponlo en **Default** (no Native). Los modelos locales suelen funcionar mejor así.
   - **Tool habilitada:** En la misma página, en **Tools**, asegúrate de que la herramienta de búsqueda esté activada (p. ej. "web_search" o "Búsqueda web (Web Search)" si importaste la tool standalone).
   - **Importar la tool standalone (si no aparece):** En el repo está `extensions/open-webui-multimedia/web_search_tool_standalone.py`. En Open WebUI ve a **Workspace** → **Tools** → **Add** / **Import** y sube o pega ese archivo. Así tendrás la tool "Búsqueda web (Web Search)" para asignarla al modelo. Luego en **Models** → Mistral → **Tools**, actívala.
   - Tras cambiar Function Calling o las tools, inicia un **chat nuevo** y prueba de nuevo: *"Usa la herramienta web_search para buscar el precio actual de las acciones de NVIDIA y dime el resultado."*

6. **Si la búsqueda está activada pero la petición no llega a web-search**  
   En los logs de `web-search` cada petición a `/search` se registra con **hora e IP** (ej.: `[Open WebUI /search] 2026-02-11 12:25:00 POST desde 172.22.0.10`). Prueba esto:
   - Abre el chat con la búsqueda fijada en la URL: **http://localhost:8082/?web-search=true** (luego elige el modelo y escribe). Así toda la conversación usa búsqueda por defecto.
   - Envía un mensaje y **en seguida** ejecuta: `docker logs web-search --tail 15`. Si no aparece ninguna línea nueva con la hora del mensaje, Open WebUI no está llamando al endpoint.

   **Arquitectura extended y proxy Ollama:** Si usas `docker-compose-extended.yml` con **ollama-proxy** (`OLLAMA_BASE_URL=http://ollama-proxy:11440`), es posible que el built-in "Web Search" de Open WebUI **no dispare** la llamada a `http://web-search:5003/search` (antes de Draco, con un solo Ollama, sí funcionaba). Para comprobarlo:
   - En `docker-compose-extended.yml`, cambia temporalmente a conexión directa a un Ollama: `OLLAMA_BASE_URL=http://ollama-mistral:11434`.
   - Reinicia solo Open WebUI: `docker compose -f docker-compose-extended.yml up -d open-webui --force-recreate --no-deps`.
   - Refresca la UI, activa "Busca en web" y envía un mensaje; revisa `docker logs web-search --tail 30`.
   - **Si con URL directa sí aparecen peticiones:** el fallo está ligado al uso del proxy o a la ruta multi-Ollama; mientras tanto usa la **herramienta web_search** de la extensión (punto 5) o mantén `OLLAMA_BASE_URL` apuntando a un solo Ollama si solo necesitas ese modelo.
   - **Si con URL directa tampoco llegan peticiones:** el problema es de Open WebUI (versión o bug del built-in); en ese caso la alternativa fiable es la herramienta **web_search** de la extensión.

   **Comprobado en este proyecto:** Con `OLLAMA_BASE_URL=http://ollama-mistral:11434` (sin proxy), el toggle "Busca en web" **sigue sin** generar peticiones a `web-search` en los logs. Por tanto el fallo no es el proxy sino el built-in de Open WebUI en este entorno. **Solución recomendada:** usar la herramienta **web_search** de la extensión (Admin → Models → Mistral → Tools; en el chat pedir: *"Usa la función web_search para buscar el precio actual de NVIDIA"*).

### 5. Si el modelo "inventa" precios o datos (no busca de verdad)

Si el modelo escribe algo como *"Lo que encontré en internet: Apertura: $159.38..."* pero **no hay enlaces ni fuentes** y los números parecen inventados:

1. **La búsqueda devolvió vacío** – Open WebUI llamó a `http://web-search:5003/search` pero el servicio respondió con `[]`. Comprueba los logs:
   ```powershell
   docker logs web-search --tail 30
   ```
   Si ves `[Open WebUI /search] query='...' -> sin resultados` o `-> timeout`, el problema está en el servicio de búsqueda (DuckDuckGo a veces falla desde contenedores).

2. **Revisa Admin Panel** – En **Admin → Settings → Web Search**:
   - **Enable Web Search**: ON  
   - **Web Search Engine**: external  
   - **External Search URL**: exactamente `http://web-search:5003/search`  
   - **Search Result Count**: 5 o más  
   - Guarda los cambios.

3. **Prueba el endpoint manualmente** desde el contenedor:
   ```powershell
   docker exec open-webui curl -s -X POST http://web-search:5003/search -H "Content-Type: application/json" -d "{\"query\":\"precio NVIDIA hoy\",\"count\":3}"
   ```
   Si la respuesta es `[]`, el fallo está en web-search (o en DuckDuckGo). Si ves un JSON con resultados, el fallo puede estar en cómo Open WebUI pasa los resultados al modelo.

4. **Alternativa**: Pide al modelo que use la herramienta **web_search** de la extensión (si está habilitada en el modelo). Esa herramienta llama directamente a web-search y no depende del built-in de Open WebUI.

### 6. Responder en el mismo idioma que la pregunta (español cuando preguntas en español)

Por defecto el modelo puede responder en inglés aunque preguntes en español. Para que **responda siempre en el idioma en que escribes**:

**Opción A – Para todos los usuarios (admin)**  
1. **Admin Panel** → **Workspace** → **Models**.  
2. Abre el modelo que uses (p. ej. **Mistral**).  
3. En **Default System Prompt** (o System Message) pega:
   ```text
   Responde siempre en el mismo idioma en que el usuario escribe su mensaje. Si escribe en español, responde en español. Si escribe en inglés, responde en inglés. No traduzcas la pregunta; responde directamente en ese idioma.
   ```
4. Guarda.

**Opción B – Solo para tu cuenta**  
1. Menú de usuario (arriba) → **Settings** → **General**.  
2. En **Default System Prompt** pega el mismo texto de arriba y guarda.

**Opción C – Solo en un chat**  
En esa conversación, abre los controles del chat (icono de engranaje o "Chat parameters") y en **System prompt** pega el mismo texto.

Así, cuando preguntes *"¿Cuál es el precio de las acciones de Pinterest hoy?"*, la respuesta vendrá en español.

### 7. Cómo obtener respuestas más detalladas y profundas

Si al pedir "más detalle" o "profundiza" el modelo solo repite listas cortas o títulos y no desarrolla cada tema, haz lo siguiente:

**1. Subir la cantidad de fuentes**  
En **Admin Panel → Settings → Web Search**:  
- **Search Result Count**: pon **6, 8 o 10** (en lugar de 3). Así se cargan más páginas y el modelo tiene más contenido para resumir y profundizar.

**2. Dar más contexto al modelo**  
En **Admin Panel → Workspace → Models** → tu modelo (p. ej. Mistral) → **Advanced**:  
- **Context length**: 8192 o más (por ejemplo 16384 si el modelo lo permite). Así no se recorta el texto de las noticias y puede usar más párrafos de cada fuente.

**3. Instrucción en el System Prompt**  
En el mismo **Default System Prompt** del modelo (o en tu Settings → General), puedes **añadir** esta línea al final del texto que ya tengas:

```text
Cuando el usuario pida más detalle, profundizar o ampliar información, elabora cada punto con datos concretos de las fuentes: fechas, nombres, cifras y contexto. Responde en párrafos de al menos 2-3 oraciones por tema; no te limites a listar títulos o una sola frase por noticia.
```

**4. Pedir el detalle de forma explícita**  
En lugar de solo "dame más detalle", prueba por ejemplo:

```text
Para cada una de las 5 noticias, escribe un párrafo corto (al menos 3 oraciones) con detalles concretos: qué pasó, cuándo, quiénes están involucrados y por qué es relevante. Usa el contenido de las fuentes que se cargaron.
```

O:

```text
Profundiza en cada noticia: para cada tema da contexto, fechas recientes, nombres de personas o instituciones mencionadas y una breve explicación de por qué es importante hoy.
```

Con más fuentes (Search Result Count), más contexto (context length) y esta forma de pedir, el modelo debería profundizar mejor en los temas.

### 8. Probar

1. Selecciona un modelo (p. ej. **Mistral**).
2. Activa **Web Search** en el campo del mensaje.
3. Escribe por ejemplo:
   ```text
   Busca en internet las últimas noticias sobre inteligencia artificial en 2025 y dame un resumen.
   ```

Si todo está bien, el modelo usará el servicio externo y responderá con información actualizada.

---

## Configuración del servicio

### Instalación

Si usas Docker Compose extendido, el servicio `web-search` ya está definido. Levanta todo con:

```powershell
docker compose -f docker-compose-extended.yml up -d
```

O solo el servicio de búsqueda si ya tienes el compose:

```powershell
docker compose -f docker-compose-extended.yml up -d web-search
```

### Configurar API Key de Tavily (opcional)

En el compose o en el contenedor:

```powershell
$env:TAVILY_API_KEY = "tu_api_key"
```

Obtén tu API key en: https://tavily.com

El endpoint `/search` usado por Open WebUI utiliza DuckDuckGo por defecto (no requiere API key).

---

## Uso desde Open WebUI (con Web Search activado)

### Uso básico

Con **Web Search** activado en el mensaje, puedes preguntar por ejemplo:

```
Busca información sobre: inteligencia artificial local 2025
```

```
¿Qué hay de nuevo sobre Docker y contenedores este año?
```

### Uso Programático

```python
from extensions.open-webui-multimedia import web_search, search_and_summarize

# Búsqueda simple
result = web_search("IA local", provider="duckduckgo", max_results=10)

# Búsqueda con resumen
summary = search_and_summarize("marketing digital 2024", max_results=5)
```

## Ejemplos de Prompts

### Investigación de Tendencias

```
Busca las últimas tendencias en marketing digital para 2024
```

### Análisis de Competencia

```
Busca información sobre [competidor] y su estrategia de marketing
```

### Información Actualizada

```
¿Qué hay de nuevo sobre [tecnología] en los últimos meses?
```

### Comparación

```
Busca información comparando [producto A] vs [producto B]
```

## Proveedores Disponibles

### DuckDuckGo

- **Ventajas**: Sin API key, ilimitado, privacidad
- **Desventajas**: Resultados menos estructurados
- **Uso**: Ideal para búsquedas generales

### Tavily

- **Ventajas**: Resultados más estructurados, mejor para análisis
- **Desventajas**: Requiere API key, límite de 1,000 búsquedas/mes gratis
- **Uso**: Ideal para análisis profundos y búsquedas especializadas

## Integración con Marketing

La búsqueda web se integra con las herramientas de marketing:

```python
from extensions.open-webui-multimedia import analyze_competitor

# Analizar competidor usando búsqueda web
analysis = analyze_competitor("https://competidor.com", max_results=10)
```

## Troubleshooting

### Error: "No se pudo conectar"

1. Verifica que el servicio está corriendo: `docker ps | findstr web-search`
2. Prueba el health endpoint: `curl http://localhost:5003/health`
3. Revisa los logs: `docker logs web-search`

### Error: "Tavily API key required"

- Usa DuckDuckGo como proveedor (no requiere API key)
- O configura la API key de Tavily

### Resultados vacíos

- Prueba con términos de búsqueda más específicos
- Verifica tu conexión a internet
- Intenta con el otro proveedor

## Mejores Prácticas

1. **Usa términos específicos**: Búsquedas más específicas dan mejores resultados
2. **Combina con análisis**: Usa `search_and_summarize` para obtener resúmenes
3. **Integra con marketing**: Combina búsqueda con análisis de competencia
4. **Verifica fuentes**: Siempre revisa las URLs de los resultados









