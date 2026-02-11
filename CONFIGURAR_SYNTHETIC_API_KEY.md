# 🔑 Configurar API Key para Synthetic con Ollama

## ✅ Solución

Ollama no requiere una API key real, pero Synthetic la pide. Puedes usar cualquier valor como placeholder.

## 📝 Opciones para API Key

**Escribe cualquiera de estas opciones:**

1. **`ollama`** (recomendado)
2. **`dummy`**
3. **`not-required`**
4. **`ollama-key`**

O simplemente presiona `Enter` si te permite omitir.

## 🔄 Después de la API Key

**Probablemente te preguntará por:**

1. **Base URL** o **API Endpoint**:
   - Escribe: `http://192.168.100.42:11435`

2. **Model Name** o **Model**:
   - Escribe: `llama2`

## ✅ Configuración Completa Esperada

Después de configurar, deberías tener:
- Provider: Synthetic
- API Key: `ollama` (o el valor que escribas)
- Base URL: `http://192.168.100.42:11435`
- Model: `llama2`

## 🧪 Probar Después

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

## 🔍 Si No Funciona

**Podemos editar el archivo después para ajustar la configuración:**

```bash
cat ~/.openclaw/agents/main/agent/auth-profiles.json
nano ~/.openclaw/agents/main/agent/auth-profiles.json
```

---

**Escribe `ollama` como API key y continúa con la configuración.**












