# 🎯 Guía Paso a Paso - Ejecutando Todo

Esta guía te llevará paso a paso con comandos que puedes ejecutar directamente.

## 📋 Estado Actual

Ejecuta este comando para verificar qué tienes:

```powershell
.\scripts\check-requirements.ps1
```

---

## PASO 1: Verificar Requisitos ✅

**Ejecuta:**
```powershell
.\scripts\check-requirements.ps1
```

**Qué hace:**
- Verifica si VirtualBox está instalado
- Verifica Docker
- Verifica SSH
- Muestra RAM y espacio en disco

**Si falta algo, te diré cómo instalarlo.**

---

## PASO 2: Instalar VirtualBox 📥

### 2.1 Descargar VirtualBox

**Opción A: Descarga automática (te ayudo)**
```powershell
# Crear carpeta de descargas
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\Downloads\VirtualBox" | Out-Null

# Descargar VirtualBox (última versión)
$vboxUrl = "https://download.virtualbox.org/virtualbox/7.0.16/VirtualBox-7.0.16-162802-Win.exe"
$vboxPath = "$env:USERPROFILE\Downloads\VirtualBox\VirtualBox-installer.exe"

Write-Host "Descargando VirtualBox..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $vboxUrl -OutFile $vboxPath

Write-Host "✅ Descargado en: $vboxPath" -ForegroundColor Green
Write-Host "Ejecuta el instalador manualmente" -ForegroundColor Yellow
```

**Opción B: Descarga manual**
1. Ve a: https://www.virtualbox.org/wiki/Downloads
2. Descarga **VirtualBox 7.x** para Windows hosts
3. Descarga también **VirtualBox Extension Pack**

### 2.2 Instalar VirtualBox

**Debes hacer esto manualmente:**
1. Ejecuta el instalador descargado
2. Sigue el asistente (acepta todos los defaults)
3. ⚠️ **IMPORTANTE**: Acepta instalar los drivers de red
4. Al final, reinicia si te lo pide

### 2.3 Instalar Extension Pack

1. Abre VirtualBox (después de instalarlo)
2. Ve a: **Archivo → Preferencias → Extensiones**
3. Haz clic en el icono **+** (agregar)
4. Selecciona el archivo `.vbox-extpack` que descargaste
5. Acepta la licencia

**Verificar instalación:**
```powershell
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" --version
```

---

## PASO 3: Descargar Ubuntu Server 📥

**Ejecuta este comando para descargar Ubuntu Server automáticamente:**

```powershell
# Crear carpeta de descargas
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\Downloads\Ubuntu" | Out-Null

# URL de Ubuntu Server 22.04 LTS
$ubuntuUrl = "https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso"
$ubuntuPath = "$env:USERPROFILE\Downloads\Ubuntu\ubuntu-22.04-server.iso"

Write-Host "Descargando Ubuntu Server 22.04 LTS..." -ForegroundColor Yellow
Write-Host "Esto puede tomar varios minutos (4.8 GB)..." -ForegroundColor Yellow

# Descargar con barra de progreso
$ProgressPreference = 'Continue'
Invoke-WebRequest -Uri $ubuntuUrl -OutFile $ubuntuPath -UseBasicParsing

Write-Host "✅ Ubuntu descargado en: $ubuntuPath" -ForegroundColor Green
```

**O descarga manualmente:**
- Ve a: https://ubuntu.com/download/server
- Descarga Ubuntu Server 22.04 LTS

---

## PASO 4: Crear la Máquina Virtual 🖥️

**Esto lo haremos con comandos de VirtualBox:**

```powershell
# Configuración de la VM
$vmName = "moltbot-vm"
$vmRam = 4096  # 4 GB
$vmDisk = 30720  # 30 GB
$ubuntuIso = "$env:USERPROFILE\Downloads\Ubuntu\ubuntu-22.04-server.iso"

# Ruta de VirtualBox
$vboxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

# Verificar que VirtualBox está instalado
if (-not (Test-Path $vboxManage)) {
    Write-Host "❌ VirtualBox no está instalado. Instala VirtualBox primero." -ForegroundColor Red
    exit 1
}

Write-Host "Creando máquina virtual: $vmName" -ForegroundColor Cyan

# Crear VM
& $vboxManage createvm --name $vmName --ostype "Ubuntu_64" --register

# Configurar RAM
& $vboxManage modifyvm $vmName --memory $vmRam

# Configurar CPU (2 procesadores)
& $vboxManage modifyvm $vmName --cpus 2

# Configurar red (NAT)
& $vboxManage modifyvm $vmName --nic1 nat

# Crear disco duro
$vmPath = & $vboxManage list systemproperties | Select-String "Default machine folder" | ForEach-Object { $_.Line.Split(":")[1].Trim() }
$diskPath = Join-Path $vmPath $vmName "$vmName.vdi"

& $vboxManage createhd --filename $diskPath --size $vmDisk --format VDI --variant Standard

# Conectar disco a la VM
& $vboxManage storagectl $vmName --name "SATA Controller" --add sata --controller IntelAHCI
& $vboxManage storageattach $vmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $diskPath

# Montar ISO de Ubuntu
if (Test-Path $ubuntuIso) {
    & $vboxManage storagectl $vmName --name "IDE Controller" --add ide
    & $vboxManage storageattach $vmName --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $ubuntuIso
    Write-Host "✅ ISO de Ubuntu montada" -ForegroundColor Green
} else {
    Write-Host "⚠️  ISO no encontrada en: $ubuntuIso" -ForegroundColor Yellow
    Write-Host "Monta la ISO manualmente desde VirtualBox" -ForegroundColor Yellow
}

# Configurar port forwarding para SSH (puerto 2222 del host -> 22 de la VM)
& $vboxManage modifyvm $vmName --natpf1 "ssh,tcp,,2222,,22"

Write-Host ""
Write-Host "✅ Máquina virtual creada: $vmName" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "1. Abre VirtualBox" -ForegroundColor Gray
Write-Host "2. Selecciona '$vmName' y haz clic en 'Iniciar'" -ForegroundColor Gray
Write-Host "3. Sigue la instalación de Ubuntu Server" -ForegroundColor Gray
Write-Host "4. ⚠️ IMPORTANTE: Marca 'Install OpenSSH server' durante la instalación" -ForegroundColor Yellow
```

---

## PASO 5: Instalar Ubuntu Server en la VM 🐧

**Esto lo haces manualmente en la ventana de VirtualBox:**

1. **Inicia la VM** desde VirtualBox
2. **Sigue la instalación** de Ubuntu Server:
   - Idioma: Elige el tuyo
   - Tipo: Ubuntu Server (normal)
   - Red: Acepta DHCP
   - Proxy: Déjalo vacío
   - Almacenamiento: **Use an entire disk**
   - Perfil:
     - Nombre: `moltbot`
     - Nombre de servidor: `moltbot-server`
     - Usuario: `moltbot`
     - Contraseña: **Elije una segura** (la necesitarás)
   - **SSH Setup**: ⚠️ **Marca "Install OpenSSH server"** (MUY IMPORTANTE)
3. **Espera** a que termine la instalación
4. **Reinicia** cuando termine

---

## PASO 6: Configurar SSH y Obtener IP 🔌

**Una vez que Ubuntu esté instalado y reiniciado:**

En la terminal de la VM, ejecuta:

```bash
# Obtener IP
hostname -I
```

**Anota la IP** que aparece.

**Si SSH no se instaló automáticamente:**

```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

---

## PASO 7: Conectar desde Windows y Transferir Scripts 📁

**Desde PowerShell en Windows:**

```powershell
# Reemplaza con la IP de tu VM
$vmIP = "10.0.2.15"  # Cambia esto por la IP real
$vmUser = "moltbot"

# Probar conexión SSH
ssh ${vmUser}@${vmIP}

# Si funciona, sal con: exit
```

**Transferir scripts a la VM:**

```powershell
# Desde el directorio del proyecto
$vmIP = "10.0.2.15"  # Cambia esto
$vmUser = "moltbot"

# Transferir scripts
scp -r scripts\* ${vmUser}@${vmIP}:~/scripts/

# O usar el script incluido
.\scripts\transfer-to-vm.ps1 -VMUser $vmUser -VMIP $vmIP -SourcePath "scripts" -DestPath "/home/$vmUser/scripts"
```

---

## PASO 8: Instalar Node.js y Moltbot en la VM 🤖

**Conectado a la VM vía SSH:**

```bash
# Hacer scripts ejecutables
chmod +x ~/scripts/*.sh

# Ejecutar instalación completa
bash ~/scripts/setup-complete.sh
```

**O paso a paso:**

```bash
# Configurar SSH (si no está)
bash ~/scripts/setup-ssh.sh

# Instalar Node.js
bash ~/scripts/install-nodejs.sh

# Instalar Moltbot
bash ~/scripts/install-moltbot.sh
```

---

## PASO 9: Conectar Cursor a la VM 💻

1. **Abre Cursor**
2. **Instala extensión**: `Remote - SSH`
3. **Conecta**: `Ctrl+Shift+P` → `Remote-SSH: Connect to Host`
4. **Escribe**: `moltbot@IP_DE_LA_VM` (ej: `moltbot@10.0.2.15`)
5. **O si usas port forwarding**: `moltbot@127.0.0.1 -p 2222`
6. **Ingresa contraseña**
7. **Abre carpeta**: `/home/moltbot/moltbot-project`

📖 **Detalles**: Ver [CURSOR_SSH_SETUP.md](CURSOR_SSH_SETUP.md)

---

## PASO 10: Verificar Todo ✅

**En la VM (desde Cursor o SSH):**

```bash
# Verificar Node.js
node --version  # Debe ser v22.x.x

# Verificar npm
npm --version

# Verificar Moltbot
moltbot --version
# O
which moltbot
```

---

## 🎉 ¡Listo!

Ahora tienes:
- ✅ VM aislada con Ubuntu Server
- ✅ SSH configurado
- ✅ Node.js 22+ instalado
- ✅ Moltbot instalado
- ✅ Cursor conectado

**Puedes empezar a desarrollar con Moltbot de forma segura en un ambiente aislado.**

---

## 🆘 Si algo falla

1. **Revisa los logs** de los scripts
2. **Verifica la conexión SSH**: `ssh usuario@IP`
3. **Consulta las guías detalladas**:
   - [GUIA_VIRTUALBOX.md](GUIA_VIRTUALBOX.md)
   - [CURSOR_SSH_SETUP.md](CURSOR_SSH_SETUP.md)
   - [README.md](README.md)












