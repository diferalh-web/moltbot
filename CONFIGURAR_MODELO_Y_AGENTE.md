# 🔧 Configurar Modelo y Agente Paso a Paso

## ❌ Problema

No hay modelos configurados en OpenClaw. Necesitamos configurar Ollama primero.

## ✅ Solución: Configurar Modelo Primero

### Paso 1: Verificar Variables de Entorno

```bash
export OPENCLAW_MODEL_PROVIDER=ollama
export OPENCLAW_MODEL_NAME=llama2
export OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435

# Verificar
echo $OPENCLAW_MODEL_PROVIDER
echo $OPENCLAW_MODEL_NAME
echo $OPENCLAW_MODEL_BASE_URL
```

### Paso 2: Ver Ayuda de Config

```bash
cd ~/moltbot
pnpm start config --help
pnpm start config set --help
```

### Paso 3: Intentar Configurar Modelo

**Opción A: Configurar modelo directamente**

```bash
cd ~/moltbot

# Intentar configurar modelo
pnpm start config set model.provider ollama
pnpm start config set model.name llama2
pnpm start config set model.baseURL http://192.168.100.42:11435
```

**Opción B: Ver estructura de configuración**

```bash
# Ver toda la configuración
pnpm start config get

# Ver archivo de configuración
cat ~/.openclaw/openclaw.json 2>/dev/null || echo "Archivo no existe"
```

### Paso 4: Agregar Agente con Modelo

**Una vez configurado el modelo, agregar el agente:**

```bash
cd ~/moltbot

# Modo interactivo (recomendado)
pnpm start agents add main

# O especificar modelo directamente
pnpm start agents add main --model ollama
```

### Paso 5: Verificar Agente Creado

```bash
pnpm start agents list
```

### Paso 6: Probar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

## 🔍 Alternativa: Usar Solo Variables de Entorno

**Si la configuración no funciona, intenta usar solo variables de entorno:**

```bash
# Configurar variables
export OPENCLAW_MODEL_PROVIDER=ollama
export OPENCLAW_MODEL_NAME=llama2
export OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435

# Agregar agente (debería usar las variables)
cd ~/moltbot
pnpm start agents add main

# Probar
pnpm start agent --session-id test-session --message "hola" --local
```

## 📝 Nota

OpenClaw puede requerir que el modelo esté configurado antes de agregar el agente, o puede usar las variables de entorno directamente.

---

**Empieza con el Paso 1 (variables de entorno) y luego el Paso 4 (agents add) en modo interactivo.**












