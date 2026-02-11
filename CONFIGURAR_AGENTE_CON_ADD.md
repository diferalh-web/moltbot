# ✅ Configurar Agente con agents add

## 📋 Información del Comando

El comando `agents add` tiene la opción `--model <id>` que necesitamos usar.

## 🔍 Paso 1: Ver Modelos Disponibles

**Primero, necesitamos ver qué modelos están configurados:**

```bash
cd ~/moltbot

# Ver configuración de modelos
pnpm start config get models

# O ver si hay un comando para listar modelos
pnpm start models --help
pnpm start config --help
```

## ✅ Paso 2: Configurar el Agente con Ollama

**Si sabemos el ID del modelo, podemos configurarlo directamente:**

```bash
cd ~/moltbot

# Intentar agregar el agente main con modelo ollama
pnpm start agents add main --model ollama

# O si necesita un ID específico
pnpm start agents add main --model llama2
```

## 🔄 Paso 3: Configuración Interactiva

**Si no especificamos --model, debería preguntar interactivamente:**

```bash
cd ~/moltbot
pnpm start agents add main
```

Durante la configuración, debería preguntarte por el modelo. Selecciona o especifica Ollama.

## 📝 Paso 4: Verificar Variables de Entorno

**Asegúrate de que las variables estén configuradas antes de agregar el agente:**

```bash
export OPENCLAW_MODEL_PROVIDER=ollama
export OPENCLAW_MODEL_NAME=llama2
export OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435

# Verificar
echo $OPENCLAW_MODEL_PROVIDER
echo $OPENCLAW_MODEL_NAME
echo $OPENCLAW_MODEL_BASE_URL
```

## 🧪 Paso 5: Probar Después de Configurar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

## 🔍 Si No Funciona

**Ver qué agentes existen:**

```bash
pnpm start agents list
```

**Ver estructura de archivos:**

```bash
find ~/.openclaw -name "*.json" -type f
ls -la ~/.openclaw/agents/
```

---

**Empieza con `pnpm start config get models` para ver qué modelos están disponibles, luego usa `agents add` con la opción `--model`.**












