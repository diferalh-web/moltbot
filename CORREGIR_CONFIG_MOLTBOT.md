# 🔧 Corregir Configuración de Moltbot

## ❌ Error Actual

```
Error: Config validation failed: models: Unrecognized key: "default"
```

Esto significa que la estructura de configuración no usa `models.default`.

## ✅ Solución: Verificar Estructura Correcta

**Conéctate a la VM y verifica la estructura:**

```bash
ssh moltbot2@127.0.0.1 -p 2222
cd ~/moltbot

# Ver toda la configuración
pnpm start config get

# Ver solo modelos
pnpm start config get models

# O ver el archivo directamente
cat ~/.openclaw/openclaw.json
```

## 🔍 Opciones de Configuración

### Opción 1: Configurar Modelo Específico (sin "default")

```bash
cd ~/moltbot

# Configurar modelo con nombre específico
pnpm start config set models.llama2.provider ollama
pnpm start config set models.llama2.model llama2
pnpm start config set models.llama2.baseURL http://192.168.100.42:11435

# Establecer como modelo por defecto
pnpm start config set model llama2
```

### Opción 2: Editar Archivo de Configuración Directamente

```bash
# Editar configuración
nano ~/.openclaw/openclaw.json
```

Agrega o modifica:

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

### Opción 3: Usar Variables de Entorno

```bash
export OPENCLAW_MODEL_PROVIDER=ollama
export OPENCLAW_MODEL_NAME=llama2
export OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435

# Ejecutar Moltbot
cd ~/moltbot
pnpm start agent --message "Hola" --local
```

## 🧪 Probar Configuración

Después de configurar:

```bash
# Verificar configuración
pnpm start config get models

# Probar conexión a Ollama
curl http://192.168.100.42:11435/api/tags

# Probar Moltbot
pnpm start agent --message "Hola" --local
```

## 📝 Nota

La estructura exacta depende de la versión de Moltbot. Primero verifica con `pnpm start config get` para ver qué estructura usa tu versión.

---

**Ejecuta los comandos de verificación primero para ver la estructura correcta.**












