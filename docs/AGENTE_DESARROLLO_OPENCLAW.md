# Agente de desarrollo autónomo con OpenClaw

Guía para usar el agente que recibe solicitudes por WhatsApp/Telegram, investiga en web, codifica, prueba en navegador e itera hasta confirmar que la aplicación funciona.

## Caso de uso

1. Envías por WhatsApp o Telegram: "Crea una app de lista de tareas en React"
2. El agente planifica, investiga, implementa, prueba en el navegador e itera hasta que funcione
3. Solo cuando está listo te avisa
4. Tú revisas el código por Cursor y la app por el navegador (con port forwarding)

## Requisitos previos

- OpenClaw instalado en la VM
- Chrome headless (script `install-browser-deps.sh`)
- BRAVE_API_KEY para búsqueda web (obtener en [brave.com/search/api](https://brave.com/search/api))
- Canales WhatsApp y/o Telegram configurados
- Gateway en ejecución: `openclaw gateway`

## Configuración rápida

### Opción 1: Script automatizado (desde Windows)

```powershell
cd c:\code\moltbot
.\scripts\setup-openclaw-desarrollo.ps1 -VMUser moltbot -VMIP 127.0.0.1 -Port 2222
```

Te pedirá BRAVE_API_KEY. Si la omites, puedes configurarla después con `openclaw configure --section web`.

### Opción 2: Manual en la VM

```bash
# 1. Instalar OpenClaw y browser deps (si no está hecho)
bash ~/scripts/install-openclaw.sh
bash ~/scripts/install-browser-deps.sh

# 2. Configurar para desarrollo
cd ~/shareFolder
bash configurar-openclaw-desarrollo.sh 192.168.100.42  # HOST_IP de Ollama

# 3. Crear workspace
bash crear-workspace-desarrollo.sh

# 4. Configurar BRAVE_API_KEY
export BRAVE_API_KEY="tu_api_key"
# O: openclaw configure --section web
```

## Configurar canales

Ver [CONFIGURAR_CANALES_WHATSAPP_TELEGRAM.md](CONFIGURAR_CANALES_WHATSAPP_TELEGRAM.md).

- **WhatsApp:** `openclaw channels login whatsapp` (QR en terminal)
- **Telegram:** `openclaw channels add --channel telegram --token <BOT_TOKEN>`

## Ejemplo de prompt

Por WhatsApp o Telegram:

> Crea una app de lista de tareas en React. Debe permitir agregar, marcar como hechas y eliminar tareas.

El agente:
1. Planificará las fases
2. Buscará documentación con `web_search`
3. Creará el proyecto con `npx create-react-app` o similar
4. Implementará el código
5. Iniciará el servidor y probará con el browser
6. Iterará hasta que funcione
7. Te avisará cuando esté listo

## Cómo revisar el resultado

### Código

Conéctate por Cursor (Remote-SSH) a la VM y abre:
`~/.openclaw/workspace`

### Aplicación en el navegador

Si la VM fue creada con `create-vm.ps1` (o añadiste port forwarding), desde tu PC:

- http://localhost:3000 (React, Next.js)
- http://localhost:5173 (Vite)
- http://localhost:8080 (Express)

Para VM existente sin esos puertos, usa túnel SSH:
```bash
ssh -L 3000:localhost:3000 usuario@127.0.0.1 -p 2222
```
Luego abre http://localhost:3000 en tu navegador.

## Solución de problemas

### Browser falla ("Failed to start Chrome CDP")

- Verifica que Chrome esté instalado: `which google-chrome-stable`
- Revisa [docs.molt.bot/tools/browser-linux-troubleshooting](https://docs.molt.bot/tools/browser-linux-troubleshooting)
- En `openclaw.json`: `browser.executablePath: "/usr/bin/google-chrome-stable"`, `headless: true`, `noSandbox: true`

### web_search no funciona

- Configura BRAVE_API_KEY: `openclaw configure --section web` o `export BRAVE_API_KEY="..."`
- Verifica que `tools.web.search.enabled` esté en true en openclaw.json

### Timeout del agente

- Aumenta `agents.defaults.timeoutSeconds` en openclaw.json (ej: 1200)
- Tareas muy largas pueden requerir dividirse en sub-agentes

### El agente no planifica

- Asegúrate de que AGENTS.md en el workspace tenga las instrucciones de planificación (usa `crear-workspace-desarrollo.sh`)

## Orden de scripts

1. `create-vm.ps1` - Crear VM (incluye port forwarding)
2. Instalar Ubuntu Server, configurar SSH
3. `setup-complete.sh` - Node, OpenClaw, browser deps (en la VM)
4. `configurar-openclaw-desarrollo.sh` - Config openclaw.json
5. `crear-workspace-desarrollo.sh` - Workspace con AGENTS.md
6. Configurar canales (WhatsApp/Telegram)
7. `openclaw gateway` - Iniciar

O todo en uno: `setup-openclaw-desarrollo.ps1` desde Windows.
