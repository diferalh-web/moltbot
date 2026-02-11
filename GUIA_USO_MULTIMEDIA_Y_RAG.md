# 🎨 Guía Completa: Uso de Multimedia y RAG en Open WebUI

## 📋 Índice

1. [Generación de Imágenes](#generación-de-imágenes)
2. [Generación de Videos](#generación-de-videos)
3. [Síntesis de Voz (TTS)](#síntesis-de-voz-tts)
4. [Knowledge Base (RAG)](#knowledge-base-rag)
5. [Solución de Problemas](#solución-de-problemas)

---

## 🖼️ Generación de Imágenes

### Opción 1: Usando Flux (Ollama) - Recomendado

**Flux** es un modelo de generación de imágenes integrado con Ollama.

#### Desde la Interfaz Web:

1. **Abre Open WebUI**: http://localhost:8082
2. **Selecciona el modelo Flux** en el selector de modelos
3. **Escribe un prompt** como:
   ```
   /generate_image Un gato astronauta flotando en el espacio, estilo realista, alta calidad
   ```
4. El modelo generará la imagen automáticamente

#### Desde la API:

```bash
curl -X POST "http://localhost:8082/api/v1/multimedia/image/generate" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Un gato astronauta flotando en el espacio",
    "model": "flux",
    "width": 1024,
    "height": 1024
  }'
```

### Opción 2: Usando ComfyUI (Avanzado)

**ComfyUI** es una interfaz avanzada con workflows visuales.

1. **Accede a ComfyUI**: http://localhost:7860
2. **Crea un workflow** arrastrando nodos
3. **O usa la API**:

```bash
curl -X POST "http://localhost:8082/api/v1/multimedia/image/generate" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Un paisaje futurista",
    "model": "comfyui",
    "width": 1024,
    "height": 1024,
    "steps": 50
  }'
```

---

## 🎬 Generación de Videos

**Stable Video Diffusion** genera videos a partir de imágenes.

### Desde la Interfaz Web:

1. **Sube una imagen** en el chat de Open WebUI
2. **Escribe el comando**:
   ```
   /generate_video duration=5 fps=24
   ```
3. El sistema generará un video animado a partir de tu imagen

### Desde la API:

```bash
curl -X POST "http://localhost:8082/api/v1/multimedia/video/generate" \
  -F "file=@imagen.png" \
  -F "duration=5" \
  -F "fps=24"
```

**Parámetros:**
- `duration`: Duración del video en segundos (1-10)
- `fps`: Frames por segundo (24, 30, 60)

### Consultar Estado del Video:

Si el video está en proceso, obtendrás un `job_id`. Consulta el estado:

```bash
curl "http://localhost:8082/api/v1/multimedia/video/status/{job_id}"
```

---

## 🔊 Síntesis de Voz (TTS)

**Coqui TTS** convierte texto a voz en múltiples idiomas.

### Desde la Interfaz Web:

1. **Escribe en el chat**:
   ```
   /tts Hola, este es un ejemplo de síntesis de voz
   ```
2. El sistema generará un archivo de audio

### Desde la API:

```bash
curl -X POST "http://localhost:8082/api/v1/multimedia/tts/generate" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Hola, este es un ejemplo de síntesis de voz",
    "language": "es",
    "voice": "default"
  }' \
  --output audio.wav
```

**Parámetros:**
- `text`: Texto a convertir (máximo 500 caracteres)
- `language`: Idioma (`es`, `en`, `fr`, `de`, etc.)
- `voice`: Voz específica (usa `/api/v1/multimedia/tts/voices` para listar)

### Listar Voces Disponibles:

```bash
curl "http://localhost:8082/api/v1/multimedia/tts/voices"
```

---

## 📚 Knowledge Base (RAG)

**Open WebUI** tiene soporte nativo para **Knowledge Base** (RAG - Retrieval-Augmented Generation).

### ¿Qué es RAG?

RAG permite que los modelos LLM accedan a información personalizada que tú proporcionas, como:
- Documentos PDF
- Archivos de texto
- Código fuente
- Notas personales
- Bases de conocimiento

### Configurar Knowledge Base

#### Paso 1: Habilitar Knowledge Base

1. **Abre Open WebUI**: http://localhost:8082
2. **Ve a Settings** (⚙️) → **Features**
3. **Habilita "Knowledge Base"** o "Document Upload"

#### Paso 2: Crear una Knowledge Base

1. **En el menú lateral**, busca **"Knowledge"** o **"Knowledge Base"**
2. **Haz clic en "Create Knowledge Base"** o **"+"**
3. **Asigna un nombre**: Ej: "Mi Base de Conocimiento"
4. **Selecciona el modelo** para embeddings (generalmente el mismo que usas para chat)

#### Paso 3: Subir Documentos

1. **Abre tu Knowledge Base**
2. **Haz clic en "Upload"** o arrastra archivos
3. **Formatos soportados**:
   - PDF (`.pdf`)
   - Texto (`.txt`, `.md`)
   - Word (`.docx`)
   - Código (`.py`, `.js`, `.java`, etc.)
   - HTML (`.html`)

#### Paso 4: Usar Knowledge Base en Chat

1. **Inicia un nuevo chat**
2. **Selecciona tu Knowledge Base** en el selector (aparece arriba del chat)
3. **Haz una pregunta** relacionada con tus documentos:
   ```
   ¿Qué dice el documento sobre X?
   ```
4. El modelo buscará información relevante en tus documentos y responderá

### Ejemplos de Uso

#### Ejemplo 1: Documentación Técnica

```
Knowledge Base: "Documentación Python"
Pregunta: "¿Cómo se usa la función map() en Python según la documentación?"
```

#### Ejemplo 2: Notas Personales

```
Knowledge Base: "Mis Notas de Reuniones"
Pregunta: "¿Qué se discutió en la reunión del 15 de enero?"
```

#### Ejemplo 3: Código Fuente

```
Knowledge Base: "Código del Proyecto"
Pregunta: "Explica cómo funciona la función authenticate()"
```

### Gestión de Knowledge Base

#### Agregar Más Documentos

1. Abre tu Knowledge Base
2. Haz clic en "Upload" o "+"
3. Selecciona los archivos
4. Espera a que se procesen (puede tardar unos minutos)

#### Eliminar Documentos

1. Abre tu Knowledge Base
2. Busca el documento
3. Haz clic en el ícono de eliminar (🗑️)

#### Actualizar Documentos

1. Elimina la versión antigua
2. Sube la nueva versión
3. El sistema re-indexará automáticamente

### Configuración Avanzada

#### Cambiar Modelo de Embeddings

1. **Settings** → **Knowledge Base**
2. **Selecciona el modelo** para embeddings
3. **Recomendaciones**:
   - `mistral:latest` (rápido, buena calidad)
   - `qwen2.5:7b` (excelente para español)
   - Modelos especializados en embeddings (si están disponibles)

#### Ajustar Chunk Size

Los documentos se dividen en "chunks" (fragmentos) para búsqueda:

1. **Settings** → **Knowledge Base** → **Advanced**
2. **Chunk Size**: 512-2048 caracteres (default: 1024)
3. **Chunk Overlap**: 50-200 caracteres (default: 100)

---

## 🔧 Solución de Problemas

### Imágenes no se generan

**Problema**: Flux no responde o da error

**Solución**:
1. Verifica que `ollama-flux` esté corriendo:
   ```powershell
   docker ps | Select-String "ollama-flux"
   ```
2. Verifica que el modelo Flux esté descargado:
   ```powershell
   docker exec ollama-flux ollama list
   ```
3. Si no está, descárgalo:
   ```powershell
   docker exec ollama-flux ollama pull flux
   ```

### Videos no se generan

**Problema**: Stable Video Diffusion no responde

**Solución**:
1. Verifica el estado del servicio:
   ```powershell
   docker logs stable-video --tail 50
   ```
2. Verifica que el puerto 8000 esté accesible:
   ```powershell
   curl http://localhost:8000/health
   ```

### TTS no funciona

**Problema**: Coqui TTS no genera audio

**Solución**:
1. Verifica el estado:
   ```powershell
   docker logs coqui-tts --tail 50
   ```
2. Verifica modelos disponibles:
   ```powershell
   curl http://localhost:5002/api/models
   ```

### Knowledge Base no encuentra información

**Problema**: El modelo no encuentra información relevante

**Solución**:
1. **Verifica que los documentos se hayan procesado**:
   - Abre tu Knowledge Base
   - Verifica que aparezcan en la lista
2. **Reformula tu pregunta**:
   - Usa palabras clave que aparezcan en tus documentos
   - Haz preguntas más específicas
3. **Aumenta el número de chunks**:
   - Settings → Knowledge Base → Advanced
   - Aumenta "Top K" (chunks a recuperar)

### Documentos no se procesan

**Problema**: Los documentos quedan en "Processing" indefinidamente

**Solución**:
1. **Verifica el modelo de embeddings**:
   - Asegúrate de que el modelo seleccionado esté disponible
2. **Reinicia Open WebUI**:
   ```powershell
   docker restart open-webui
   ```
3. **Vuelve a subir el documento**

---

## 📝 Comandos Útiles

### Verificar Estado de Servicios

```powershell
# Ver todos los servicios multimedia
docker ps --format "table {{.Names}}\t{{.Status}}" | Select-String "comfyui|stable-video|coqui-tts|ollama-flux"

# Ver logs de un servicio
docker logs comfyui --tail 50
docker logs stable-video --tail 50
docker logs coqui-tts --tail 50
```

### Reiniciar Servicios

```powershell
# Reiniciar todos los servicios multimedia
docker restart comfyui stable-video coqui-tts ollama-flux

# Reiniciar Open WebUI
docker restart open-webui
```

### Verificar Puertos

```powershell
# Verificar que los puertos estén abiertos
Test-NetConnection -ComputerName localhost -Port 7860  # ComfyUI
Test-NetConnection -ComputerName localhost -Port 8000  # Stable Video
Test-NetConnection -ComputerName localhost -Port 5002  # Coqui TTS
Test-NetConnection -ComputerName localhost -Port 11439 # Ollama Flux
```

---

## 🎯 Mejores Prácticas

### Para Imágenes

- ✅ Usa prompts descriptivos y específicos
- ✅ Especifica estilo artístico si es necesario
- ✅ Ajusta width/height según necesidad (1024x1024 es un buen balance)
- ✅ Para Flux, usa menos steps (20-30) para velocidad, más (50+) para calidad

### Para Videos

- ✅ Usa imágenes de buena calidad (1024x1024 o mayor)
- ✅ Videos cortos (3-5 segundos) son más rápidos
- ✅ Asegúrate de que la imagen tenga un sujeto claro

### Para TTS

- ✅ Textos cortos funcionan mejor (< 500 caracteres)
- ✅ Usa puntuación correcta para mejor entonación
- ✅ Prueba diferentes voces para encontrar la que prefieras

### Para Knowledge Base

- ✅ Organiza documentos por tema en diferentes Knowledge Bases
- ✅ Usa nombres descriptivos para tus Knowledge Bases
- ✅ Actualiza documentos regularmente
- ✅ Combina múltiples fuentes (PDFs, notas, código) para mejor cobertura

---

## 🚀 Próximos Pasos

1. **Explora las capacidades** de cada servicio
2. **Crea Knowledge Bases** para tus proyectos
3. **Experimenta** con diferentes modelos y configuraciones
4. **Comparte tus resultados** y aprende de la comunidad

---

## 📞 Soporte

Si encuentras problemas:

1. Revisa los logs: `docker logs [nombre-servicio]`
2. Verifica que los servicios estén corriendo: `docker ps`
3. Consulta esta guía para soluciones comunes
4. Revisa la documentación oficial de cada servicio

¡Disfruta usando multimedia y RAG en Open WebUI! 🎉









