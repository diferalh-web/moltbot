# ✅ Verificar Configuración de Moltbot

## 🔍 Comandos de Verificación

### 1. Ver el Contenido del Archivo

```bash
cat ~/.openclaw/openclaw.json
```

**Deberías ver:**
```json
{
  "models": {
    "llama2": {
      "provider": "ollama",
      "model": "llama2",
      "baseURL": "http://192.168.100.42:11435"
    }
  },
  "model": "llama2"
}
```

### 2. Verificar que el Archivo Existe

```bash
ls -la ~/.openclaw/openclaw.json
```

Deberías ver el archivo listado.

### 3. Verificar Formato JSON (Validar Sintaxis)

```bash
cat ~/.openclaw/openclaw.json | python3 -m json.tool
```

**O si no tienes Python:**
```bash
cat ~/.openclaw/openclaw.json | jq .
```

Si el JSON está bien formado, lo mostrará formateado. Si hay error, mostrará un mensaje de error.

### 4. Verificar que Moltbot Puede Leer la Configuración

```bash
cd ~/moltbot
pnpm start config get
```

Esto debería mostrar la configuración completa.

### 5. Probar Conexión a Ollama

```bash
curl http://192.168.100.42:11435/api/tags
```

Deberías ver una respuesta JSON con los modelos disponibles (incluyendo `llama2`).

### 6. Probar Moltbot con la Configuración

```bash
cd ~/moltbot
pnpm start agent --message "Hola" --local
```

Si todo está bien, Moltbot debería conectarse a Ollama y responder.

## ❌ Errores Comunes

### Archivo no existe
```bash
# Verificar si existe
ls ~/.openclaw/
# Si no existe, créalo de nuevo
```

### JSON mal formado
```bash
# Verificar sintaxis
cat ~/.openclaw/openclaw.json | python3 -m json.tool
# Si da error, revisa comillas, comas y llaves
```

### No puede conectar a Ollama
```bash
# Verificar que Ollama responde
curl http://192.168.100.42:11435/api/tags
# Si no responde, verifica firewall y que el contenedor esté corriendo
```

---

**Empieza con el comando 1 (`cat`) para ver el contenido, luego el 3 para validar el JSON.**












