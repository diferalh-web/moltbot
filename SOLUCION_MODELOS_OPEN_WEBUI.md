# 🔧 Solución: No Veo Modelos en Open WebUI

## ✅ Verificación Rápida

He verificado que:
- ✅ Open WebUI está corriendo
- ✅ Todos los servicios Ollama están accesibles
- ✅ Los modelos están disponibles:
  - `mistral:latest` (puerto 11436)
  - `qwen2.5:7b` (puerto 11437)
  - `codellama:34b` (puerto 11438)
  - `deepseek-coder:33b` (puerto 11438)

## 🎯 Solución: Configurar en la Interfaz Web

Open WebUI a veces no detecta automáticamente los modelos. Sigue estos pasos:

### Paso 1: Acceder a Configuración

1. Abre `http://localhost:8082` en tu navegador
2. **Inicia sesión** (si no lo has hecho)
3. Busca el **ícono de engranaje (⚙️)** en la esquina superior derecha
4. Haz clic en él para abrir **Settings** o **Configuración**

### Paso 2: Configurar Conexión a Ollama

1. En el menú lateral, busca **"Connections"** o **"Conexiones"**
2. Busca la sección de **Ollama**
3. Verifica o configura la URL:
   ```
   http://host.docker.internal:11436
   ```
   O prueba con:
   ```
   http://localhost:11436
   ```

4. Haz clic en **"Test Connection"** o **"Probar Conexión"**
5. Si funciona, haz clic en **"Save"** o **"Guardar"**

### Paso 3: Recargar y Ver Modelos

1. **Recarga la página** (presiona `F5` o `Ctrl+R`)
2. Busca el **dropdown "Select a model"** en la parte superior
3. Haz clic en él
4. Deberías ver los modelos disponibles

## 🔄 Si Solo Ves un Modelo

Si solo ves `mistral:latest`, puedes agregar los demás modelos manualmente:

### Opción A: Agregar Múltiples Conexiones Ollama

1. En **Settings → Connections**
2. Agrega una nueva conexión Ollama:
   - **Nombre**: "Ollama-Qwen"
   - **URL**: `http://host.docker.internal:11437`
3. Agrega otra:
   - **Nombre**: "Ollama-Code"
   - **URL**: `http://host.docker.internal:11438`
4. Guarda y recarga

### Opción B: Usar el Selector de Modelo Manualmente

Si los modelos no aparecen en el dropdown, puedes escribir el nombre del modelo manualmente:

1. En el campo de chat, antes de escribir, busca un botón o campo para **"Model"**
2. Escribe directamente: `mistral:latest` o `qwen2.5:7b`
3. O usa el formato completo: `ollama/mistral:latest`

## 🐛 Troubleshooting

### No veo el ícono de engranaje

- Asegúrate de estar **iniciado sesión**
- Busca en el menú lateral izquierdo
- Puede estar en la parte inferior de la página

### El "Test Connection" falla

**Verifica en PowerShell:**
```powershell
# Verificar que los servicios estén corriendo
docker ps | findstr ollama

# Probar acceso directo
curl http://localhost:11436/api/tags
```

### Los modelos no aparecen después de recargar

1. **Limpia la caché del navegador:**
   - Presiona `Ctrl+Shift+Delete`
   - Selecciona "Cached images and files"
   - Haz clic en "Clear data"

2. **Prueba en modo incógnito:**
   - Presiona `Ctrl+Shift+N` (Chrome) o `Ctrl+Shift+P` (Firefox)
   - Abre `http://localhost:8082`

3. **Revisa la consola del navegador:**
   - Presiona `F12`
   - Ve a la pestaña "Console"
   - Busca errores en rojo

### Reiniciar Open WebUI

Si nada funciona, reinicia el contenedor:

```powershell
docker restart open-webui
```

Espera 30 segundos y vuelve a intentar.

## 📋 Modelos Disponibles por Servicio

| Servicio | Puerto | Modelos |
|----------|--------|---------|
| **Ollama-Mistral** | 11436 | `mistral:latest` |
| **Ollama-Qwen** | 11437 | `qwen2.5:7b` |
| **Ollama-Code** | 11438 | `codellama:34b`, `deepseek-coder:33b` |

## 💡 Consejos

- **Primera vez**: Puede tardar 10-30 segundos en cargar los modelos
- **Recarga siempre**: Después de cambiar configuración, recarga la página
- **Un modelo a la vez**: Si tienes problemas, configura solo un servicio Ollama primero
- **Verifica logs**: Si persiste el problema:
  ```powershell
  docker logs open-webui --tail 50
  ```

## 🎯 Próximos Pasos

Una vez que veas los modelos:

1. **Selecciona un modelo** del dropdown
2. **Escribe tu pregunta** en el campo de texto
3. **Presiona Enter** o haz clic en el botón de enviar
4. **¡Disfruta de tu IA local!**

---

**¿Necesitas ayuda con algún paso específico?** Puedo guiarte paso a paso.












