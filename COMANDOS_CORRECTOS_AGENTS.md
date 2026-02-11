# ✅ Comandos Correctos para Agents

## ❌ Error Común

El comando correcto es `pnpm start agents` (no solo `pnpm agents`).

## ✅ Comandos Correctos

**Ver ayuda:**

```bash
cd ~/moltbot
pnpm start agents add --help
```

**Ver agentes:**

```bash
pnpm start agents list
```

**Agregar/configurar agente:**

```bash
pnpm start agents add main
```

## 📋 Secuencia Completa

**Ejecuta estos comandos en orden:**

```bash
cd ~/moltbot

# 1. Ver ayuda
pnpm start agents add --help

# 2. Ver agentes existentes
pnpm start agents list

# 3. Intentar agregar/configurar el agente main
pnpm start agents add main
```

## 🔍 Si agents add no funciona

**Ver estructura de archivos:**

```bash
# Ver todos los archivos de configuración
find ~/.openclaw -name "*.json" -type f

# Ver contenido del agente
ls -la ~/.openclaw/agents/main/agent/
cat ~/.openclaw/agents/main/agent/*.json
```

## 📝 Nota Importante

**Todos los comandos de OpenClaw requieren `pnpm start` antes del comando:**
- ✅ `pnpm start agents list`
- ✅ `pnpm start agents add`
- ✅ `pnpm start agent --session-id ...`
- ❌ `pnpm agents list` (incorrecto)
- ❌ `pnpm agents add` (incorrecto)

---

**Ejecuta `pnpm start agents add --help` para ver las opciones disponibles.**












