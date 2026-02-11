# ✅ Usar Synthetic con Ollama

## 💡 Idea

**Synthetic** es "Anthropic-compatible (multi-model)" y puede funcionar con Ollama ya que Ollama tiene una API compatible.

## ✅ Paso 1: Seleccionar Synthetic

**En el prompt actual:**
- Usa las flechas `↑` `↓` para moverte a "Synthetic"
- Presiona `Enter` para seleccionar

## 📋 Paso 2: Configuración Esperada

Después de seleccionar Synthetic, probablemente te preguntará:

1. **API Endpoint** o **Base URL**:
   - Escribe: `http://192.168.100.42:11435`

2. **API Key** (si pregunta):
   - Ollama no requiere API key real
   - Puedes escribir: `ollama` o `dummy`
   - O presionar `Enter` para omitir

3. **Model Name** (si pregunta):
   - Escribe: `llama2`

## 🔧 Paso 3: Si Pregunta por Modelo Específico

**Si te muestra opciones de modelos:**
- Busca "llama2" en la lista
- O escribe "llama2" directamente

## ✅ Paso 4: Verificar Configuración

**Después de que termine la configuración:**

```bash
# Ver agentes
pnpm start agents list

# Ver configuración del agente
cat ~/.openclaw/agents/main/agent/auth-profiles.json
```

## 🧪 Paso 5: Probar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

## 🔍 Si No Funciona Directamente

**Si Synthetic no acepta Ollama directamente, podemos editar el archivo después:**

```bash
nano ~/.openclaw/agents/main/agent/auth-profiles.json
```

**Y modificar para apuntar a Ollama:**

```json
{
  "synthetic": {
    "baseURL": "http://192.168.100.42:11435",
    "apiKey": "ollama",
    "model": "llama2"
  }
}
```

---

**Selecciona "Synthetic" ahora y ve qué opciones te da. Es una buena idea porque es multi-model y compatible con Anthropic.**












