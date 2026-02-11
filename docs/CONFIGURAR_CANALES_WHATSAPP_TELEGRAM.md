# Configurar canales WhatsApp y Telegram

Para que el agente reciba solicitudes por WhatsApp o Telegram, debes configurar los canales y tener el Gateway en ejecución.

## Requisitos previos

- OpenClaw instalado en la VM
- Gateway corriendo: `openclaw gateway`
- Puertos accesibles (el Gateway usa 18789 por defecto; si accedes remotamente, configura tunnel SSH o expón el puerto)

## WhatsApp

### Configuración

1. **Configurar en openclaw.json** (o durante `openclaw onboard`):

```json
{
  "channels": {
    "whatsapp": {
      "dmPolicy": "allowlist",
      "allowFrom": ["+521234567890"]
    }
  }
}
```

- `dmPolicy`: `allowlist` (solo números listados), `pairing` (código de emparejamiento), u `open`
- `allowFrom`: lista de números en formato E.164 (ej: +521234567890)

2. **Login (escanear QR)**:
   - Con el Gateway corriendo, ejecuta en la VM:
   ```bash
   openclaw channels login whatsapp
   ```
   - Se mostrará un QR en la terminal (ASCII)
   - En tu teléfono: WhatsApp → Configuración → Dispositivos vinculados → Vincular dispositivo
   - Escanea el QR que aparece en la terminal SSH

3. Las credenciales se guardan en `~/.openclaw/credentials/whatsapp/`.

### Notas

- Usa preferiblemente un número dedicado (no tu WhatsApp personal)
- El QR se muestra en la terminal; no necesitas interfaz gráfica en la VM

## Telegram

### Configuración

1. **Obtener token del bot**:
   - Abre Telegram y busca @BotFather
   - Envía `/newbot` y sigue las instrucciones
   - Copia el token que te devuelve

2. **Añadir el canal**:
   ```bash
   openclaw channels add --channel telegram --token TU_BOT_TOKEN
   ```

   O configurar en openclaw.json:

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "123456:ABC-DEF...",
      "dmPolicy": "pairing"
    }
  }
}
```

3. **Emparejamiento**: por defecto usa `pairing`; la primera vez que alguien escribe al bot, recibe un código. Aprueba con:
   ```bash
   openclaw pairing approve telegram <CODIGO>
   ```

### Variables de entorno

Puedes usar `TELEGRAM_BOT_TOKEN` en lugar de config:
```bash
export TELEGRAM_BOT_TOKEN="123456:ABC-DEF..."
```

## Port forwarding para acceso remoto

Si el Gateway corre en una VM y accedes desde tu PC:

```bash
ssh -N -L 18789:127.0.0.1:18789 usuario@127.0.0.1 -p 2222
```

Deja esa sesión abierta; el puerto 18789 de tu PC quedará tunnelado al Gateway en la VM.

## Verificar estado

```bash
openclaw channels status
openclaw channels list
```

## Referencias

- [OpenClaw Channels CLI](https://docs.molt.bot/cli/channels)
- [WhatsApp (OpenClaw)](https://docs.clawd.bot/channels/whatsapp)
- [Telegram (OpenClaw)](https://docs.clawd.bot/channels/telegram)
