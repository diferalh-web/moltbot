# 🚀 Comandos para Ejecutar en la VM

## ✅ Ya estás conectado a la VM

Ahora ejecuta estos comandos en tu terminal SSH:

## 📋 Paso 1: Crear Directorio y Archivo de Configuración

```bash
# Crear directorio
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

## ✅ Paso 2: Verificar que se Creó Correctamente

```bash
cat ~/.openclaw/openclaw.json
```

Deberías ver el contenido JSON.

## 🧪 Paso 3: Probar Conexión a Ollama

```bash
curl http://192.168.100.42:11435/api/tags
```

Deberías ver una lista con el modelo `llama2`.

## 🚀 Paso 4: Probar Moltbot

```bash
cd ~/moltbot
pnpm start agent --message "Hola, ¿cómo estás?" --local
```

Esto debería iniciar Moltbot y usar Ollama para responder.

---

**Copia y pega los comandos del Paso 1 primero, luego ejecuta los pasos 2-4.**
