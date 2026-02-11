# Guía Completa: Instalar Moltbot en VirtualBox con Ubuntu Server

## Paso 1: Instalar VirtualBox

### 1.1 Descargar VirtualBox
1. Ve a: https://www.virtualbox.org/wiki/Downloads
2. Descarga **VirtualBox 7.x** para Windows hosts
3. Descarga también **VirtualBox Extension Pack** (mismo sitio)

### 1.2 Instalar VirtualBox
1. Ejecuta el instalador de VirtualBox
2. Sigue el asistente de instalación (acepta todos los defaults)
3. **IMPORTANTE**: Durante la instalación, acepta instalar los drivers de red (puede desconectar temporalmente tu internet)

### 1.3 Instalar Extension Pack
1. Abre VirtualBox
2. Ve a: **Archivo → Preferencias → Extensiones**
3. Haz clic en el icono **+** (agregar)
4. Selecciona el archivo `.vbox-extpack` que descargaste
5. Acepta la licencia

---

## Paso 2: Descargar Ubuntu Server

### 2.1 Obtener la imagen ISO
1. Ve a: https://ubuntu.com/download/server
2. Descarga **Ubuntu Server 22.04 LTS** o **24.04 LTS** (recomendado 22.04)
3. Guarda el archivo `.iso` en una ubicación fácil de encontrar (ej: `C:\Users\TuUsuario\Downloads\ubuntu-22.04-server.iso`)

---

## Paso 3: Crear la Máquina Virtual

### 3.1 Crear nueva VM
1. Abre VirtualBox
2. Haz clic en **Nuevo** (o presiona `Ctrl+N`)
3. Configura:
   - **Nombre**: `moltbot-vm`
   - **Tipo**: Linux
   - **Versión**: Ubuntu (64-bit)
   - Haz clic en **Siguiente**

### 3.2 Configurar Memoria RAM
- **Recomendado**: 4096 MB (4 GB)
- **Mínimo**: 2048 MB (2 GB)
- Haz clic en **Siguiente**

### 3.3 Crear Disco Virtual
1. Selecciona **Crear un disco virtual ahora**
2. Haz clic en **Crear**
3. Tipo de archivo: **VDI (VirtualBox Disk Image)**
4. Almacenamiento: **Asignado dinámicamente** (recomendado)
5. Tamaño: **30 GB** (puedes ajustar según tu espacio)
6. Haz clic en **Crear**

### 3.4 Configurar la VM (ANTES de iniciarla)
1. Selecciona la VM `moltbot-vm`
2. Haz clic en **Configuración** (icono de engranaje)
3. Ve a **Sistema → Procesador**:
   - Procesadores: **2** (o más si tienes disponibles)
   - Habilita **PAE/NX** si está disponible
4. Ve a **Almacenamiento**:
   - En **Controlador: IDE**, haz clic en el icono de disco vacío
   - En **Atributos**, haz clic en el icono de disco junto a "Unidad óptica"
   - Selecciona **Elegir un archivo de disco...**
   - Selecciona tu archivo `.iso` de Ubuntu Server
5. Ve a **Red**:
   - Adaptador 1: **NAT** (para acceso a internet)
   - O **Adaptador puente** si quieres que la VM tenga IP en tu red local
6. Ve a **Carpetas compartidas** (opcional pero útil):
   - Haz clic en el icono **+** (agregar)
   - Ruta de carpeta: `C:\moltbot-dev` (o la que prefieras)
   - Nombre de carpeta: `moltbot-dev`
   - Marca **Auto-montar** y **Hacer permanente**
7. Haz clic en **Aceptar**

---

## Paso 4: Instalar Ubuntu Server en la VM

### 4.1 Iniciar la VM
1. Selecciona `moltbot-vm`
2. Haz clic en **Iniciar** (flecha verde)
3. La VM se abrirá en una ventana nueva

### 4.2 Proceso de instalación de Ubuntu
1. **Seleccionar idioma**: Elige tu idioma preferido
2. **Actualizar instalador**: Si pregunta, elige **Actualizar al instalador más reciente**
3. **Tipo de instalación**: 
   - Elige **Ubuntu Server** (instalación normal)
4. **Configuración de red**:
   - Si aparece, acepta la configuración DHCP automática
5. **Proxy**: Déjalo vacío (a menos que uses proxy)
6. **Archivo de instalación Ubuntu**: Usa el mirror por defecto
7. **Configuración de almacenamiento**:
   - Elige **Use an entire disk** (usar todo el disco)
   - Selecciona el disco virtual que creaste
   - Confirma escribiendo **yes** y presiona Enter
8. **Perfil del sistema**:
   - Nombre: `moltbot` (o el que prefieras)
   - Nombre de servidor: `moltbot-server`
   - Usuario: `moltbot` (o el que prefieras)
   - **CONTRASEÑA**: Elige una contraseña segura (la necesitarás para SSH)
   - Confirma la contraseña
9. **SSH Setup**:
   - **IMPORTANTE**: Marca la casilla **Install OpenSSH server**
   - Esto es crucial para conectarte con Cursor
10. **Snaps**: Puedes instalar algunos o saltar (no es crítico)
11. **Esperar instalación**: El proceso tomará varios minutos
12. **Reiniciar**: Cuando termine, presiona Enter para reiniciar

### 4.3 Primera conexión
1. La VM se reiniciará
2. Inicia sesión con el usuario y contraseña que creaste
3. Verás el prompt de terminal de Ubuntu

---

## Paso 5: Configurar SSH (si no se instaló automáticamente)

Ejecuta estos comandos en la terminal de la VM:

```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl status ssh
```

### 5.1 Obtener la IP de la VM
```bash
ip addr show
# O más simple:
hostname -I
```

Anota la IP que aparece (ej: `10.0.2.15` para NAT, o una IP de tu red si usas Bridge)

---

## Paso 6: Configurar acceso SSH desde Windows

### 6.1 Habilitar SSH en Windows (si es necesario)
1. Abre PowerShell como Administrador
2. Ejecuta:
```powershell
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
```

### 6.2 Probar conexión SSH
En PowerShell o CMD de Windows:
```bash
ssh moltbot@IP_DE_LA_VM
# Ejemplo: ssh moltbot@10.0.2.15
```

Si te pide confirmar la clave, escribe `yes` y presiona Enter.
Ingresa tu contraseña cuando se solicite.

---

## Paso 7: Configurar Port Forwarding (si usas NAT)

Si tu VM usa NAT y no puedes conectarte, configura port forwarding:

1. En VirtualBox, selecciona la VM (apagada)
2. **Configuración → Red → Adaptador 1 → Avanzado → Reenvío de puertos**
3. Agrega una regla:
   - **Nombre**: SSH
   - **Protocolo**: TCP
   - **IP del anfitrión**: 127.0.0.1
   - **Puerto del anfitrión**: 2222
   - **IP del invitado**: (deja vacío)
   - **Puerto del invitado**: 22
4. Guarda y reinicia la VM
5. Conéctate con: `ssh moltbot@127.0.0.1 -p 2222`

---

## Siguiente paso: Ejecutar los scripts de instalación

Una vez que tengas SSH funcionando, continúa con los scripts de instalación que están en este proyecto.












