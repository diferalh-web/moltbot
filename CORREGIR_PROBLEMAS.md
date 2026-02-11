# 🔧 Corregir Problemas

## ❌ Problemas Detectados

1. **Archivo de configuración incorrecto** todavía existe y causa error
2. **Error de sintaxis** en el comando: `agent--message` debería ser `agent --message`

## ✅ Solución

### Paso 1: Eliminar Archivo de Configuración Incorrecto

```bash
rm ~/.openclaw/openclaw.json
```

O eliminar todo el directorio si quieres empezar limpio:

```bash
rm -rf ~/.openclaw
```

### Paso 2: Verificar Variables de Entorno

```bash
echo $OPENCLAW_MODEL_PROVIDER
echo $OPENCLAW_MODEL_NAME
echo $OPENCLAW_MODEL_BASE_URL
```

Deberías ver:
- `ollama`
- `llama2`
- `http://192.168.100.42:11435`

### Paso 3: Probar Moltbot con Comando Correcto

**IMPORTANTE:** Usa espacios correctamente:

```bash
cd ~/moltbot
pnpm start agent --message "hola, como estas" --local
```

**Nota:** Hay un **espacio** entre `agent` y `--message`, no `agent--message`.

## 🧪 Verificar Conexión a Ollama

Ya verificaste que Ollama responde correctamente:
```bash
curl http://192.168.100.42:11435/api/tags
```

Esto funcionó y mostró el modelo `llama2:latest`.

## 📝 Comandos Completos

```bash
# 1. Eliminar archivo incorrecto
rm ~/.openclaw/openclaw.json

# 2. Verificar variables (ya están configuradas)
echo $OPENCLAW_MODEL_PROVIDER
echo $OPENCLAW_MODEL_NAME
echo $OPENCLAW_MODEL_BASE_URL

# 3. Probar Moltbot (con espacio correcto)
cd ~/moltbot
pnpm start agent --message "hola, como estas" --local
```

---

**Ejecuta el Paso 1 primero para eliminar el archivo incorrecto, luego el Paso 3 con el comando corregido.**












