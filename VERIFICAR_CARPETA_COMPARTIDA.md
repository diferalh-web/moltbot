# 🔍 Verificar Carpeta Compartida VirtualBox

## 📋 Script de Verificación

He creado un script que verifica todo lo necesario para la carpeta compartida.

### Ejecutar en la VM:

```bash
# Buscar el script
find / -name "verificar-carpeta-compartida.sh" 2>/dev/null

# O si conoces la ruta
cd /media/sf_shareFolder  # ajusta según tu configuración
chmod +x verificar-carpeta-compartida.sh
./verificar-carpeta-compartida.sh
```

## 🔧 Verificaciones Manuales

Si prefieres verificar manualmente:

### 1. Verificar Grupo vboxsf

```bash
# Ver si estás en el grupo
groups | grep vboxsf

# Si NO estás en el grupo, agregarte:
sudo usermod -aG vboxsf $USER

# Luego reinicia sesión SSH
exit
# Vuelve a conectarte
```

### 2. Verificar Montajes

```bash
# Ver todos los montajes de VirtualBox
mount | grep vboxsf

# Ver montajes en /media
ls -la /media/

# Ver si existe sf_shareFolder
ls -la /media/sf_shareFolder 2>/dev/null
```

### 3. Verificar VirtualBox Guest Additions

```bash
# Verificar si está instalado
ls /usr/bin/VBoxClient

# Ver servicios
systemctl list-units --type=service | grep vboxadd

# Ver estado de servicios
systemctl status vboxadd-service
```

### 4. Buscar Carpeta Compartida

```bash
# Buscar en ubicaciones comunes
ls /media/sf_* 2>/dev/null
ls /mnt/sf_* 2>/dev/null
ls /media/*/shareFolder 2>/dev/null

# Buscar los scripts
find / -name "configurar-moltbot-mistral-vm.sh" 2>/dev/null
```

## 🔧 Soluciones Comunes

### Problema 1: Usuario no está en grupo vboxsf

```bash
# Agregar al grupo
sudo usermod -aG vboxsf $USER

# Verificar
groups | grep vboxsf

# Reiniciar sesión SSH
exit
# Reconectar
```

### Problema 2: Carpeta compartida no está montada

```bash
# 1. Verificar nombre en VirtualBox
# Máquina > Configuración > Carpetas compartidas

# 2. Crear directorio de montaje
sudo mkdir -p /media/sf_shareFolder

# 3. Montar (reemplaza 'shareFolder' con el nombre real)
sudo mount -t vboxsf shareFolder /media/sf_shareFolder

# 4. Verificar
ls -la /media/sf_shareFolder
```

### Problema 3: Montar automáticamente al iniciar

```bash
# Editar /etc/fstab
sudo nano /etc/fstab

# Agregar esta línea (ajusta 'shareFolder' al nombre real):
shareFolder /media/sf_shareFolder vboxsf defaults 0 0

# Guardar y probar
sudo mount -a
```

### Problema 4: VirtualBox Guest Additions no instalado

```bash
# Instalar Guest Additions
sudo apt update
sudo apt install -y virtualbox-guest-utils virtualbox-guest-dkms

# Reiniciar
sudo reboot
```

## 📝 Verificar Configuración en VirtualBox

**En Windows Host:**

1. Abre VirtualBox
2. Selecciona tu VM
3. Click en **Configuración** > **Carpetas compartidas**
4. Verifica que:
   - Existe una carpeta compartida llamada `shareFolder` (o el nombre que uses)
   - La ruta es `C:\code\moltbot\shareFolder`
   - Está marcada como **Montar automáticamente** (opcional)
   - Está marcada como **Permanente** (recomendado)

## ✅ Después de Verificar

Una vez que la carpeta compartida esté montada y accesible:

```bash
# Navegar a la carpeta
cd /media/sf_shareFolder  # o la ruta que encuentres

# Ver archivos
ls -la

# Deberías ver:
# - configurar-moltbot-mistral-vm.sh
# - configurar-moltbot-qwen-vm.sh
# - encontrar-y-ejecutar-mistral.sh
# - verificar-carpeta-compartida.sh

# Ejecutar configuración
chmod +x configurar-moltbot-mistral-vm.sh
./configurar-moltbot-mistral-vm.sh
```

## 🆘 Si Nada Funciona

Si después de todo esto no puedes acceder a la carpeta compartida, puedes:

1. **Usar los comandos manuales** de `EJECUTAR_EN_VM_MISTRAL.md`
2. **Copiar los scripts vía SCP** (si SSH funciona)
3. **Crear los archivos manualmente** en la VM

¿Necesitas ayuda con alguna de estas opciones?












