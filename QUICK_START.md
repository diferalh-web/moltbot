# 🚀 Inicio Rápido - Moltbot en VirtualBox

Esta es una guía rápida para empezar. Para detalles completos, consulta [README.md](README.md).

## ⚡ Pasos Rápidos

### 1️⃣ Instalar VirtualBox y crear VM (30-45 min)

1. **Descargar VirtualBox**: https://www.virtualbox.org/wiki/Downloads
2. **Instalar VirtualBox** + Extension Pack
3. **Descargar Ubuntu Server 22.04**: https://ubuntu.com/download/server
4. **Crear VM en VirtualBox**:
   - Nombre: `moltbot-vm`
   - RAM: 4 GB
   - Disco: 30 GB (dinámico)
   - Montar ISO de Ubuntu Server
5. **Instalar Ubuntu Server**:
   - ⚠️ **IMPORTANTE**: Marca "Install OpenSSH server" durante la instalación
   - Crea usuario: `moltbot` (o el que prefieras)
   - Anota la contraseña

📖 **Guía detallada**: [GUIA_VIRTUALBOX.md](GUIA_VIRTUALBOX.md)

---

### 2️⃣ Obtener IP de la VM (1 min)

En la terminal de la VM:
```bash
hostname -I
```

Anota la IP (ej: `10.0.2.15`)

---

### 3️⃣ Configurar SSH (si no se instaló) (2 min)

En la terminal de la VM:
```bash
bash scripts/setup-ssh.sh
```

O manualmente:
```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

---

### 4️⃣ Conectar Cursor a la VM (5 min)

1. **Instalar extensión** en Cursor: `Remote - SSH`
2. **Conectar**: `Ctrl+Shift+P` → `Remote-SSH: Connect to Host`
3. **Escribir**: `moltbot@IP_DE_LA_VM` (ej: `moltbot@10.0.2.15`)
4. **Ingresar contraseña** cuando se solicite
5. **Abrir carpeta**: `/home/moltbot/moltbot-project`

📖 **Guía detallada**: [CURSOR_SSH_SETUP.md](CURSOR_SSH_SETUP.md)

---

### 5️⃣ Instalar Node.js y Moltbot (10-15 min)

En la terminal de Cursor (conectado a la VM):

**Opción rápida (todo en uno):**
```bash
bash scripts/setup-complete.sh
```

**O paso a paso:**
```bash
# Instalar Node.js
bash scripts/install-nodejs.sh

# Instalar Moltbot
bash scripts/install-moltbot.sh
```

---

### 6️⃣ Verificar instalación (1 min)

```bash
node --version    # Debe mostrar v22.x.x
npm --version
moltbot --version # O: which moltbot
```

---

## ✅ ¡Listo!

Ahora tienes:
- ✅ VM aislada con Ubuntu Server
- ✅ SSH configurado
- ✅ Cursor conectado a la VM
- ✅ Node.js 22+ instalado
- ✅ Moltbot instalado

---

## 🎯 Próximos Pasos

1. **Configurar Moltbot**: Crea archivos de configuración según necesites
2. **Probar Moltbot**: Ejecuta `moltbot` y verifica que funciona
3. **Desarrollar**: Usa Cursor para crear y editar archivos en la VM

---

## 🆘 Problemas Comunes

### No puedo conectarme vía SSH
- Verifica IP: `hostname -I` en la VM
- Verifica SSH: `sudo systemctl status ssh` en la VM
- Si usas NAT, configura port forwarding en VirtualBox

### Scripts no se ejecutan
```bash
chmod +x scripts/*.sh
```

### Node.js no se instala
```bash
sudo apt update && sudo apt upgrade -y
bash scripts/install-nodejs.sh
```

---

## 📚 Documentación Completa

- [README.md](README.md) - Documentación completa
- [GUIA_VIRTUALBOX.md](GUIA_VIRTUALBOX.md) - Guía detallada de VirtualBox
- [CURSOR_SSH_SETUP.md](CURSOR_SSH_SETUP.md) - Configuración de Cursor

---

**Tiempo total estimado**: 45-60 minutos (la mayor parte es la instalación de Ubuntu)

¡Buena suerte! 🚀












