# 🔍 Cómo Seleccionar Modelos en Open WebUI

## ❌ Problema: No ves los modelos en el selector

Si no ves los modelos en el dropdown de Open WebUI, sigue estos pasos:

## ✅ Solución Paso a Paso

### Paso 1: Verificar que los modelos estén disponibles

**En PowerShell (host):**
```powershell
# Verificar modelos en cada servicio
curl http://localhost:11436/api/tags
curl http://localhost:11437/api/tags
curl http://localhost:11438/api/tags
```

### Paso 2: Acceder a la configuración de Open WebUI

1. Abre `http://localhost:8082` en tu navegador
2. Inicia sesión con tu cuenta
3. Haz clic en el **ícono de engranaje (⚙️)** en la esquina superior derecha
4. Ve a la sección **"Connections"** o **"Conexiones"**

### Paso 3: Configurar Ollama manualmente

Si los modelos no aparecen automáticamente:

1. En la sección de **Ollama**, verifica que la URL sea:
   ```
   http://host.docker.internal:11436
   ```
   O prueba con:
   ```
   http://localhost:11436
   ```

2. Haz clic en **"Test Connection"** o **"Probar Conexión"**

3. Si funciona, haz clic en **"Save"** o **"Guardar"**

### Paso 4: Recargar la página

1. Presiona `F5` o `Ctrl+R` para recargar la página
2. Los modelos deberían aparecer ahora en el selector

### Paso 5: Seleccionar un modelo

1. Busca el **dropdown "Select a model"** en la parte superior de la interfaz
2. Haz clic en él
3. Deberías ver:
   - `mistral:latest` (desde puerto 11436)
   - `qwen2.5:7b` (desde puerto 11437)
   - `codellama:34b` (desde puerto 11438)
   - `deepseek-coder:33b` (desde puerto 11438)

4. Selecciona el modelo que quieras usar

## 🔧 Si Aún No Funciona

### Opción A: Configurar múltiples instancias de Ollama

Open WebUI puede tener problemas detectando múltiples instancias. Prueba configurando cada una manualmente:

1. Ve a **Settings → Connections**
2. Agrega cada instancia de Ollama:
   - **Ollama 1**: `http://host.docker.internal:11436` (Mistral)
   - **Ollama 2**: `http://host.docker.internal:11437` (Qwen)
   - **Ollama 3**: `http://host.docker.internal:11438` (Code)

### Opción B: Usar solo una instancia principal

Si prefieres simplicidad, puedes usar solo Ollama-Mistral:

1. Ve a **Settings → Connections**
2. Configura solo: `http://host.docker.internal:11436`
3. Los modelos de Mistral deberían aparecer

### Opción C: Verificar logs

**En PowerShell:**
```powershell
# Ver logs de Open WebUI
docker logs open-webui --tail 50

# Buscar errores relacionados con modelos
docker logs open-webui 2>&1 | Select-String -Pattern "model|error|OLLAMA"
```

## 📋 Modelos Disponibles

| Modelo | Servicio | Puerto | Uso |
|--------|----------|--------|-----|
| `mistral:latest` | Ollama-Mistral | 11436 | Chat general |
| `qwen2.5:7b` | Ollama-Qwen | 11437 | Chat alternativo |
| `codellama:34b` | Ollama-Code | 11438 | Programación |
| `deepseek-coder:33b` | Ollama-Code | 11438 | Programación avanzada |

## 🎯 Consejos

- **Primera vez**: Puede tardar unos segundos en cargar los modelos
- **Recarga**: Siempre recarga la página después de cambiar la configuración
- **Navegador**: Prueba en modo incógnito si hay problemas de caché
- **Consola**: Abre las herramientas de desarrollador (F12) y revisa la consola por errores

## 🆘 Si Nada Funciona

1. **Reinicia Open WebUI:**
   ```powershell
   docker restart open-webui
   ```

2. **Verifica que los servicios Ollama estén corriendo:**
   ```powershell
   docker ps | findstr ollama
   ```

3. **Prueba acceder directamente a Ollama:**
   ```powershell
   curl http://localhost:11436/api/tags
   ```

---

**¿Necesitas ayuda con algún paso específico?**












