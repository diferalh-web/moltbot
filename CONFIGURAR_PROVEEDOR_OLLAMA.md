# 🔧 Configurar Proveedor Ollama Correctamente

## ❌ Problema

OpenClaw está intentando usar "anthropic" en lugar de "ollama", a pesar de las variables de entorno.

## ✅ Solución 1: Verificar Variables de Entorno

**Primero, verifica que las variables estén configuradas:**

```bash
echo $OPENCLAW_MODEL_PROVIDER
echo $OPENCLAW_MODEL_NAME
echo $OPENCLAW_MODEL_BASE_URL
```

Deberías ver:
- `ollama`
- `llama2`
- `http://192.168.100.42:11435`

## ✅ Solución 2: Configurar Agente para Usar Ollama

**Configura el agente "main" para usar Ollama:**

```bash
cd ~/moltbot

# Ver agentes disponibles
pnpm start agents list

# Configurar agente main (si existe)
pnpm start agents add main
```

O ver la ayuda de configuración:

```bash
pnpm start agents --help
pnpm start agents add --help
```

## ✅ Solución 3: Usar Variables de Entorno con Nombre Correcto

**Puede que necesites usar nombres diferentes. Prueba:**

```bash
export OPENCLAW_MODEL_PROVIDER=ollama
export OPENCLAW_MODEL=llama2
export OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435
export OPENCLAW_BASE_URL=http://192.168.100.42:11435
```

## ✅ Solución 4: Configurar Auth Profiles

**El error menciona auth-profiles.json. Puedes crear uno:**

```bash
mkdir -p ~/.openclaw/agents/main/agent
cat > ~/.openclaw/agents/main/agent/auth-profiles.json << 'EOF'
{
  "ollama": {
    "baseURL": "http://192.168.100.42:11435"
  }
}
EOF
```

## 🧪 Probar Después de Configurar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

## 📝 Nota

OpenClaw puede estar usando una configuración por defecto que prioriza Anthropic. Necesitamos configurar explícitamente el agente para usar Ollama.

---

**Empieza verificando las variables de entorno y luego prueba configurar el agente.**












