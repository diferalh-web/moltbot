# 🔧 Solución: Error al Configurar Ollama en Open WebUI

## ❌ Problema

Estás intentando configurar Ollama en **"External Tools" → "Manage Tool Servers"**, pero esa sección es para **servidores OpenAPI compatibles**, no para Ollama como backend de modelos.

## ✅ Solución Correcta

### Opción 1: Buscar la Sección Correcta de Ollama

En Open WebUI, la configuración de Ollama como backend está en otro lugar:

1. **Cierra el modal "Edit Connection"** (haz clic en la X)
2. **Busca en el menú lateral izquierdo** una de estas opciones:
   - **"Connections"** o **"Conexiones"**
   - **"Backend"** o **"Backend Configuration"**
   - **"Ollama"** (puede estar como sección separada)
   - O busca en **"General"** → puede haber una subsección de Ollama

3. Si encuentras la sección de Ollama, ahí deberías poder agregar:
   - URL: `http://host.docker.internal:11437` (para Qwen)
   - URL: `http://host.docker.internal:11438` (para Code)

### Opción 2: Configurar mediante Variables de Entorno

Si no encuentras la sección correcta en la interfaz, puedo recrear Open WebUI con una configuración que detecte automáticamente todos los servicios Ollama.

**Ejecuta este comando:**
```powershell
.\scripts\configurar-multi-ollama-open-webui.ps1
```

Luego, los modelos deberían aparecer automáticamente.

### Opción 3: Usar Solo Mistral (Solución Temporal)

Por ahora, puedes usar solo **Mistral** que ya está funcionando. Es un modelo muy versátil que puede:
- Chat general
- Programación básica
- Preguntas y respuestas

Los demás modelos (Qwen, CodeLlama) los puedes agregar después cuando encontremos la sección correcta.

## 🔍 Dónde Buscar la Configuración de Ollama

En diferentes versiones de Open WebUI, la configuración puede estar en:

1. **Settings → Connections** (más común)
2. **Settings → General → Backend**
3. **Settings → Backend Configuration**
4. **Directamente en el selector de modelos** (algunas versiones permiten escribir URLs)

## 🐛 Si No Encuentras la Sección

**Puedo ayudarte de dos formas:**

1. **Recrear Open WebUI** con una configuración que detecte automáticamente todos los servicios Ollama
2. **Verificar la versión de Open WebUI** y buscar la documentación específica para esa versión

## 📋 Modelos Disponibles

Aunque no los veas en el selector todavía, estos modelos están disponibles y funcionando:

- ✅ `mistral:latest` (puerto 11436) - **Ya visible**
- ⏳ `qwen2.5:7b` (puerto 11437) - Necesita configuración
- ⏳ `codellama:34b` (puerto 11438) - Necesita configuración
- ⏳ `deepseek-coder:33b` (puerto 11438) - Necesita configuración

## 💡 Recomendación

**Por ahora, usa Mistral** que ya está funcionando. Es un modelo excelente para la mayoría de tareas. Podemos configurar los demás modelos después.

---

**¿Quieres que:**
1. **Te ayude a buscar la sección correcta** en Settings?
2. **Recrear Open WebUI** con configuración automática?
3. **Usar solo Mistral** por ahora?












