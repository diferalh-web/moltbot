# Configurar Cursor para trabajar con la VM vía SSH

## Paso 1: Instalar extensión Remote-SSH en Cursor

1. Abre Cursor
2. Ve a **Extensions** (Ctrl+Shift+X)
3. Busca: **Remote - SSH**
4. Instala la extensión de Microsoft (Remote - SSH)
5. Reinicia Cursor si es necesario

---

## Paso 2: Obtener la IP de tu VM

En la terminal de tu VM (o conectado vía SSH), ejecuta:

```bash
hostname -I
```

Anota la IP que aparece (ej: `10.0.2.15` o `192.168.1.100`)

---

## Paso 3: Configurar conexión SSH en Cursor

### Opción A: Configuración rápida

1. En Cursor, presiona `Ctrl+Shift+P` (o `Cmd+Shift+P` en Mac)
2. Escribe: **Remote-SSH: Connect to Host**
3. Selecciona la opción
4. Escribe: `moltbot@IP_DE_TU_VM`
   - Ejemplo: `moltbot@10.0.2.15`
   - O si usas port forwarding: `moltbot@127.0.0.1 -p 2222`
5. Selecciona la plataforma: **Linux**
6. Ingresa tu contraseña cuando se solicite
7. Cursor se conectará y abrirá una nueva ventana

### Opción B: Configuración permanente (recomendado)

1. Presiona `Ctrl+Shift+P`
2. Escribe: **Remote-SSH: Open SSH Configuration File**
3. Selecciona el archivo de configuración (generalmente el primero)
4. Agrega esta configuración:

```
Host moltbot-vm
    HostName 10.0.2.15
    User moltbot
    Port 22
    # Si usas port forwarding, usa esto en su lugar:
    # HostName 127.0.0.1
    # Port 2222
```

5. Guarda el archivo (Ctrl+S)
6. Ahora puedes conectarte usando: `Ctrl+Shift+P` → **Remote-SSH: Connect to Host** → Selecciona `moltbot-vm`

---

## Paso 4: Conectarse a la VM

1. Presiona `Ctrl+Shift+P`
2. Escribe: **Remote-SSH: Connect to Host**
3. Selecciona `moltbot-vm` (o la IP directamente)
4. Espera a que Cursor se conecte (primera vez puede tardar)
5. Ingresa tu contraseña cuando se solicite
6. Selecciona la plataforma: **Linux**

---

## Paso 5: Abrir carpeta en la VM

Una vez conectado:

1. Ve a **File → Open Folder** (o `Ctrl+K Ctrl+O`)
2. Navega a: `/home/moltbot/moltbot-project` (o crea la carpeta primero)
3. O crea una nueva carpeta desde Cursor

---

## Paso 6: Trabajar con archivos

Ahora puedes:
- ✅ Editar archivos directamente en la VM
- ✅ Ejecutar terminal integrado (Ctrl+`)
- ✅ Instalar extensiones que funcionen en Linux
- ✅ Usar Git, Node.js, npm, etc. desde Cursor

---

## Solución de problemas

### Error: "Could not establish connection"
- Verifica que SSH esté corriendo en la VM: `sudo systemctl status ssh`
- Verifica la IP: `hostname -I`
- Prueba la conexión desde PowerShell: `ssh moltbot@IP`

### Error: "Permission denied"
- Verifica usuario y contraseña
- Si usas claves SSH, asegúrate de que estén configuradas

### No puedo conectarme desde Windows
- Si usas NAT, configura port forwarding en VirtualBox (ver GUIA_VIRTUALBOX.md)
- O cambia la red de la VM a "Adaptador puente"

### La conexión es lenta
- Aumenta la RAM de la VM
- Cierra otras aplicaciones pesadas
- Considera usar una conexión por cable en lugar de WiFi

---

## Configuración avanzada: Claves SSH (sin contraseña)

Para no tener que ingresar contraseña cada vez:

### En Windows (PowerShell):

```powershell
# Generar clave SSH (si no tienes una)
ssh-keygen -t rsa -b 4096

# Copiar clave a la VM
ssh-copy-id moltbot@IP_DE_LA_VM
```

Ahora podrás conectarte sin contraseña.

---

## Usar Cursor con la VM

Una vez conectado, puedes:

1. **Abrir terminal integrado**: `Ctrl+` (backtick)
2. **Ejecutar comandos**: Todos los comandos se ejecutan en la VM
3. **Editar archivos**: Los cambios se guardan directamente en la VM
4. **Instalar extensiones**: Funcionan en el contexto remoto
5. **Usar Git**: Clonar repositorios, hacer commits, etc.

---

## Crear proyecto de Moltbot

Una vez conectado vía SSH:

```bash
# Crear directorio del proyecto
mkdir -p ~/moltbot-project
cd ~/moltbot-project

# Inicializar proyecto (si es necesario)
npm init -y

# Instalar dependencias locales (si las hay)
# npm install ...

# Crear archivos de configuración
# (Cursor te permite crear y editar archivos directamente)
```

¡Listo! Ahora puedes desarrollar Moltbot directamente desde Cursor en tu VM aislada.












