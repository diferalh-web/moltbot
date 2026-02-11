# 🧪 Comandos para Probar Moltbot

## Comando Correcto

El comando que intentaste usar necesita un `--session-id` o `--to`:

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "test" --local
```

O si quieres usar un número de teléfono (si tienes WhatsApp/Telegram configurado):

```bash
pnpm start agent --to +1234567890 --message "test"
```

## Variaciones Útiles

### Probar con un mensaje simple
```bash
cd ~/moltbot
pnpm start agent --session-id test-$(date +%s) --message "Hola, ¿cómo estás?" --local
```

### Probar con un session-id fijo (mantiene contexto)
```bash
cd ~/moltbot
pnpm start agent --session-id mi-sesion --message "¿Qué puedes hacer?" --local
```

### Ver ayuda completa
```bash
cd ~/moltbot
pnpm start agent --help
```

### Ver estado del sistema
```bash
cd ~/moltbot
pnpm start health
pnpm start status
```

## Verificar que Funciona Después de Aplicar Seguridad

Después de ejecutar `aplicar-mejoras-seguridad.sh`, verifica que todo sigue funcionando:

```bash
# 1. Verificar configuración
cd ~/moltbot
pnpm start config get

# 2. Probar el agente
pnpm start agent --session-id test-seguridad --message "test" --local

# 3. Si funciona, deberías ver una respuesta del asistente
```

## Solución de Problemas

### Error: "Pass --to <E.164>, --session-id, or --agent"
**Solución:** Agrega `--session-id` al comando:
```bash
pnpm start agent --session-id test --message "hola" --local
```

### Error: "No model configured"
**Solución:** Verifica la configuración:
```bash
pnpm start config get models
cat ~/.openclaw/agents/main/agent/config.json
```

### Error: "Connection refused" o problemas de red
**Solución:** Verifica que Ollama esté accesible:
```bash
curl http://192.168.100.42:11435/api/tags
```

---

**Nota:** El `--local` indica que se ejecuta localmente sin necesidad de un gateway externo.












