# Moltbot - Configuración en VirtualBox con Ubuntu Server

Este proyecto contiene todos los scripts y guías necesarios para instalar y configurar Moltbot en una máquina virtual aislada usando VirtualBox y Ubuntu Server, con integración completa con Cursor IDE.

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Guía de Instalación Completa](#guía-de-instalación-completa)
3. [Scripts de Instalación](#scripts-de-instalación)
4. [Configuración de Cursor](#configuración-de-cursor)
5. [Uso de Docker (Opcional)](#uso-de-docker-opcional)
6. [Solución de Problemas](#solución-de-problemas)

## 🔧 Requisitos Previos

- Windows 10/11
- Al menos 8 GB de RAM (4 GB para la VM + 4 GB para el host)
- 50 GB de espacio libre en disco
- Conexión a internet
- VirtualBox (se instala en el proceso)

## 📚 Guía de Instalación Completa

### Paso 1: Configurar VirtualBox y la VM

Sigue la guía detallada en: **[GUIA_VIRTUALBOX.md](GUIA_VIRTUALBOX.md)**

Esta guía te llevará paso a paso para:
- Instalar VirtualBox
- Descargar Ubuntu Server
- Crear y configurar la máquina virtual
- Instalar Ubuntu Server en la VM

### Paso 2: Configurar SSH

Una vez que tengas Ubuntu Server instalado en la VM:

1. **Opción A: Ejecutar script automático** (recomendado)
   ```bash
   # En la terminal de la VM
   cd /ruta/a/este/proyecto
   bash scripts/setup-ssh.sh
   ```

2. **Opción B: Manual**
   ```bash
   sudo apt update
   sudo apt install -y openssh-server
   sudo systemctl enable ssh
   sudo systemctl start ssh
   ```

3. Obtén la IP de la VM:
   ```bash
   hostname -I
   ```

### Paso 3: Conectar Cursor vía SSH

Sigue la guía detallada en: **[CURSOR_SSH_SETUP.md](CURSOR_SSH_SETUP.md)**

Esta guía explica cómo:
- Instalar la extensión Remote-SSH en Cursor
- Configurar la conexión SSH
- Conectarte a la VM desde Cursor
- Trabajar con archivos en la VM

### Paso 4: Instalar Node.js y Moltbot

Una vez conectado a la VM desde Cursor:

#### Opción A: Script completo (recomendado)
```bash
# En la terminal de Cursor (conectado a la VM)
cd ~/moltbot-project  # o donde hayas montado este proyecto
bash scripts/setup-complete.sh
```

Este script ejecuta automáticamente:
- Configuración de SSH
- Instalación de Node.js 22.x
- Instalación de Moltbot

#### Opción B: Scripts individuales
```bash
# Instalar Node.js
bash scripts/install-nodejs.sh

# Instalar Moltbot
bash scripts/install-moltbot.sh
```

#### Opción C: Manual
```bash
# Instalar Node.js
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Instalar Moltbot
sudo npm install -g moltbot@latest
```

### Paso 5: Verificar instalación

```bash
# Verificar Node.js
node --version  # Debe mostrar v22.x.x o superior
npm --version

# Verificar Moltbot
moltbot --version
# O
which moltbot
```

## 🚀 Scripts de Instalación

Este proyecto incluye varios scripts para automatizar la instalación:

| Script | Descripción |
|--------|-------------|
| `scripts/setup-complete.sh` | **Ejecuta todo**: SSH + Node.js + Moltbot |
| `scripts/setup-ssh.sh` | Configura SSH en Ubuntu Server |
| `scripts/install-nodejs.sh` | Instala Node.js 22.x |
| `scripts/install-moltbot.sh` | Instala Moltbot globalmente |

### Uso de los scripts

1. Copia los scripts a tu VM (o clona este repositorio)
2. Haz los scripts ejecutables:
   ```bash
   chmod +x scripts/*.sh
   ```
3. Ejecuta el script deseado:
   ```bash
   bash scripts/setup-complete.sh
   ```

## 💻 Configuración de Cursor

Una vez que tengas SSH funcionando, puedes trabajar completamente desde Cursor:

1. **Conecta vía SSH** (ver [CURSOR_SSH_SETUP.md](CURSOR_SSH_SETUP.md))
2. **Abre una carpeta** en la VM: `/home/moltbot/moltbot-project`
3. **Usa el terminal integrado**: `Ctrl+` (backtick)
4. **Edita archivos directamente** en la VM
5. **Ejecuta comandos** desde Cursor

## 🐳 Uso de Docker (Opcional)

Si prefieres usar Docker en lugar de instalación directa:

### Configuración básica

```bash
# Copiar docker-compose.yml a tu proyecto
cp docker-compose.yml ~/moltbot-project/

# Crear directorios necesarios
mkdir -p ~/moltbot-project/{moltbot-data,moltbot-config,moltbot-logs}

# Iniciar Moltbot en Docker
cd ~/moltbot-project
docker-compose up -d
```

### Configuración segura (con restricciones)

```bash
# Usar configuración con restricciones de seguridad
docker-compose -f docker-compose.secure.yml up -d
```

Ver archivos:
- `docker-compose.yml` - Configuración básica
- `docker-compose.secure.yml` - Configuración con restricciones de seguridad

## 🔒 Seguridad y Aislamiento

### Ventajas de esta configuración

✅ **Aislamiento completo**: Moltbot solo puede acceder a recursos dentro de la VM  
✅ **Fácil de resetear**: Puedes crear snapshots y restaurar si algo sale mal  
✅ **Control de recursos**: Limita RAM, CPU y disco desde VirtualBox  
✅ **Red aislada**: Configura la red según tus necesidades  
✅ **Desarrollo seguro**: Prueba sin riesgo en tu sistema principal  

### Recomendaciones de seguridad

1. **No uses `--privileged`** en Docker a menos que sea absolutamente necesario
2. **Crea snapshots** de la VM antes de hacer cambios importantes
3. **Configura firewall** en Ubuntu si necesitas restricciones de red
4. **Usa usuarios no-root** para ejecutar Moltbot
5. **Revisa permisos** de archivos y directorios

## 🛠️ Solución de Problemas

### Problema: No puedo conectarme vía SSH

**Solución:**
1. Verifica que SSH esté corriendo: `sudo systemctl status ssh`
2. Verifica la IP: `hostname -I`
3. Si usas NAT, configura port forwarding en VirtualBox
4. Prueba desde PowerShell: `ssh usuario@IP`

### Problema: Node.js no se instala

**Solución:**
```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Reintentar instalación
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Problema: Moltbot no se encuentra después de instalar

**Solución:**
```bash
# Verificar instalación
npm list -g moltbot

# Agregar al PATH si es necesario
export PATH=$PATH:/usr/local/bin

# O usar npx
npx moltbot
```

### Problema: La VM es muy lenta

**Solución:**
1. Aumenta la RAM asignada (mínimo 4 GB recomendado)
2. Asigna más CPUs (2-4 CPUs)
3. Habilita aceleración de hardware en VirtualBox
4. Cierra aplicaciones pesadas en el host

### Problema: No puedo copiar archivos a la VM

**Solución:**
1. Usa carpetas compartidas de VirtualBox
2. O usa SCP desde Windows:
   ```powershell
   scp archivo.txt moltbot@IP_DE_LA_VM:/home/moltbot/
   ```
3. O usa Cursor para crear/editar archivos directamente

## 📝 Estructura del Proyecto

```
moltbot/
├── README.md                    # Este archivo
├── GUIA_VIRTUALBOX.md          # Guía completa de VirtualBox
├── CURSOR_SSH_SETUP.md         # Guía de configuración de Cursor
├── docker-compose.yml           # Docker básico
├── docker-compose.secure.yml   # Docker con restricciones
└── scripts/
    ├── setup-complete.sh        # Script completo
    ├── setup-ssh.sh            # Configurar SSH
    ├── install-nodejs.sh       # Instalar Node.js
    └── install-moltbot.sh      # Instalar Moltbot
```

## 🎯 Próximos Pasos

Una vez que tengas todo configurado:

1. **Configura Moltbot**: Crea archivos de configuración según la documentación oficial
2. **Prueba la instalación**: Ejecuta `moltbot` y verifica que funciona
3. **Desarrolla tu proyecto**: Usa Cursor para crear y editar archivos
4. **Crea snapshots**: Guarda estados de la VM antes de cambios importantes

## 📚 Recursos Adicionales

- [Documentación oficial de Moltbot](https://github.com/moltbot/moltbot) (cuando esté disponible)
- [Documentación de VirtualBox](https://www.virtualbox.org/manual/)
- [Documentación de Ubuntu Server](https://ubuntu.com/server/docs)
- [Documentación de Remote-SSH en VS Code/Cursor](https://code.visualstudio.com/docs/remote/ssh)

## 🤝 Contribuciones

Si encuentras problemas o mejoras, siéntete libre de:
- Reportar issues
- Sugerir mejoras
- Compartir tus configuraciones

## ⚠️ Notas Importantes

- **Moltbot puede ejecutar comandos reales**: Por eso el aislamiento en VM es importante
- **Backup regular**: Crea snapshots de la VM regularmente
- **Contraseñas seguras**: Usa contraseñas fuertes para SSH
- **Actualizaciones**: Mantén Ubuntu y los paquetes actualizados

---

¡Listo para empezar! Sigue los pasos en orden y tendrás Moltbot funcionando en un ambiente aislado y seguro. 🚀












