# 🔧 Comando Agent Correcto

## ❌ Error Actual

```
Error: Pass --to <E.164>, --session-id, or --agent to choose a session
```

El comando `agent` requiere especificar un destino o sesión.

## ✅ Soluciones

### Opción 1: Usar --agent

```bash
cd ~/moltbot
pnpm start agent --agent test --message "hola, como estas" --local
```

### Opción 2: Ver Ayuda del Comando

```bash
cd ~/moltbot
pnpm start agent --help
```

Esto mostrará todas las opciones disponibles.

### Opción 3: Usar --to (si tienes un número de teléfono configurado)

```bash
cd ~/moltbot
pnpm start agent --to +1234567890 --message "hola" --local
```

### Opción 4: Usar --session-id

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

## 🧪 Probar

**Primero verifica la ayuda:**

```bash
cd ~/moltbot
pnpm start agent --help
```

**Luego prueba con --agent:**

```bash
pnpm start agent --agent test --message "hola, como estas" --local
```

## 📝 Nota

El flag `--local` indica que es una sesión local. Necesitas especificar también `--agent`, `--to`, o `--session-id` para identificar la sesión.

---

**Empieza con `pnpm start agent --help` para ver todas las opciones disponibles.**












