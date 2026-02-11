# Cómo Agregar Otros Modelos al Menú de Open WebUI

## ✅ Estado Actual

- **Mistral** ya está visible y funcionando en el menú de modelos
- Los otros modelos (Qwen, CodeLlama, DeepSeek-Coder) están corriendo pero no aparecen en el menú

## 🔧 Solución: Agregar Modelos Manualmente

Open WebUI requiere agregar los backends adicionales manualmente desde la interfaz web. Sigue estos pasos:

### Paso 1: Acceder a Configuración

1. Abre Open WebUI: http://localhost:8082
2. Haz clic en el ícono de **Configuración** (⚙️) en la parte inferior izquierda
3. Busca la sección **"Connections"** o **"External Tools"**

### Paso 2: Agregar Cada Backend

Para cada backend, haz clic en **"Add Connection"** o el botón **"+"** y completa:

#### Backend 1: Qwen
- **Name**: `Qwen`
- **Type**: `Ollama` (o selecciona "Ollama" del dropdown)
- **URL**: `http://localhost:11437`
- **Description** (opcional): `Qwen 2.5 7B - Modelo general chino`

#### Backend 2: Code
- **Name**: `Code`
- **Type**: `Ollama`
- **URL**: `http://localhost:11438`
- **Description** (opcional): `CodeLlama y DeepSeek-Coder - Modelos de programación`

#### Backend 3: Flux
- **Name**: `Flux`
- **Type**: `Ollama`
- **URL**: `http://localhost:11439`
- **Description** (opcional): `Flux - Generación de imágenes`

### Paso 3: Verificar Modelos

Después de agregar cada backend:
1. Espera 10-30 segundos
2. Refresca la página (F5)
3. Haz clic en el selector de modelos (donde dice "mistral:latest")
4. Deberías ver los nuevos modelos disponibles

## 📋 Modelos Disponibles por Backend

### Ollama Mistral (puerto 11436) - ✅ Ya visible
- `mistral:latest` (7.2B)

### Ollama Qwen (puerto 11437)
- `qwen2.5:7b` (4.7 GB)

### Ollama Code (puerto 11438)
- `codellama:34b` (19 GB)
- `deepseek-coder:33b` (18 GB)

### Ollama Flux (puerto 11439)
- (sin modelos aún - puedes descargar Flux más tarde)

## 🔍 Si No Aparece la Opción "Connections"

Si no encuentras la sección "Connections" en Settings:

1. **Verifica la versión de Open WebUI**: Algunas versiones tienen la opción en diferentes lugares
2. **Busca "External Tools"**: Puede estar en esa sección
3. **Revisa "General"**: A veces hay una opción "Ollama Base URLs" donde puedes agregar múltiples URLs separadas por comas

## 🚀 Alternativa: Usar Solo Mistral

Si prefieres no configurar manualmente, puedes usar solo **Mistral** que ya está funcionando. Mistral es muy versátil y puede:
- ✅ Chat general
- ✅ Programación (Java, Python, SQL, etc.)
- ✅ Arquitectura y diseño
- ✅ Seguridad y ethical hacking
- ✅ Cloud computing
- ✅ IA/ML

## 🛠️ Solución Técnica Avanzada

Si quieres automatizar esto, puedes modificar directamente la base de datos de Open WebUI:

```powershell
# Acceder a la base de datos SQLite de Open WebUI
docker exec -it open-webui sqlite3 /app/backend/data/webui.db
```

Sin embargo, esto requiere conocer la estructura exacta de la base de datos y puede causar problemas si se hace incorrectamente.

## ✅ Verificación

Para verificar que los modelos están disponibles:

```powershell
# Ver modelos en Qwen
curl http://localhost:11437/api/tags

# Ver modelos en Code
curl http://localhost:11438/api/tags

# Ver modelos en Flux
curl http://localhost:11439/api/tags
```

## 📝 Notas

- Los modelos pueden tardar 30-60 segundos en aparecer después de agregar el backend
- Si un modelo no aparece, verifica que el contenedor Ollama correspondiente esté corriendo
- Asegúrate de que los puertos 11437, 11438, 11439 estén accesibles desde tu máquina











