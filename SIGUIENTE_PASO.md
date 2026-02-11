# 🚀 Siguiente Paso: Configurar la VM

## ✅ Estado Actual

- ✅ Ubuntu Server instalado
- ✅ VM lista y funcionando
- ⏳ Pendiente: Configurar SSH y transferir scripts

## 📋 Paso 1: Conectarte a la VM vía SSH

**Abre PowerShell o CMD** y ejecuta:

```powershell
ssh moltbot@127.0.0.1 -p 2222
```

**O si prefieres usar la IP directa de la VM:**

1. En la terminal de la VM (dentro de VirtualBox), ejecuta:
   ```bash
   hostname -I
   ```
   Anota la IP que aparece (ej: `10.0.2.15`)

2. Desde PowerShell en Windows:
   ```powershell
   ssh moltbot@IP_DE_LA_VM
   # Ejemplo: ssh moltbot@10.0.2.15
   ```

**Cuando te conectes:**
- Si te pide confirmar la clave, escribe `yes` y presiona Enter
- Ingresa tu contraseña (la que creaste durante la instalación)
- Deberías ver el prompt de Ubuntu: `moltbot@moltbot-server:~$`

## 📁 Paso 2: Transferir Scripts a la VM

Una vez conectado vía SSH, **abre OTRA ventana de PowerShell** (deja la SSH abierta) y ejecuta:

```powershell
cd C:\code\moltbot
.\scripts\transfer-to-vm.ps1 -VMUser moltbot -VMIP 127.0.0.1 -Port 2222 -SourcePath "scripts" -DestPath "/home/moltbot/scripts"
```

**O manualmente con SCP:**

```powershell
scp -P 2222 -r scripts\* moltbot@127.0.0.1:~/scripts/
```

Cuando te pida la contraseña, ingrésala.

## 🚀 Paso 3: Instalar Node.js y OpenClaw

**En la ventana SSH conectada a la VM**, ejecuta:

```bash
# Hacer scripts ejecutables
chmod +x ~/scripts/*.sh

# Ejecutar instalación completa
bash ~/scripts/setup-complete.sh
```

Esto instalará:
- ✅ SSH (verificación)
- ✅ Node.js 22.x
- ✅ OpenClaw (sucesor de Moltbot)
- ✅ Dependencias del browser (Chrome, Playwright)

**Tiempo estimado: 10-15 minutos**

**Alternativa automatizada desde Windows:**
```powershell
.\scripts\setup-openclaw-desarrollo.ps1 -VMUser moltbot -VMIP 127.0.0.1 -Port 2222
```

## 💻 Paso 4: Conectar Cursor

Una vez que todo esté instalado:

1. **Abre Cursor**
2. **Instala extensión**: `Remote - SSH` (si no la tienes)
3. **Conecta**: 
   - Presiona `Ctrl+Shift+P`
   - Escribe: `Remote-SSH: Connect to Host`
   - Escribe: `moltbot@127.0.0.1 -p 2222`
   - O si usas IP directa: `moltbot@IP_DE_LA_VM`
4. **Ingresa contraseña** cuando se solicite
5. **Abre carpeta**: `/home/moltbot/moltbot-project`

## ✅ Paso 5: Verificar Instalación

En Cursor (conectado a la VM) o en SSH:

```bash
node --version    # Debe ser v22.x.x
npm --version
openclaw --version # O: which openclaw
```

## 🎉 ¡Listo!

Ahora tienes:
- ✅ VM aislada con Ubuntu Server
- ✅ SSH configurado
- ✅ Node.js 22+ instalado
- ✅ OpenClaw instalado
- ✅ Cursor conectado

¡Puedes empezar a desarrollar con OpenClaw!

## 🤖 Agente de desarrollo autónomo

Para que el agente reciba solicitudes por WhatsApp/Telegram, investigue en web, codifique y pruebe apps:

1. Configura para desarrollo: `bash ~/shareFolder/configurar-openclaw-desarrollo.sh`
2. Crea el workspace: `bash ~/shareFolder/crear-workspace-desarrollo.sh`
3. Configura canales: [docs/CONFIGURAR_CANALES_WHATSAPP_TELEGRAM.md](docs/CONFIGURAR_CANALES_WHATSAPP_TELEGRAM.md)
4. Inicia el Gateway: `openclaw gateway`

Guía completa: [docs/AGENTE_DESARROLLO_OPENCLAW.md](docs/AGENTE_DESARROLLO_OPENCLAW.md)

## 🆘 Si algo falla

### No puedo conectarme vía SSH

**Verifica en la VM:**
```bash
sudo systemctl status ssh
```

Si no está corriendo:
```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

### Los scripts no se transfieren

**Verifica que la carpeta existe:**
```bash
mkdir -p ~/scripts
```

**Luego transfiere manualmente:**
```powershell
scp -P 2222 scripts\setup-complete.sh moltbot@127.0.0.1:~/scripts/
scp -P 2222 scripts\install-nodejs.sh moltbot@127.0.0.1:~/scripts/
scp -P 2222 scripts\install-openclaw.sh moltbot@127.0.0.1:~/scripts/
scp -P 2222 scripts\install-browser-deps.sh moltbot@127.0.0.1:~/scripts/
scp -P 2222 scripts\setup-ssh.sh moltbot@127.0.0.1:~/scripts/
```

### Node.js no se instala

**Ejecuta manualmente:**
```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
```

---

**¿Listo para empezar?** Sigue los pasos arriba y avísame cuando termines cada uno. 🚀












