# 🐧 Instalar Ubuntu Server en la VM

## ✅ Estado Actual

La máquina virtual está completamente configurada:
- ✅ Nombre: `moltbot-vm`
- ✅ RAM: 4 GB
- ✅ CPU: 2 procesadores
- ✅ Disco: 30 GB
- ✅ Red: NAT con port forwarding (2222 -> 22)
- ✅ ISO de Ubuntu montada

## 🚀 Paso 1: Iniciar la VM

1. **Abre VirtualBox**
2. **Selecciona** `moltbot-vm` en la lista
3. **Haz clic en "Iniciar"** (flecha verde)

La VM se abrirá en una ventana nueva y comenzará a arrancar desde el ISO de Ubuntu.

## 📋 Paso 2: Instalar Ubuntu Server

Sigue estos pasos en la ventana de la VM:

### 2.1 Seleccionar Idioma
- Elige tu idioma preferido
- Presiona **Enter**

### 2.2 Actualizar Instalador (si aparece)
- Si pregunta si quieres actualizar el instalador, elige **Actualizar al instalador más reciente**
- Espera a que descargue las actualizaciones

### 2.3 Tipo de Instalación
- Selecciona **Ubuntu Server** (instalación normal)
- Presiona **Enter**

### 2.4 Configuración de Red
- Acepta la configuración de red por defecto (DHCP)
- Presiona **Enter**

### 2.5 Proxy (si aparece)
- Déjalo vacío (a menos que uses proxy)
- Presiona **Enter**

### 2.6 Archivo de Instalación Ubuntu
- Usa el mirror por defecto
- Presiona **Enter**

### 2.7 Configuración de Almacenamiento
- Selecciona **Use an entire disk** (usar todo el disco)
- Presiona **Enter**
- Selecciona el disco virtual (debería ser el único)
- Presiona **Enter**
- Confirma escribiendo **yes** y presiona **Enter**
- Presiona **Enter** para continuar

### 2.8 Perfil del Sistema ⚠️ IMPORTANTE
Configura estos valores:

- **Your name**: `moltbot` (o el que prefieras)
- **Your server's name**: `moltbot-server`
- **Pick a username**: `moltbot` (o el que prefieras)
- **Choose a password**: **Elige una contraseña segura** (la necesitarás para SSH)
- **Confirm your password**: Confirma la contraseña

⚠️ **ANOTA ESTA CONTRASEÑA** - La necesitarás para conectarte vía SSH

### 2.9 SSH Setup ⚠️ MUY IMPORTANTE
- **Marca la casilla**: **Install OpenSSH server**
- Esto es CRUCIAL para poder conectarte desde Cursor
- Presiona **Enter** para continuar

### 2.10 Snaps (Opcional)
- Puedes instalar algunos snaps o saltar
- No es crítico para nuestro propósito

### 2.11 Esperar Instalación
- El proceso tomará varios minutos (10-20 minutos)
- Espera pacientemente

### 2.12 Reiniciar
- Cuando termine, presiona **Enter** para reiniciar
- La VM se reiniciará y arrancará Ubuntu Server

## 🔌 Paso 3: Obtener IP y Verificar SSH

Una vez que Ubuntu esté instalado y reiniciado:

1. **Inicia sesión** con el usuario y contraseña que creaste
2. **Obtén la IP** de la VM:
   ```bash
   hostname -I
   ```
   Anota la IP que aparece (ej: `10.0.2.15`)

3. **Verifica SSH**:
   ```bash
   sudo systemctl status ssh
   ```
   Debe mostrar "active (running)"

## 📁 Paso 4: Transferir Scripts a la VM

Desde PowerShell en Windows (en el directorio del proyecto):

```powershell
# Reemplaza con la IP de tu VM
$vmIP = "10.0.2.15"  # Cambia esto por la IP real
$vmUser = "moltbot"

# Transferir scripts
.\scripts\transfer-to-vm.ps1 -VMUser $vmUser -VMIP $vmIP -SourcePath "scripts" -DestPath "/home/$vmUser/scripts"
```

O manualmente con SCP:
```powershell
scp -r scripts\* ${vmUser}@${vmIP}:~/scripts/
```

## 🚀 Paso 5: Instalar Node.js y Moltbot

Conectado a la VM vía SSH:

```bash
# Hacer scripts ejecutables
chmod +x ~/scripts/*.sh

# Ejecutar instalación completa
bash ~/scripts/setup-complete.sh
```

Esto instalará:
- SSH (si no está)
- Node.js 22.x
- Moltbot

## 💻 Paso 6: Conectar Cursor

1. **Abre Cursor**
2. **Instala extensión**: `Remote - SSH`
3. **Conecta**: `Ctrl+Shift+P` → `Remote-SSH: Connect to Host`
4. **Escribe**: `moltbot@127.0.0.1 -p 2222` (si usas NAT con port forwarding)
   - O: `moltbot@IP_DE_LA_VM` (si usas Bridge)
5. **Ingresa contraseña**
6. **Abre carpeta**: `/home/moltbot/moltbot-project`

## ✅ Verificar Todo

En la VM (desde Cursor o SSH):

```bash
node --version    # Debe ser v22.x.x
npm --version
moltbot --version  # O: which moltbot
```

## 🎉 ¡Listo!

Ahora tienes:
- ✅ VM aislada con Ubuntu Server
- ✅ SSH configurado
- ✅ Node.js 22+ instalado
- ✅ Moltbot instalado
- ✅ Cursor conectado

¡Puedes empezar a desarrollar con Moltbot de forma segura!

## 🆘 Problemas Comunes

### No puedo conectarme vía SSH
- Verifica IP: `hostname -I` en la VM
- Verifica SSH: `sudo systemctl status ssh` en la VM
- Prueba desde PowerShell: `ssh moltbot@127.0.0.1 -p 2222`

### Olvidé instalar SSH durante la instalación
```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

### La VM es muy lenta
- Aumenta la RAM en VirtualBox (Configuración → Sistema → Memoria base)
- Asigna más CPUs (Configuración → Sistema → Procesador)












