# 🚀 Comandos Finales para la VM

## ✅ Configurar auth-profiles.json

**Ejecuta este comando completo en PowerShell (te pedirá la contraseña):**

```powershell
ssh moltbot2@127.0.0.1 -p 2222 "mkdir -p ~/.openclaw/agents/main/agent && echo '{\"ollama\":{\"baseURL\":\"http://192.168.100.42:11435\",\"model\":\"llama2\"}}' > ~/.openclaw/agents/main/agent/auth-profiles.json && cat ~/.openclaw/agents/main/agent/auth-profiles.json"
```

**O ejecuta en la VM directamente:**

```bash
mkdir -p ~/.openclaw/agents/main/agent
echo '{"ollama":{"baseURL":"http://192.168.100.42:11435","model":"llama2"}}' > ~/.openclaw/agents/main/agent/auth-profiles.json
cat ~/.openclaw/agents/main/agent/auth-profiles.json
```

## ✅ Verificar Variables de Entorno

```bash
echo $OPENCLAW_MODEL_PROVIDER
echo $OPENCLAW_MODEL_NAME
echo $OPENCLAW_MODEL_BASE_URL
```

Deberías ver:
- `ollama`
- `llama2`
- `http://192.168.100.42:11435`

## ✅ Probar Moltbot

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola, como estas" --local
```

## 🔍 Si Aún Da Error

**Verificar que el archivo existe:**

```bash
ls -la ~/.openclaw/agents/main/agent/auth-profiles.json
cat ~/.openclaw/agents/main/agent/auth-profiles.json
```

**Verificar conexión a Ollama:**

```bash
curl http://192.168.100.42:11435/api/tags
```

---

**Ejecuta los comandos en orden y comparte los resultados si hay algún error.**












