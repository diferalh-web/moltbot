# ✅ Usar Agent en Modo Local

## 📋 Solución

Para usar `--local`, necesitas especificar `--session-id` (o `--to` con un número).

## 🚀 Comando Correcto

**Ejecuta en la VM:**

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola, como estas" --local
```

## 🔍 Ver Agentes Configurados (Opcional)

Si quieres ver qué agentes están configurados:

```bash
pnpm start agents list
```

## 📝 Opciones Disponibles

Según la ayuda, para modo `--local` puedes usar:

1. **`--session-id <id>`** - ID de sesión explícito (más simple)
   ```bash
   pnpm start agent --session-id test-session --message "hola" --local
   ```

2. **`--to <number>`** - Número E.164 (ej: +15555550123)
   ```bash
   pnpm start agent --to +15555550123 --message "hola" --local
   ```

3. **`--agent <id>`** - Requiere que el agente esté configurado primero
   ```bash
   pnpm start agent --agent ops --message "hola" --local
   ```

## 🧪 Probar

**Con session-id (recomendado para pruebas):**

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola, como estas" --local
```

Esto debería:
- Usar las variables de entorno configuradas (Ollama)
- Ejecutar localmente sin gateway
- Responder usando el modelo llama2

## 📚 Notas

- `--local` ejecuta el agente embebido localmente
- Requiere las variables de entorno o configuración del modelo
- No necesita gateway corriendo
- Perfecto para pruebas

---

**Ejecuta el comando con `--session-id test-session` y debería funcionar.**












