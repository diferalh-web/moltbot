# 🔧 Solución: Usar agents add

## ❌ Problema

OpenClaw sigue intentando usar "anthropic" a pesar de todas las configuraciones. El error sugiere usar `openclaw agents add <id>`.

## ✅ Solución: Configurar Agente con agents add

**El error menciona específicamente usar este comando. Probémoslo:**

```bash
cd ~/moltbot

# Ver ayuda del comando
pnpm start agents add --help

# Ver agentes disponibles
pnpm start agents list

# Intentar agregar/configurar el agente main
pnpm start agents add main
```

## 🔍 Verificar Estructura de Directorios

**Ver qué hay en el directorio del agente:**

```bash
ls -la ~/.openclaw/agents/
ls -la ~/.openclaw/agents/main/
ls -la ~/.openclaw/agents/main/agent/
cat ~/.openclaw/agents/main/agent/*.json
```

## 🔄 Alternativa: Buscar Configuración Principal

**Puede que haya un directorio principal con configuración:**

```bash
# Buscar archivos de configuración
find ~/.openclaw -name "*.json" -type f
find ~/.openclaw -name "auth-profiles.json" -type f

# Ver estructura completa
tree ~/.openclaw 2>/dev/null || find ~/.openclaw -type f
```

## 📝 Crear Configuración desde Cero

**Si nada funciona, intentemos eliminar y recrear:**

```bash
# Hacer backup
cp -r ~/.openclaw/agents/main/agent ~/.openclaw/agents/main/agent.backup

# Eliminar configuración actual
rm -rf ~/.openclaw/agents/main/agent/*.json

# Usar el comando oficial para configurar
cd ~/moltbot
pnpm start agents add main
```

**Durante la configuración, debería preguntarte por el proveedor. Selecciona "ollama".**

## 🧪 Verificar Variables de Entorno

**Asegúrate de que las variables estén activas:**

```bash
echo $OPENCLAW_MODEL_PROVIDER
echo $OPENCLAW_MODEL_NAME
echo $OPENCLAW_MODEL_BASE_URL

# Si no están, configúralas de nuevo
export OPENCLAW_MODEL_PROVIDER=ollama
export OPENCLAW_MODEL_NAME=llama2
export OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435
```

## 🔍 Ver Documentación

**Ver si hay documentación en el proyecto:**

```bash
cd ~/moltbot
cat README.md | grep -i agent
cat README.md | grep -i ollama
cat README.md | grep -i config
```

---

**Empieza con `pnpm start agents add --help` para ver las opciones disponibles.**












