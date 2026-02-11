# 🔧 Solución Paso a Paso: Ver Modelos en Open WebUI

## 📍 Situación Actual

Estás en la página de **Settings** pero no ves la opción "Connections". Esto es normal en algunas versiones de Open WebUI.

## ✅ Solución: Dos Opciones

### Opción 1: Buscar en "External Tools" (Recomendado)

1. **En el menú lateral izquierdo de Settings**, haz clic en **"External Tools"** (tiene un ícono de llave inglesa 🔧)
2. Ahí deberías ver la configuración de **Ollama** o **Backend**
3. Verifica que la URL sea: `http://host.docker.internal:11436`
4. Haz clic en **"Test"** o **"Save"**
5. **Cierra Settings** y vuelve a la página principal
6. Busca el **dropdown "Select a model"** en la parte superior
7. Los modelos deberían aparecer

### Opción 2: Verificar en la Página Principal

Los modelos pueden aparecer automáticamente sin configuración:

1. **Cierra Settings** (haz clic en la X o presiona `Esc`)
2. En la **página principal de chat**, busca el **dropdown "Select a model"**
   - Está en la parte superior, cerca del campo de texto
   - Puede decir "Select a model" o estar vacío
3. **Haz clic en el dropdown**
4. **Espera 5-10 segundos** - Open WebUI puede tardar en cargar los modelos
5. Los modelos deberían aparecer:
   - `mistral:latest`
   - `qwen2.5:7b`
   - `codellama:34b`
   - `deepseek-coder:33b`

## 🔍 Si el Dropdown Está Vacío

Si haces clic en "Select a model" y no aparece nada:

### Paso 1: Verificar Conexión

**Abre la consola del navegador:**
1. Presiona `F12`
2. Ve a la pestaña **"Console"**
3. Busca errores en rojo relacionados con "ollama" o "model"

### Paso 2: Verificar Configuración de Open WebUI

**En PowerShell:**
```powershell
# Verificar que Open WebUI puede acceder a Ollama
docker exec open-webui curl -s http://host.docker.internal:11436/api/tags
```

Si esto funciona, deberías ver una lista de modelos en JSON.

### Paso 3: Reiniciar Open WebUI

```powershell
docker restart open-webui
```

Espera 30 segundos y vuelve a intentar.

## 🎯 Ubicación del Selector de Modelos

El selector de modelos **NO está en Settings**. Está en la **página principal de chat**:

```
┌─────────────────────────────────────┐
│  [Select a model ▼]  [⚙️ Settings]  │  ← Aquí está el selector
├─────────────────────────────────────┤
│                                     │
│         Área de Chat                │
│                                     │
│  [Escribe tu mensaje aquí...]      │
└─────────────────────────────────────┘
```

## 🔄 Si Nada Funciona

### Verificar Variables de Entorno

```powershell
# Verificar configuración actual de Open WebUI
docker inspect open-webui --format '{{range .Config.Env}}{{println .}}{{end}}' | Select-String -Pattern "OLLAMA"
```

Deberías ver:
- `OLLAMA_BASE_URL=http://host.docker.internal:11436`
- `OLLAMA_BASE_URLS=...`

### Recrear Open WebUI con Configuración Correcta

Si los modelos no aparecen después de todo esto, puedo recrear Open WebUI con una configuración que funcione mejor.

## 📋 Checklist Rápido

- [ ] Cerré Settings y volví a la página principal
- [ ] Busqué el dropdown "Select a model" en la parte superior
- [ ] Hice clic en el dropdown
- [ ] Esperé 5-10 segundos
- [ ] Revisé la consola del navegador (F12) por errores
- [ ] Verifiqué que los servicios Ollama estén corriendo

## 💡 Nota Importante

En Open WebUI, los modelos **deberían aparecer automáticamente** en el selector principal si:
1. Open WebUI está configurado con `OLLAMA_BASE_URL`
2. Los servicios Ollama están corriendo
3. Los modelos están descargados

**No necesitas configurar nada en Settings** si la variable de entorno `OLLAMA_BASE_URL` está correctamente configurada (que ya lo está).

---

**¿Puedes cerrar Settings, ir a la página principal y hacer clic en el dropdown "Select a model"? ¿Qué ves?**












