# ✅ Configurar Moltbot Correctamente

## 🔍 Estado Actual

La configuración de modelos no existe aún. Necesitamos verificar la estructura correcta.

## 📋 Paso 1: Verificar Configuración Actual

**En la VM, ejecuta:**

```bash
# Ver toda la configuración
pnpm start config get

# Ver archivo de configuración
cat ~/.openclaw/openclaw.json

# Ver qué archivos hay
ls -la ~/.openclaw/
```

## 🔧 Paso 2: Configurar Modelo (Opción A - CLI)

**Intenta configurar directamente sin "default":**

```bash
cd ~/moltbot

# Configurar modelo con nombre específico
pnpm start config set models.llama2.provider ollama
pnpm start config set models.llama2.model llama2
pnpm start config set models.llama2.baseURL http://192.168.100.42:11435
```

## 📝 Paso 3: Configurar Modelo (Opción B - Archivo Directo)

**Si la CLI no funciona, edita el archivo directamente:**

```bash
# Crear directorio si no existe
mkdir -p ~/.openclaw

# Editar configuración
nano ~/.openclaw/openclaw.json
```

**Agrega este contenido:**

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

Guarda con `Ctrl+O`, `Enter`, `Ctrl+X`.

## 🔄 Paso 4: Configurar Modelo (Opción C - Variables de Entorno)

**O usa variables de entorno:**

```bash
export OPENCLAW_MODEL_PROVIDER=ollama
export OPENCLAW_MODEL_NAME=llama2
export OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435

# Probar
cd ~/moltbot
pnpm start agent --message "Hola" --local
```

## 🧪 Paso 5: Probar Conexión

**Primero verifica que Ollama es accesible:**

```bash
curl http://192.168.100.42:11435/api/tags
```

**Luego prueba Moltbot:**

```bash
cd ~/moltbot
pnpm start agent --message "Hola, ¿cómo estás?" --local
```

## 📚 Estructura de Configuración Esperada

Basado en OpenClaw, la estructura debería ser:

```json
{
  "models": {
    "nombre-del-modelo": {
      "provider": "ollama",
      "model": "llama2",
      "baseURL": "http://192.168.100.42:11435"
    }
  },
  "model": "nombre-del-modelo"
}
```

## 🆘 Si Nada Funciona

**Verifica la documentación de OpenClaw:**

```bash
cd ~/moltbot
pnpm start --help
pnpm start config --help
```

O revisa el README:

```bash
cat ~/moltbot/README.md | grep -i config
cat ~/moltbot/README.md | grep -i model
```

---

**Empieza con el Paso 1 para ver la estructura actual, luego usa la opción que funcione.**












