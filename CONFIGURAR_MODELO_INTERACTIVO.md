# ✅ Configurar Modelo en Modo Interactivo

## 📋 Proceso Actual

El asistente pregunta: **"Configure model/auth for this agent now?"**

## ✅ Acción: Seleccionar "Yes"

**Usa las flechas del teclado para moverte:**
- `↑` o `↓` para cambiar entre opciones
- `Espacio` o `Enter` para seleccionar

**Selecciona: `Yes`**

## 📝 Próximas Preguntas Esperadas

Después de seleccionar "Yes", probablemente te preguntará:

1. **Model Provider** o **Provider**:
   - Selecciona o escribe: `ollama`

2. **Model Name** o **Model**:
   - Escribe: `llama2`

3. **Base URL** o **API Endpoint**:
   - Escribe: `http://192.168.100.42:11435`

4. **API Key** (si pregunta):
   - Ollama no requiere API key real
   - Puedes escribir: `ollama` o dejar vacío
   - O presionar `Enter` para omitir

## 🔍 Si Muestra Lista de Proveedores

Si muestra una lista de proveedores disponibles:
- Busca "ollama" en la lista
- Selecciona el número correspondiente
- O escribe "ollama" directamente

## ✅ Después de Configurar

**El asistente debería:**
- Crear el agente con la configuración de Ollama
- Mostrar un resumen de la configuración
- Confirmar que el agente fue creado

## 🧪 Verificar y Probar

**Después de que termine:**

```bash
# Ver agentes
pnpm start agents list

# Probar
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

---

**Selecciona "Yes" ahora y luego configura Ollama cuando te pregunte.**












