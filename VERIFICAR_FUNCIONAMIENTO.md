# ✅ Verificar si Moltbot está Funcionando

## 📋 Estado Actual

El comando se está ejecutando. Puede tardar unos segundos en procesar.

## ⏳ Esperar Respuesta

**El agente debería:**
1. Conectarse a Ollama
2. Procesar el mensaje "hola"
3. Generar una respuesta usando llama2
4. Mostrar la respuesta

## 🔍 Si Tarda Mucho

**Si pasa más de 30-60 segundos sin respuesta:**

1. **Presiona `Ctrl+C` para cancelar**
2. **Verifica que Ollama responde:**

```bash
curl http://192.168.100.42:11435/api/tags
```

3. **Verifica las variables de entorno:**

```bash
echo $OPENCLAW_MODEL_PROVIDER
echo $OPENCLAW_MODEL_NAME
echo $OPENCLAW_MODEL_BASE_URL
```

4. **Verifica la configuración:**

```bash
cat ~/.openclaw/agents/main/agent/config.json
cat ~/.openclaw/agents/main/agent/auth-profiles.json | grep -A 5 "lastGood"
```

## ✅ Si Funciona

**Deberías ver:**
- Una respuesta del modelo llama2
- El mensaje procesado
- Posiblemente logs de la conexión

## 🔍 Ver Logs Detallados

**Si quieres ver más información:**

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local --verbose on
```

## 📝 Nota

La primera vez puede tardar más porque:
- Necesita cargar el modelo
- Establecer la conexión con Ollama
- Procesar la primera solicitud

---

**Espera unos segundos a ver si responde. Si no responde en 30-60 segundos, cancela con Ctrl+C y verifica la configuración.**












