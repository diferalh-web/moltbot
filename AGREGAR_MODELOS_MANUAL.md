# 📋 Cómo Agregar los Otros Modelos en Open WebUI

## ✅ Situación Actual

Ya ves **`mistral:latest`** en el selector. Ahora necesitas agregar:
- `qwen2.5:7b` (puerto 11437)
- `codellama:34b` (puerto 11438)
- `deepseek-coder:33b` (puerto 11438)

## 🎯 Solución: Agregar en la Interfaz Web

### Método 1: Settings → External Tools (Recomendado)

1. **En Open WebUI**, haz clic en el **ícono de engranaje (⚙️)** en la esquina superior derecha
2. En el menú lateral izquierdo, haz clic en **"External Tools"** (ícono de llave inglesa 🔧)
3. Busca la sección de **"Ollama"** o **"Backend"**
4. Si hay un botón **"Add Connection"** o **"Agregar Conexión"**, haz clic en él
5. Agrega cada servicio:

   **Conexión 1: Qwen**
   - **Nombre**: `Ollama-Qwen` (o cualquier nombre)
   - **URL**: `http://host.docker.internal:11437`
   - Haz clic en **"Test"** o **"Save"**

   **Conexión 2: Code**
   - **Nombre**: `Ollama-Code` (o cualquier nombre)
   - **URL**: `http://host.docker.internal:11438`
   - Haz clic en **"Test"** o **"Save"**

6. **Cierra Settings** y vuelve a la página principal
7. **Recarga la página** (F5)
8. Haz clic en el **dropdown "Select a model"**
9. Deberías ver todos los modelos:
   - `mistral:latest`
   - `qwen2.5:7b`
   - `codellama:34b`
   - `deepseek-coder:33b`

### Método 2: Si No Hay Opción "External Tools"

Algunas versiones de Open WebUI tienen la configuración en otro lugar:

1. **Settings → General**
   - Busca una sección de **"Backend"** o **"API Configuration"**
   - Agrega las URLs allí

2. **O directamente en el selector de modelos**
   - Algunas versiones permiten escribir la URL directamente
   - Prueba escribir: `http://host.docker.internal:11437` en el campo de búsqueda del selector

## 🔧 Alternativa: Configuración por Variables de Entorno

Si la interfaz web no permite agregar múltiples conexiones, puedo recrear Open WebUI con una configuración que detecte automáticamente todos los servicios.

**Ejecuta este script:**
```powershell
.\scripts\configurar-multi-ollama-open-webui.ps1
```

Luego sigue los pasos del Método 1.

## 🐛 Si No Funciona

### Verificar que los servicios estén accesibles

**En PowerShell:**
```powershell
# Verificar que los servicios Ollama responden
curl http://localhost:11437/api/tags
curl http://localhost:11438/api/tags
```

Deberías ver JSON con los modelos disponibles.

### Verificar desde Open WebUI

**Abre la consola del navegador (F12)** y revisa si hay errores al intentar agregar las conexiones.

### Reiniciar Open WebUI

```powershell
docker restart open-webui
```

Espera 30 segundos y vuelve a intentar.

## 📋 Modelos Disponibles por Servicio

| Servicio | Puerto | Modelos |
|----------|--------|---------|
| **Ollama-Mistral** | 11436 | `mistral:latest` ✅ (ya visible) |
| **Ollama-Qwen** | 11437 | `qwen2.5:7b` |
| **Ollama-Code** | 11438 | `codellama:34b`, `deepseek-coder:33b` |

## 💡 Consejos

- **Una conexión a la vez**: Agrega primero Qwen, verifica que funciona, luego agrega Code
- **Nombres descriptivos**: Usa nombres claros como "Ollama-Qwen" para identificarlos fácilmente
- **Recarga siempre**: Después de agregar una conexión, recarga la página (F5)
- **Prueba la conexión**: Usa el botón "Test" antes de guardar

## 🎯 Resultado Esperado

Después de configurar, cuando hagas clic en **"Select a model"**, deberías ver:

```
Local
├── mistral:latest (7.2B) ✅
├── qwen2.5:7b (7.6B)
├── codellama:34b (34B)
└── deepseek-coder:33b (33B)
```

---

**¿Puedes intentar agregar las conexiones en Settings → External Tools y decirme qué opciones ves?**












