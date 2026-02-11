# ✅ Verificar y Corregir Configuración

## ✅ Ollama Funciona Correctamente

Ollama responde y tiene el modelo `llama2:latest` disponible. El problema es la configuración de OpenClaw.

## 🔍 Paso 1: Verificar Archivos de Configuración

**Ver qué archivos tiene el agente:**

```bash
ls -la ~/.openclaw/agents/main/agent/
cat ~/.openclaw/agents/main/agent/*.json
```

## 🔧 Paso 2: Verificar Variables de Entorno

```bash
echo $OPENCLAW_MODEL_PROVIDER
echo $OPENCLAW_MODEL_NAME
echo $OPENCLAW_MODEL_BASE_URL
```

**Si no están configuradas, configúralas:**

```bash
export OPENCLAW_MODEL_PROVIDER=ollama
export OPENCLAW_MODEL_NAME=llama2
export OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435
```

## 🔧 Paso 3: Crear/Verificar config.json

**Crear o editar config.json:**

```bash
nano ~/.openclaw/agents/main/agent/config.json
```

**Asegúrate de que tenga:**

```json
{
  "model": {
    "provider": "ollama",
    "name": "llama2",
    "baseURL": "http://192.168.100.42:11435"
  }
}
```

Guarda: `Ctrl+O`, `Enter`, `Ctrl+X`

## 🔧 Paso 4: Modificar auth-profiles.json

**El problema puede ser que Synthetic está siendo usado por defecto. Modifica auth-profiles.json:**

```bash
nano ~/.openclaw/agents/main/agent/auth-profiles.json
```

**Asegúrate de que el perfil ollama esté en lastGood:**

```json
{
  "version": 1,
  "profiles": {
    "synthetic:default": {
      "type": "api_key",
      "provider": "synthetic",
      "key": "ollama",
      "baseURL": "http://192.168.100.42:11435",
      "model": "llama2"
    },
    "ollama:default": {
      "type": "api_key",
      "provider": "ollama",
      "key": "ollama",
      "baseURL": "http://192.168.100.42:11435",
      "model": "llama2"
    }
  },
  "lastGood": {
    "ollama": "ollama:default"
  }
}
```

## 🧪 Paso 5: Probar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

## 🔍 Si Aún No Funciona

**Ver qué modelo está usando el agente:**

```bash
pnpm start agents list
```

**Si muestra Synthetic, podemos intentar eliminar y recrear el agente, o buscar en la documentación cómo forzar el uso de Ollama.**

---

**Empieza verificando los archivos (Paso 1) y luego crea/verifica config.json (Paso 3).**












