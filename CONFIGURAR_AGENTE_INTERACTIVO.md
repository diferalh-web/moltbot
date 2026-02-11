# 📝 Configurar Agente en Modo Interactivo

## ✅ Proceso Interactivo

Cuando ejecutas `pnpm start agents add main`, te pregunta varias cosas:

### Paso 1: Workspace Directory

**Pregunta:** `Workspace directory`

**Respuesta:** Presiona `Enter` para aceptar el valor por defecto:
```
/home/moltbot2/.openclaw/workspace
```

O escribe otro directorio si prefieres.

### Paso 2: Model ID (Importante)

**Después te preguntará por el Model ID.**

**Opciones:**
- Si pregunta por modelo, escribe: `ollama` o `llama2`
- O si hay opciones, selecciona la que corresponda a Ollama

### Paso 3: Otras Preguntas

Puede preguntar por:
- **Agent directory**: Presiona `Enter` para el valor por defecto
- **Channel bindings**: Presiona `Enter` si no necesitas bindings específicos

## 📋 Secuencia Esperada

1. **Workspace directory**: `Enter` (aceptar por defecto)
2. **Model ID**: Escribe `ollama` o lo que corresponda
3. **Agent directory**: `Enter` (aceptar por defecto)
4. **Channel bindings**: `Enter` (si pregunta)

## 🔍 Si Pregunta por Modelo

**Si te muestra una lista de modelos disponibles:**
- Busca "ollama" o "llama2" en la lista
- Selecciona el número correspondiente

**Si te pide escribir el ID:**
- Escribe: `ollama`
- O: `llama2`

## ✅ Después de Configurar

**Verifica que se creó:**

```bash
pnpm start agents list
```

**Probar:**

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

---

**Presiona `Enter` en el prompt actual para continuar y ver qué pregunta después.**












