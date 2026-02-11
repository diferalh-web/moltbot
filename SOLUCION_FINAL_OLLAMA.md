# ✅ Solución Final - Configurar Ollama

## ❌ Problema

OpenClaw intenta usar "anthropic" en lugar de "ollama".

## ✅ Solución: Crear auth-profiles.json

**Ejecuta estos comandos en la VM:**

```bash
# Crear directorio del agente
mkdir -p ~/.openclaw/agents/main/agent

# Crear archivo de configuración para Ollama
cat > ~/.openclaw/agents/main/agent/auth-profiles.json << 'EOF'
{
  "ollama": {
    "baseURL": "http://192.168.100.42:11435"
  }
}
EOF
```

**O con echo (más simple):**

```bash
mkdir -p ~/.openclaw/agents/main/agent
echo '{"ollama":{"baseURL":"http://192.168.100.42:11435"}}' > ~/.openclaw/agents/main/agent/auth-profiles.json
```

## ✅ Verificar

```bash
cat ~/.openclaw/agents/main/agent/auth-profiles.json
```

Deberías ver el JSON con la configuración de Ollama.

## 🧪 Probar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola, como estas" --local
```

## 📝 Comandos Correctos

**Para ver agentes (comando correcto):**
```bash
pnpm start agents list
```

**Para agregar agente:**
```bash
pnpm start agents add --help
```

## 🔍 Si Aún No Funciona

**Verificar que las variables de entorno estén activas:**

```bash
echo $OPENCLAW_MODEL_PROVIDER
echo $OPENCLAW_MODEL_NAME
echo $OPENCLAW_MODEL_BASE_URL
```

**Y verificar que Ollama responde:**

```bash
curl http://192.168.100.42:11435/api/tags
```

---

**Ejecuta primero el comando para crear auth-profiles.json, luego prueba de nuevo.**












