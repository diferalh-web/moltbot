# 🚀 Comandos para Configurar Moltbot

## 📋 Paso 1: Ver Configuración Actual

**En la VM, ejecuta:**

```bash
# Ver toda la configuración
pnpm start config get

# Ver si existe el archivo
cat ~/.openclaw/openclaw.json

# Ver qué archivos hay
ls -la ~/.openclaw/
```

## 🔧 Paso 2: Crear Configuración Manualmente

**Si el archivo no existe, créalo:**

```bash
# Crear directorio si no existe
mkdir -p ~/.openclaw

# Crear archivo de configuración
cat > ~/.openclaw/openclaw.json << 'EOF'
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
EOF
```

**O edita manualmente:**

```bash
nano ~/.openclaw/openclaw.json
```

Pega este contenido:

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

Guarda: `Ctrl+O`, `Enter`, `Ctrl+X`

## 🧪 Paso 3: Probar Conexión

**Verificar que Ollama es accesible:**

```bash
curl http://192.168.100.42:11435/api/tags
```

**Probar Moltbot:**

```bash
cd ~/moltbot
pnpm start agent --message "Hola, ¿cómo estás?" --local
```

## 🔄 Paso 4: Alternativa - Variables de Entorno

**Si el archivo no funciona, usa variables de entorno:**

```bash
export OPENCLAW_MODEL_PROVIDER=ollama
export OPENCLAW_MODEL_NAME=llama2
export OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435

# Probar
cd ~/moltbot
pnpm start agent --message "Hola" --local
```

---

**Ejecuta el Paso 1 primero para ver qué hay, luego el Paso 2 para crear la configuración.**












